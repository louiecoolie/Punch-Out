-- services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");
-- container to hold connections
local connections = {}

-- systems
local UIService = require(ReplicatedStorage.Services.UIService)()
local CombatService = require(ReplicatedStorage.Services.CombatService)()

UIService:LoadApp(game.Players.LocalPlayer.PlayerGui)

connections["InputBegan"] = UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        CombatService:Attack()
    end
end)