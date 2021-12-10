--Services
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
--const
local DAMAGE = 2
local ATTACK_COLOR = Color3.new(200,0,0)
local FIRST_COMBO = 0
local COMBO_SCHEME = {
    [0] = "rbxassetid://8205848368";
    [1] = "rbxassetid://8205852213";
}

local attackCreator = {}
-- create damage gui
function attackCreator.createDamageGui(target : Model, attackColor : Color3, damageDealt : number)
    if target.PrimaryPart == nil then
        target.PrimaryPart = target.HumanoidRootPart
    end

    local targetPosition = target.PrimaryPart.Position
    local color = attackColor or ATTACK_COLOR 
    local damage = damageDealt or DAMAGE
    --part container
    local displayPart = Instance.new("Part") 
    displayPart.Anchored = true
    displayPart.Position = targetPosition + Vector3.new(0,2,0)
    displayPart.Transparency = 1
    -- gui container
    local billboard = Instance.new("BillboardGui") 
    billboard.Parent = displayPart
    billboard.Size = UDim2.fromOffset(100,100)
    local scoreText = Instance.new("TextLabel", billboard) -- gui texts
    scoreText.BackgroundTransparency = 1
    scoreText.Size = UDim2.fromScale(1,1)
    scoreText.TextColor3 = color--different color than actual player damage display
    scoreText.TextScaled = true
    scoreText.Font = Enum.Font.SourceSansBold
    scoreText.Text = "- "..damage
    displayPart.Parent = workspace
    --create tween up
    local goal = {}
    goal.Position = displayPart.Position + Vector3.new(0,3,0)
    local tweenInfo = TweenInfo.new(1)
    local tween = TweenService:Create(displayPart, tweenInfo, goal)
    tween:Play()
    -- clean up
    Debris:AddItem(displayPart, 1)
    
end
-- deals damage to target humanoid and calls death function if death detected
function attackCreator.dealDamage(damageDealer : Model, target : Model, damageDealt : number, deathCallback)
    if target.Humanoid == nil then
        warn("This target does not have a humanoid, abort damage")
        return
    end
    if damageDealer.PrimaryPart == nil then
        damageDealer.PrimaryPart = damageDealer.HumanoidRootPart
    end
    if target.PrimaryPart == nil then
        target.PrimaryPart = target.HumanoidRootPart
    end

    local damage = damageDealt or DAMAGE
    local targetHumanoid = target.Humanoid --get the humanoid of the target player
    local dealer = damageDealer 

    if targetHumanoid and targetHumanoid.Health > 0 then
        --make the target look at the person who is damaging
        targetHumanoid.Parent:SetPrimaryPartCFrame(
            CFrame.new(
                targetHumanoid.Parent.PrimaryPart.Position, 
                Vector3.new(
                    dealer.PrimaryPart.Position.X,
                    targetHumanoid.Parent.PrimaryPart.Position.Y,
                    dealer.PrimaryPart.Position.Z
                )
            )
        )
        --create a stun animation
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://8206374727"
        local animator = targetHumanoid:FindFirstChildOfClass("Animator")
        if animator then
            local animationTrack = animator:LoadAnimation(animation)
            animationTrack:Play() -- play the stun animation
        end
        targetHumanoid:TakeDamage(damage) -- apply damage based on npc model attribute
 
        if targetHumanoid.Health <= 0 then
            deathCallback()
        end

    end
    
end
--takes in a combo scheme and iterates through the combos based on stored combo attribute
function attackCreator.animateAttack(damageDealer : Model, comboScheme : table)
    if damageDealer == nil then
        return 
    end
    
    local combo = comboScheme or COMBO_SCHEME
    --get the npc or player last attack state from model attribute
    local comboCount = damageDealer:GetAttribute("CurrentCombo") 
    --if not one set then assign default combo position
    if comboCount == nil then
        damageDealer:SetAttribute("CurrentCombo", FIRST_COMBO)
        comboCount = FIRST_COMBO
    end
    --set the last attack time for cooldown calculation for npc types
    if damageDealer:GetAttribute("IsEnemy") then
        damageDealer:SetAttribute("LastAttack", tick()) 
    end
     --if the combo doesn't exist reset the combo counter
    if combo[comboCount] == nil then
        damageDealer:SetAttribute("CurrentCombo", FIRST_COMBO)
        comboCount = FIRST_COMBO
    end
    --locate humanoid animator and run animation
    local humanoid = damageDealer:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        -- need to use animation object for server access
        local animation = Instance.new("Animation")
        animation.AnimationId = combo[comboCount]
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local animationTrack = animator:LoadAnimation(animation)
            animationTrack:Play()
        end
    end
    --tick the combo up in value.
    damageDealer:SetAttribute("CurrentCombo", comboCount+1) 
end
-- this function is used by the AI system, while the functions themselves are broken apart for the client/server to call them appropriately for players
function attackCreator:Attack(damageDealer : Model, target : Model, damageDealt : number, deathCallback, attackColor : Color3, comboScheme : table)
    if damageDealer == nil then return end
    if target == nil then return end

    self.animateAttack(damageDealer, comboScheme)
    self.dealDamage(damageDealer, target, damageDealt, deathCallback)
    self.createDamageGui(target, attackColor, damageDealt)
end

return attackCreator