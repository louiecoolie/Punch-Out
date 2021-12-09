-- services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- container to hold connections
local connections = {}
-- systems
--initializing client side of the ui system
local UIService = require(ReplicatedStorage.Services.UIService)()
--initiliaizing client side of the combat system.
local CombatService = require(ReplicatedStorage.Services.CombatService)()

UIService:LoadApp(game.Players.LocalPlayer.PlayerGui) -- this mounts the ui to the players PlayerGui

connections["InputBegan"] = UserInputService.InputBegan:Connect(function(input)
    --get mouse or touch input
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        CombatService:Attack() --makes combat service do a combat call
    end
end)

