local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local util = ReplicatedStorage.Vendor
local rodux = require(util:WaitForChild("Rodux"))

return rodux.combineReducers({
    Server = require(script.Reducers.PlayerCore)
})