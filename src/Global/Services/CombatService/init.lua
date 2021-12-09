-- responsible for the combat of the game
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
-- modules
local util = ReplicatedStorage.Vendor
local class = require(util.LuaClass)
local baseSingleton = require(util.LuaClass:WaitForChild("BaseSingleton"))
local combo = require(script.Modules.Combo)
--class declaration
local CombatService, get, set = class("CombatService", baseSingleton)


-- this function creates a billboard gui that tweens up, it is supplied with damage dealt.
local function displayDamage(targetChar, damage)
    local displayPart = Instance.new("Part") -- create part container for billboard.
    displayPart.Anchored = true
    displayPart.Position = targetChar + Vector3.new(0,2,0)
    displayPart.Transparency = 1
    local billboard = Instance.new("BillboardGui") --create billboard to parent to part container
    billboard.Parent = displayPart
    billboard.Size = UDim2.fromOffset(100,100)
    local scoreText = Instance.new("TextLabel", billboard) -- create the text for billboard
    scoreText.BackgroundTransparency = 1
    scoreText.Size = UDim2.fromScale(1,1)
    scoreText.TextColor3 = Color3.fromRGB(175, 0, 0)
    scoreText.TextScaled = true
    scoreText.Font = Enum.Font.SourceSansBold
    scoreText.Text = "- "..damage
    displayPart.Parent = workspace  -- load into workspace
    --tween here
    local goal = {} 
    goal.Position = displayPart.Position + Vector3.new(0,3,0)
    local tweenInfo = TweenInfo.new(1)
    local tween = TweenService:Create(displayPart, tweenInfo, goal)
    tween:Play()
    Debris:AddItem(displayPart, 1) --clean up item after a second

end

function CombatService.__initSingleton(prototype) -- class initilaization
    local self = baseSingleton.__initSingleton(CombatService) -- get singleton by calling super init

    if  RunService:IsServer() then -- define server side of the class
        self._initiateAttack = Instance.new("RemoteEvent", script) -- creating an event to send attacks
        self._initiateAttack.Name = "InitiateAttack"
        self._damageMap = {} -- holds the power each player has for damage calculations
        self._binding = ReplicatedStorage.Events.Binding -- creating binding that commnicates data to other scripts
        self._bindingFunction = ReplicatedStorage.Events.BindingFunction -- used to pull data from other scripts
        self._initiateAttack.OnServerEvent:Connect(function(plr)
            if not self._damageMap[plr.Name] then -- if the damage isn't already mapped then get pull from state
                local data = self._bindingFunction:Invoke(plr) -- will send a request and the responsible script will return value
                self._damageMap[plr.Name] = data.power -- save that value so that we don't make too many binding event calls for simple combat
            end 
            --create a thread for the collision detection
            task.spawn(function() 
                local collider = Instance.new("Part") --create a collider part to get collision
                collider.Size = Vector3.new(5,5,2)
                collider.Transparency = 1
                collider.CFrame = plr.Character.PrimaryPart.CFrame*CFrame.new(0,0,-1) -- sets to in front of player
                collider.Parent = workspace

                local parts = collider:GetTouchingParts() -- get the collision
                collider:Destroy() -- destroy colllider as it is no longer needed
                local humanoid -- holding variable for getting humanoid of enemy
                for _, part in pairs(parts) do
                    if part.Parent and part.Parent:FindFirstChild("Humanoid") then
                        if part.Parent == plr.Character then -- we don't want the player to hit themselves
                            continue
                        else -- if not the player then we found an eligible humanoid.
                            humanoid = part.Parent.Humanoid
                            break
                        end
                    end
                end

                if humanoid then
                    --make the enemy look at the person who is damaging
                    humanoid.Parent:SetPrimaryPartCFrame(
                        CFrame.new(
                            humanoid.Parent.PrimaryPart.Position, 
                            Vector3.new(
                                plr.Character.PrimaryPart.Position.X,
                                humanoid.Parent.PrimaryPart.Position.Y,
                                plr.Character.PrimaryPart.Position.Z
                            )
                        )
                    )
                    --create a stun animation
                    local animation = Instance.new("Animation")
                    animation.AnimationId = "rbxassetid://8206374727"
                    local animator = humanoid:FindFirstChildOfClass("Animator")
                    if animator then
                        local animationTrack = animator:LoadAnimation(animation) -- load the animation
                        animationTrack:Play()
                    end
                    humanoid:TakeDamage(self._damageMap[plr.Name]) -- call damage on the humanoid
                    displayDamage(humanoid.Parent.PrimaryPart.Position, self._damageMap[plr.Name]) -- display the hit damage as gui
                    if humanoid.Health <= 0 then -- if the humanoid is dead, credit the player the score.
                        self._binding:Fire({
                            type = "kill";
                            player = plr;
                            coins = 10;
                        })
                    
                    end

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
    --tick combo count
    self._comboCount += 1
    --check if combo exists in combo map
    if combo[self._comboCount] == nil then
        self._comboCount = 0
    end
    --locate humanoid animator and run animation
	local humanoid = self._player.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		-- need to use animation object for server access
        local animation = Instance.new("Animation")
        animation.AnimationId = combo[self._comboCount]
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local animationTrack = animator:LoadAnimation(animation)
			animationTrack:Play()
		end
	end

    self._initiateAttack:FireServer()

end

return CombatService
