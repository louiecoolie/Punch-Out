-- responsible for the combat of the game
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
-- modules
local util = ReplicatedStorage.Vendor
local collisionDetection = require(ReplicatedStorage.Modules.CollisionDetection)
local attackCreator = require(ReplicatedStorage.Modules.AttackCreator)
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))
local combo = require(script.Modules.Combo)
--class declaration
local CombatService, get, set = class("CombatService", baseSingleton)

function CombatService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(CombatService) -- get singleton by calling super init

    if  RunService:IsServer() then -- define server side of the class
        self._initiateAttack = Instance.new("RemoteEvent", script) -- creating an event to send attacks
        self._initiateAttack.Name = "InitiateAttack"

        self._binding = ReplicatedStorage.Events.Binding -- creating binding that commnicates data to other scripts
        self._bindingFunction = ReplicatedStorage.Events.BindingFunction -- used to pull data from other scripts

        self._damageMap = {} -- holds the power each player has for damage calculations

        self._initiateAttack.OnServerEvent:Connect(function(plr)
            if not self._damageMap[plr.Name] then -- if the damage isn't already mapped then get pull from state
                local data = self._bindingFunction:Invoke(plr) -- will send a request and the responsible script will return value
                self._damageMap[plr.Name] = data.power -- save that value so that we don't make too many binding event calls for simple combat
            end 
            --create a thread for the collision detection and attack
            task.spawn(function() 
                local target = collisionDetection.getEnemyCollision(plr.Character, plr.Character.PrimaryPart.CFrame*CFrame.new(0,0,-1), Vector3.new(5,5,2))
                if target == nil then return end
     
                if target then
                    attackCreator.dealDamage(
                        plr.Character,
                        target,
                        self._damageMap[plr.Name],
                        function() self._binding:Fire({
                            type = "kill";
                            player = plr;
                            coins = 10;
                        })
                        end
                    )
   
                    attackCreator.createDamageGui(target, Color3.fromRGB(220,0,0),self._damageMap[plr.Name])
                end
            end)
        end)

        self._binding.Event:Connect(function(data)
            if data.type == "upgrade" then -- update damage map if player upgrades
                self._damageMap[data.player] = data.upgrade --store updated damage into cache
            end
        end)
    else -- start defining client side of class
        self._initialized = false
        self._comboCount = 0 -- creating combo count variable to count combos
        self._lastCombo = tick() -- will be used to determine combo used
        self._player = Players.LocalPlayer -- making a reference to the player object as that is always available.
        self._initiateAttack = script.InitiateAttack -- get the remote event used for this service to communicate between server-client
        self._initialized = true
    end

    return self
end
--responsible for animating the attack and calling server to calculate collision and damage
function CombatService:Attack()
    --call animation on attack
    attackCreator.animateAttack(self._player.Character, combo)
    --send server request to do damage
    self._initiateAttack:FireServer()
end

return CombatService
