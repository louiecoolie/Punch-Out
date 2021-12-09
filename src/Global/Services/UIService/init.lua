-- responsible for general ui of the game
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
-- modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))
local roactRodux = require(util:WaitForChild("Roact-Rodux"))
local roact = require(util:WaitForChild("Roact"))
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))
--class declaration
local UIService, get, set = class("UIService", baseSingleton)
--reducers
local server = require(script.Server)
local client = require(script.Client)
local baseApp = script.BaseApp

local function calculateCost(powerLevel)
    local result = (0.2*math.exp(powerLevel)) * 10
    return math.floor(result)
end

local function calculatePower(powerLevel)
    local result = (0.37*math.exp(powerLevel)) * 10
    return math.floor(result)
end
function UIService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(UIService) -- get singleton by calling super init

    if  RunService:IsServer() then -- define server side of the class
        local result, response = pcall(DataStoreService.GetDataStore, DataStoreService, "PUNCHDS")
        self._datastore = result and response or false
        self._binding = ReplicatedStorage.Events:WaitForChild("Binding") -- used to communicate between scripts
        self._updateServer = Instance.new("RemoteEvent", script) -- receives updates external to the service
        self._dispatchClient = Instance.new("RemoteEvent", script) -- dispatches updates internal to the service.
        self._updateServer.Name = "updateServer"
        self._dispatchClient.Name = "dispatchClient"
        self._playerStores = {}
        self._serverStore = rodux.Store.new(server, {}, {
            --rodux.thunkMiddleware
        })

        -- set up connection that will communicate updates to the server
        self._updateServer.OnServerEvent:Connect(function(player, data)
            if data.type == "PurchasePower" then
        
                local state = self._serverStore:getState() -- pull state 
               
                local coins = state.Server.Profiles[player.Name].coins -- get clients points from state.
                local powerLevel = state.Server.Profiles[player.Name].powerLevel
                local nextLevelCost = calculateCost(powerLevel+1)
                if coins >= nextLevelCost then
                    coins -= nextLevelCost

                    self._serverStore:dispatch({
                        type = "Coins";
                        key = player.Name;
                        value = coins;
                    })

                    self._serverStore:dispatch({
                        type = "Power";
                        key = player.Name;
                        level = powerLevel + 1;
                        power = calculatePower(powerLevel+1)
                    })
                    self._binding:Fire({
                        type = "upgrade";
                        player = player.Name;
                        upgrade = calculatePower(powerLevel+1);
                    })
                    self._dispatchClient:FireClient(player, {
                        type = "Coins",
                        value = coins
                    })

                    self._dispatchClient:FireClient(player, {
                        type = "Power";
                        level = powerLevel + 1;
                        power = calculatePower(powerLevel+1)
                    })
                end
            elseif data.type == "Shop" then -- toggle the shop for client if requested
                self._dispatchClient:FireClient(player, {
                    type = "Shop"
                })
            end
        end)

        game.Players.PlayerAdded:Connect(function(player)

            self._serverStore:dispatch({
                type = "AddPlayer";
                player = player.UserId;
            })

            self._dispatchClient:FireClient(player, {
                type = "AddPlayer";
                player = player.UserId;
            })

            local success, store = pcall(function()
                return  self._datastore:GetAsync(player.UserId)
            end)

            if success and store then

                self._serverStore:dispatch({
                    type = "Profile";
                    key = player.Name;
                    data = store;
                })

                self._dispatchClient:FireClient(player, {
                    type = "Profile";
                    data = store;
                })
            else
           
                self._serverStore:dispatch({
                    type = "Profile";
                    key = player.Name;
                    data = {
                        coins = 0;
                        power = 10;
                        powerLevel = 1;
                    };
                })
                self._dispatchClient:FireClient(player, {
                    type = "Profile";
                    data = {
                        coins = 0;
                        power = 10;
                        powerLevel = 1;
                    };
                })
            end
        
        
        end)
        
        game.Players.PlayerRemoving:Connect(function(player)
            local state = self._serverStore:getState() 
            local success, errorMessage = pcall(function()
                self._datastore:SetAsync(player.UserId, state.Server.Profiles[player.Name])
            end)
        
        end)

        ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
       
            self._dispatchClient:FireClient(player, {
                type = "Shop"
            })
        
        end)

        ReplicatedStorage.Events:WaitForChild("BindingFunction").OnInvoke = function(player)
            local state = self._serverStore:getState() 
            return state.Server.Profiles[player.Name]
        end
        self._binding.Event:Connect(function(data)
            if data.type == "kill" then
                local state = self._serverStore:getState() -- pull state 
           
                local coins = state.Server.Profiles[data.player.Name].coins -- get clients points from state.

                coins += data.coins

                if coins < 0 then
                    coins = 0   -- ensure we do not have negative points
                end

                self._serverStore:dispatch({
                    type = "Coins";
                    key = data.player.Name;
                    value = coins;
                })

                self._dispatchClient:FireClient(data.player, {
                    type = "Coins",
                    value = coins
                })
            end
        end)
    else -- start defining client side of class
        self._initialized = false
        self._uiHandle = ""; -- set it to an empty string for now
        self._dispatchClient = script:WaitForChild("dispatchClient")
        self._updateServer = script:WaitForChild("updateServer")
        self._clientStore = rodux.Store.new(client, {}, {
            rodux.thunkMiddleware
        })
        self._clientApp = roact.createElement(roactRodux.StoreProvider, {
            store = self._clientStore
        }, {
            App = roact.createElement(require(script.BaseApp),{
                serverDispatch = self._updateServer
            })
        })


        self._dispatchClient.OnClientEvent:Connect(function(data)
      
            self._clientStore:dispatch(data)
        
        end)

        self._initialized = true

    end

    return self
end



-- server methods

function UIService:DispatchToClient(player, dispatch)
    self._remoteEvent:FireClient(player, dispatch)

end

function UIService:ToggleUI(player, toggle)
    self._toggleEvent:FireClient(player, toggle)

end

-- client methods


function UIService:LoadApp(playerGui)
 
        if self._initialized then
    
            self._uiHandle = roact.mount(self._clientApp, playerGui, "LobbyApp")
        else
            task.defer(function()
                while not(self._initialized) do
                    tick()
                end
                
                self._uiHandle = roact.mount(self._clientApp, playerGui, "LobbyApp")
            end)
        end
           
   


end

function UIService:Unmount()
    roact.unmount(self._uiHandle)
    self._uiHandle = nil

end

return UIService
