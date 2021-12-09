local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

return rodux.createReducer({
    Profiles = {};
    GameData = {
        Players = {};
    }
},{
    Coins = function(state, action)
        local newState = copy(state)
        

        newState.Profiles[action.key].coins = action.value
        
        return newState
    end,
    Power = function(state, action)

        local newState = copy(state)

        newState.Profiles[action.key].power = action.power
        newState.Profiles[action.key].powerLevel = action.level;

        return newState
    end,
    Profile = function(state, action)
        local newState = copy(state) 

        newState.Profiles[action.key] = action.data
        
        return newState
    end,
    AddPlayer = function(state, action)
        local newState = copy(state)
        newState.GameData = copy(state.GameData)

        newState.GameData.Players[#newState.GameData.Players+1] = action.player


    end;
    

})
