--This script is used to support the addition of multiple state reducers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))

return rodux.combineReducers({
    playerHandler = require(script.Reducers.PlayerCore)
})
