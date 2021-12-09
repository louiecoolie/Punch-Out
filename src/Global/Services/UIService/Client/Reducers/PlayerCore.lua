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
--[[
    Profile: Initial state for a profile if the server doesn't provide information or new player
    GameData: used to show the data of other players if needed
    Shop: state to toggle shop visibility
    Theme: theme of the app  
]]--
return rodux.createReducer({
    Profile = {
        coins = 0;
        power = 10;
        powerLevel = 1;
    };
    GameData = {
        Players = {};
    };
    Shop = false;
    Theme = {
        Current = "darkTheme"
    };
},{
    --[[
        Coins:  action to update coin count
        Power: action to update power count and level
        Profile: action to receive profile sent from server
        Shop: action to toggle shop
    ]]--
    Coins = function(state, action)
        local newState = copy(state)
      
        newState.Profile.coins = action.value
        
        return newState
    end,
    Power = function(state, action)

        local newState = copy(state)

        newState.Profile.power = action.power
        newState.Profile.powerLevel = action.level;

        return newState
    end,
    Profile = function(state, action)
        local newState = copy(state) 

        newState.Profile = action.data
        
        return newState
    end,
    Shop = function(state, action)
        local newState = copy(state)
    
        newState.Shop = not(state.Shop)
        
        return newState
    end
})
