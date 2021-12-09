local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Rodux)

local module = {}

-- Action creator for the ReceivedNewPhoneNumber action


local function CreateServerState(serverName)
    return {
        type = "ServerStore",
        newServer = serverName

    }

end

local function CreatingNewStore(playerName)
    return {
        type = "PlayerStore",
        newStore = playerName
    }

end

local function TrackingNewPlayer(playerName)
    return {
        type = "TrackingNewPlayer",
        newPlayer = playerName
    }
end

local function CreatingNewMode(modeName)
    return {
        type ="ModeStore",
        newMode = modeName
    }
end


local storeReducer = Rodux.createReducer({},{
    PlayerStore = function(state, action)
        local newState = state


        --for player, table in ipairs(state) do

        --    newState[player] = table
      --  end

        --table.insert(newState, action.newPlayer[1], action.newPlayer[2])
        newState[action.newStore[1]] = action.newStore[2]

        return newState
    end,


})

local serverReducer = Rodux.createReducer({},{
    ServerStore = function(state, action)
        local newState = state


        --for player, table in ipairs(state) do

        --    newState[player] = table
      --  end

        --table.insert(newState, action.newPlayer[1], action.newPlayer[2])
        newState[action.newServer[1]] = action.newServer[2]

        return newState
    end,


})

local modeReducer = Rodux.createReducer({},{
    ModeStore = function(state, action)
        local newState = state


        --for player, table in ipairs(state) do

        --    newState[player] = table
      --  end

        --table.insert(newState, action.newPlayer[1], action.newPlayer[2])
        newState[action.newMode[1]] = action.newMode[2]

        return newState
    end,


})



local trackingReducer = Rodux.createReducer({},{
    TrackingNewPlayer = function(state, action)
        local newState = state


        --for player, table in ipairs(state) do

        --    newState[player] = table
      --  end

        --table.insert(newState, action.newPlayer[1], action.newPlayer[2])
        newState[action.newPlayer[1]] = action.newPlayer[2]

        return newState
    end,


})

local reducer = Rodux.combineReducers({
    trackers = trackingReducer,
    stores = storeReducer,
    modes = modeReducer,
    servers = serverReducer,
})

local store = Rodux.Store.new(reducer, nil, {
    --Rodux.loggerMiddleware,
})


function module.GetStore()
    return store:getState()
end

function module.TrackPlayer(player)
    store:dispatch(TrackingNewPlayer({player.Name,{
        run = false,
        runaim = false,
        aim = false,
        fire = false,
        swing = tick(),
        idle = false,
        block = false,
        type = "default",
        equip = false,
        attack = false,
        special = false,
        rig = false,
        combo = 1,
    }}))



end

function module.CreateMode(mode, settings)
    store:dispatch(CreatingNewMode({mode, settings}))

end

function module.CreateServer(serverName, state)
    store:dispatch(CreateServerState({serverName, state}))
end

function module.TrackDataStore(player)
    store:dispatch(CreatingNewStore({player.Name,{
        skin = "Meanie",
        hat = "Cap",
        toy = "BlarBox",
        taunt = "whatsup",
        kills = 0,
        attack = false,
    }}))
end

function module.UpdateDataStore(player, type, updateData)
    local player_state = store:getState().stores[player.Name]

    local newState = {}

    for stateType, value in pairs(player_state) do
        if stateType == type then
            newState[stateType] = updateData
        else
            newState[stateType] = value
        end
    end

end

function module.UpdateSkin(player, skin)
    local player_state = store:getState().stores[player.Name]

    local newState = {}

    for stateType, value in pairs(player_state) do
        if stateType == "skin" then
            newState[stateType] = skin
        else
            newState[stateType] = value
        end
    end

    store:dispatch(CreatingNewStore({player.Name, newState}))
end

function module.UpdateSetting(mode, setting, newValue)
    local player_state = store:getState().modes[mode]

    local newState = {}

    for stateType, value in pairs(player_state) do
        if stateType == setting then
            newState[stateType] = newValue
        else
            newState[stateType] = value
        end
    end

    store:dispatch(CreatingNewMode({mode, newState}))

end

function module.UpdateServer(server, state, newValue)
    local player_state = store:getState().servers[server]

    local newState = {}

    for stateType, value in pairs(player_state) do
        if stateType == state then
            newState[stateType] = newValue
        else
            newState[stateType] = false
        end
    end

    store:dispatch(CreateServerState({server, newState}))

end

function module.UpdateRig(player, rig)
    local player_state = store:getState().trackers[player.Name]

    local newState = {}

    for stateType, value in pairs(player_state) do

        if stateType == "rig" then
            if rig then
                newState[stateType] = rig
            else
                newState[stateType] = value
            end
        else
            newState[stateType] = value
        end

    end

    store:dispatch(TrackingNewPlayer({player.Name, newState}))

end
function module.UpdateTrack(player, state, type, equip, attack, combo)
    local player_state = store:getState().trackers[player.Name]

    local newState = {}

    for stateType, value in pairs(player_state) do
      
        if stateType == "type" then
           
            newState[stateType] = type
            continue
        end
        if stateType == "equip" then
            newState[stateType] = equip
            continue
        end

        if stateType == "rig" then
            newState[stateType] = value
            continue
        end

        if stateType == "combo" then
            if not(combo == nil) then
                newState[stateType] = combo
                continue
            else
                newState[stateType] = value
                continue
            end
        end

        if state == "attack" then
            if attack then
                newState[stateType] = attack
                continue
            else
                newState[stateType] = tick()
            end
        end

        if stateType == "swing" then
            if attack then
                newState[stateType] = attack
                continue
            else
                newState[stateType] = tick()
                continue
            end
        end

        if stateType == state then
            newState[stateType] = true
        else
            newState[stateType] = false
        end
    end

    store:dispatch(TrackingNewPlayer({player.Name, newState}))

end




return module