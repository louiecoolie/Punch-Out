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
--systems are structured in a way to help load them in a specific order to prevent issues from bad load order
local UIService = require(ReplicatedStorage.Services.UIService)() -- define ui server side
local CombatService = require(ReplicatedStorage.Services.CombatService)() -- define combat server side
local MarketService = require(ServerStorage.Services.MarketService)() -- used for the future if monetization is important
local AIService = require(ReplicatedStorage.Services.AIService)({updateTime = 0.1}) -- initiate the ai service with 0.1 tick time
local Commands = require(ServerStorage.Modules.Commands)() --initiate command listener



