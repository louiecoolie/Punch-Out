local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))

return rodux.combineReducers({
    playerHandler = require(script.Reducers.PlayerCore)
})
