-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");

--networker
local Binding = Instance.new("BindableEvent", ReplicatedStorage.Events) -- this will be used between services.
Binding.Name = "Binding"
local BindingFunction = Instance.new("BindableFunction", ReplicatedStorage.Events)
BindingFunction.Name = "BindingFunction"
-- systems
local UIService = require(ReplicatedStorage.Services.UIService)()
local CombatService = require(ReplicatedStorage.Services.CombatService)()
local MarketService = require(ServerStorage.Services.MarketService)()
local AIService = require(ReplicatedStorage.Services.AIService)({updateTime = 0.1})
local Commands = require(ServerStorage.Modules.Commands)

Commands:init()



