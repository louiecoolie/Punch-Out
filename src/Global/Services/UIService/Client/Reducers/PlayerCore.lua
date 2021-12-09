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
    Profile = {
        coins = 0;
        power = 10;
        powerLevel = 1;
    };
    GameData = {
        Players = {};
    };
    Lobby = {
        currentOpen = "PLAY"
    };
    Settings = {
        Navigation = {
            tabRight = {Enum.KeyCode.A, Enum.KeyCode.ButtonR1};
            tabLeft = {Enum.KeyCode.D, Enum.KeyCode.ButtonL1};
        }
    };
    Shop = false;
    Theme = {
        Current = "darkTheme"
    };
    Active = false;
},{
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
    end,
    AddTeam = function(state, action)
        local newState = copy(state)
        newState.GameData = copy(state.GameData)

        newState.GameData.Players[#newState.GameData.Players+1] = action.player


    end;
    ToggleLobby = function(state, action)
        local newState = copy(state)

        newState.Lobby.currentOpen = action.toggleTo

        return newState

    end,

    

})
