-- CONSTS
local REMOTE_NAME = "NetworkObjectEvent"
local REMOTE_FUNC_NAME = "NetworkObjectFunction"

local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameShared = ReplicatedStorage:WaitForChild("GameShared")
local sharedLib = gameShared:WaitForChild("SharedLib")
local util = gameShared:WaitForChild("Util")

local cryo = require(util:WaitForChild("Cryo"))

local luaClassModule = sharedLib:WaitForChild("LuaClass")
local luaClass = require(luaClassModule)
local baseObject = require(luaClassModule:WaitForChild("BaseObject"))

local BaseNetworkedObject, get, set = luaClass("BaseNetworkedObject", baseObject)

-- class static variables
local processEvents = isServer and true or false -- on the client, throw out queued events that come from before population
local instancedObjects = {} -- map by hash
local _serializedObjects

local remoteEvent, remoteFunc do
    if isServer then
        remoteEvent, remoteFunc = Instance.new("RemoteEvent"), Instance.new("RemoteFunction")
        remoteEvent.Name = REMOTE_NAME
        remoteFunc.Name = REMOTE_FUNC_NAME
        remoteEvent.Parent = script
        remoteFunc.Parent = script
    else
        remoteEvent, remoteFunc = script:WaitForChild(REMOTE_NAME), script:WaitForChild(REMOTE_FUNC_NAME)
    end
end

-- define base network methods
local baseNetworkMethods do
    if isServer then
        baseNetworkMethods = {
            __requestPopulate = function(client) -- special network function asking the server to send initialization data of previously created objects to a specific client
                -- this involves sending to a client that is not the owner, so it has to go around the standard send method
                if not _serializedObjects then
                    -- serialize
                    _serializedObjects = {}
                    for hash, obj in pairs(instancedObjects) do
                        table.insert(_serializedObjects, obj:__serialize())
                    end
                end
                local send = {
                    {"__populate", {_serializedObjects}}
                }
                remoteEvent:FireClient(client, "__populate", send)
            end;
        }
    else
        local function init(serializedProps)
            --local passed, err = pcall(function() -- have to wrap in pcall, as the error would otherwise not get logged.
                local classType = serializedProps.classType
                local hash = serializedProps.id

                -- check if object has already been created (can happen if created when we called request population)
                if instancedObjects[hash] then return end

                -- check to see if class already exists
                local class = luaClass.classes[classType]
                if not class then
                    -- yield until class is defined
                    local t = tick()
                    local didWarn = false
                    repeat
                        RunService.Heartbeat:Wait()
                        class = luaClass.classes[classType]
                        if not didWarn and tick()-t > 1 then
                            didWarn = true
                            warn("BaseNetworkedObject.network.__init() | Class, '"..classType.."' has not yet been defined, yielding until definition.")
                        end
                    until class ~= nil
                end

                -- with class defined, instantiate from serialized props
                serializedProps["replicated"] = true
                instancedObjects[hash] = class(serializedProps)
            --end)
            --if not passed then 
                --warn("BaseNetworkedObject.network.__init Error:", err)
            --end
        end

        baseNetworkMethods = {
            __init = init; -- special network function to handle the creation of server created network objects
            __populate = function(serializedObjects) -- special network function to handle the batch creation of pre-existing objects
                for i = 1, #serializedObjects do
                    -- init can yield, so each should be its own thread
                    coroutine.wrap(init)(serializedObjects[i])
                end
            end;
            __destroy = function(self) -- network method to cleanup a server created object
                self:Destroy()
            end;
            __setOwner = function(self, newOwner) -- network method to tell the client to change ownership of the object
                assert(newOwner:IsA("Player") or (newOwner == nil), self.__name..".network.__setOwner() | must provide a Player instance or nil.")
                self._ownerId = tostring(newOwner.UserId)
                self._owner = newOwner
            end;
        }
    end
end

-- finally set base network methods
BaseNetworkedObject._networkMethods = baseNetworkMethods

-- private methods
local function _handleNetworkEvents(self, batchedEvents) -- handle a batch of events from the client/server
    for i = 1, #batchedEvents do
        local pair = batchedEvents[i]
        local methods = self._networkMethods or baseNetworkMethods
        
        if not methods[pair[1]] then
            error(self.__name.."._handleNetworkEvents() | attempt to call invalid network method '"..pair[1].."()'")
        end
        methods[pair[1]](self, unpack(pair[2]))
    end
end

local function _sendBatchedEvents(self)
    -- fire event batch
    if #self._eventBatch > 0 then
        local tempBatch = {} -- to hold the items so we can clear the eventBatch, tempBatch should get GCed by the next frame
        for i = 1, #self._eventBatch do
            tempBatch[i] = self._eventBatch[i]
        end
        if isServer then
            remoteEvent:FireClient(self._owner, self:__hash(), tempBatch)
        else
            remoteEvent:FireServer(self:__hash(), tempBatch)
        end
        table.clear(self._eventBatch)
    end

    -- do global event batch
    if not isServer then return end
    if #self._globalEventBatch > 0 then
        local tempBatch = {} -- to hold the items so we can clear the eventBatch, tempBatch should get GCed by the next frame
        for i = 1, #self._globalEventBatch do
            tempBatch[i] = self._globalEventBatch[i]
            -- Handle initialization differently, as we have to send all properties serializable at the very point of transfer (couldn't do this in the __init as it was still being created)
            if tempBatch[i][1] == "__init" then 
                tempBatch[i][2] = {self:__serialize()}
            end
        end
        remoteEvent:FireAllClients(self:__hash(), tempBatch)
        table.clear(self._globalEventBatch)
    end
end

local _fireNetworkEvent, _fireGlobalNetworkEvent, heartbeatConnection do
    if isServer then
        remoteEvent.OnServerEvent:Connect(function(client, objHash, batch)
            if objHash == "__requestPopulate" then baseNetworkMethods[objHash](client) return end
            
            -- get the toolbar from the client
            local networkedObj = instancedObjects[objHash]
            local owned = networkedObj and (networkedObj._owner == client)
            if owned then
                _handleNetworkEvents(networkedObj, batch)
            end
        end)
    else
        local function getInitData(batch)
            -- if networkedObj doesn't exist, probably exists initialization data, which *should* be the first thing in the batch
            if not (batch[1] and (batch[1][1] == "__init" or batch[1][1] == "__populate")) then return end
            return batch[1][2][1] -- network obj is now the serialized properties sent by server
        end
        -- client functions for event handling
        remoteEvent.OnClientEvent:Connect(function(objHash, batch)
            if batch[1] and batch[1][1] == "__populate" then processEvents = true end -- allow processing events after populate has been received
            if not processEvents then return end

            local networkedObj = instancedObjects[objHash] or getInitData(batch)

            if not networkedObj then print("bad batch:", batch) end
            assert(networkedObj ~= nil, "NetworkedObject: "..objHash..", does not exist")

            _handleNetworkEvents(networkedObj, batch)
        end)

        -- request server to populate
        remoteEvent:FireServer("__requestPopulate")
    end

    heartbeatConnection = RunService.Heartbeat:Connect(function(delta)
        debug.profilebegin("BaseNetworkedObject.Heartbeat")
        -- go through all objects and send batches if they are nonempty
        for hash, netObj in pairs(instancedObjects) do
            _sendBatchedEvents(netObj)

            if netObj._markForRemoval then
                -- finalize destruction
                instancedObjects[hash] = nil
                netObj._eventBatch = nil
                netObj._globalEventBatch = nil
                netObj._owner = nil
                setmetatable(netObj, nil)
                netObj._removed = true
                --print("object destroyed and dereferenced")
            end
        end

        if isServer then -- reset serialized objects every frame
            _serializedObjects = nil
        end
        debug.profileend()
    end)
end

function BaseNetworkedObject.__getReplicatedObject(hash)
    -- for client versions of server created objects that have already
    -- yield for a couple seconds if not initially there
    if not instancedObjects[hash] then
        -- wait until object exists
        local t = tick()
        local didWarn = false
        repeat 
            RunService.Heartbeat:Wait()
            if not didWarn and tick()-t > 1 then
                didWarn = true
                warn("BaseNetworkedObject.__init() | NetworkedObject -'"..hash.."' has not yet been replicated by the server, yielding until creation.")
            end
        until instancedObjects[hash]
    end
    return instancedObjects[hash]
end

function BaseNetworkedObject.__init(prototype, props, owner)
    assert(prototype ~= BaseNetworkedObject, "BaseNetworkedObject.__init() | Cannot instantiate abstract class: '"..prototype.__name.."'")
    if not isServer then
        assert(props ~= nil, "BaseNetworkedObject.__init() | initialization requires serialized properties from the Server.")
        if not props.replicated then
            return BaseNetworkedObject.__getReplicatedObject(props.id)
        end
    end
    props = props or {}
    local networkedObject = baseObject.__init(prototype, props)

    -- set member variables
    networkedObject._markForRemoval = false -- for removal when destroyed

    if owner then -- objects can be unowned, but clients cannot call methods on them (at least not through this class)
        assert(owner:IsA("Player"), "BaseNetworkedObject.__init() | owner must be a Player or nil.")
        networkedObject._ownerId = tostring(owner.UserId)
        networkedObject._owner = owner
    else
        local id = networkedObject._ownerId
        if id then
            -- get player from userId
            networkedObject._owner = PlayersService:GetPlayerByUserId(tonumber(id))
        end
    end

    networkedObject._eventBatch = {}
    if isServer then
        networkedObject._globalEventBatch = {}
    end

    instancedObjects[networkedObject._id] = networkedObject

    if isServer then
        -- send creation of object to clients
        networkedObject:_fireGlobalNetworkEvent("__init")
    end

    return networkedObject
end

function BaseNetworkedObject:Destroy()
    if isServer then
        -- fire clients
        self:_fireGlobalNetworkEvent("__destroy")
    end
    self._markForRemoval = true
end

-- protected
function BaseNetworkedObject:__serialize()
    -- uses a dictionary combiner to recursively serialize inherited member variables
    return cryo.Dictionary.join({
        -- add serializable properties here
        ownerId = self._ownerId
    }, baseObject.__serialize(self))
end

function BaseNetworkedObject:_fireNetworkEvent(event, ...) -- fire to owner client/server
    table.insert(self._eventBatch, {event, table.pack(...)})
end

function BaseNetworkedObject:_fireGlobalNetworkEvent(event, ...) -- fire to all clients
    assert(isServer, "BaseNetworkedObject._fireGlobalNetworkEvent() | must be called from the Server.")
    table.insert(self._globalEventBatch, {event, table.pack(...)})
end

-- public
function BaseNetworkedObject:SetOwner(player)
    assert(isServer, "BaseNetworkedObject.SetOwner() | must be called from the Server.")
    if player then
        assert(player:IsA("Player"), "BaseNetworkedObject.SetOwner() | must provide a Player instance or nil.")
    end
    self._ownerId = player and tostring(player.UserId) or nil
    self._owner = player
end


return BaseNetworkedObject