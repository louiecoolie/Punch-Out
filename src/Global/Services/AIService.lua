--[[
    This service is a runtime service that will
    cycle through the AIs to issue updates.
]]
-- services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
-- data
local NPC = workspace.NPC
local NPCCache = {}
local NPCMemory = {}
local combo = {
    [0] = "rbxassetid://8205848368";
    [1] = "rbxassetid://8205852213";
}

local function displayDamage(targetChar, damage)
    local displayPart = Instance.new("Part")
    displayPart.Anchored = true
    displayPart.Position = targetChar + Vector3.new(0,2,0)
    displayPart.Transparency = 1
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = displayPart
    billboard.Size = UDim2.fromOffset(100,100)
    local scoreText = Instance.new("TextLabel", billboard)
    scoreText.BackgroundTransparency = 1
    scoreText.Size = UDim2.fromScale(1,1)
    scoreText.TextColor3 = Color3.fromRGB(210, 255, 46)
    scoreText.TextScaled = true
    scoreText.Font = Enum.Font.SourceSansBold
    scoreText.Text = "- "..damage
    displayPart.Parent = workspace

    local goal = {}
    goal.Position = displayPart.Position + Vector3.new(0,3,0)
    local tweenInfo = TweenInfo.new(1)
    local tween = TweenService:Create(displayPart, tweenInfo, goal)
    tween:Play()
    Debris:AddItem(displayPart, 1)

end

local function setupNPCS()
    task.spawn(function()
        for index, npc in pairs(NPCCache) do
            npc.Humanoid.Died:Connect(function()
                NPCCache[index] = nil
                NPCMemory[npc] = nil
                npc:Destroy()
            end)
        end
    end)
end

local function hitboxAttack(npc)
    local humanoid = NPCMemory[npc].Humanoid
    local plr = npc


    if humanoid and humanoid.Health > 0 then
        --make the enemy look at the person who is damaging
        humanoid.Parent:SetPrimaryPartCFrame(
            CFrame.new(
                humanoid.Parent.PrimaryPart.Position, 
                Vector3.new(
                    plr.PrimaryPart.Position.X,
                    humanoid.Parent.PrimaryPart.Position.Y,
                    plr.PrimaryPart.Position.Z
                )
            )
        )
        --create a stun animation
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://8206374727"
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local animationTrack = animator:LoadAnimation(animation)
            animationTrack:Play()
        end
        humanoid:TakeDamage(npc:GetAttribute("Damage"))
        displayDamage(NPCMemory[npc].PrimaryPart.Position, npc:GetAttribute("Damage"))
        if humanoid.Health <= 0 then
            NPCMemory[npc] = nil
        end

    end
    
end

local function npcAttack(npc)
        if NPCMemory[npc] then
            if NPCMemory[npc].Humanoid.Health <= 0 then
                NPCMemory[npc] = nil
                return
            end
        end
        npc:SetAttribute("LastAttack", tick())
        local comboCount = npc:GetAttribute("CurrentCombo")
        --tick combo count
        npc:SetAttribute("CurrentCombo", comboCount+1)
        --check if combo exists in combo map
        if combo[comboCount] == nil then
            npc:SetAttribute("CurrentCombo", 0)
            comboCount = npc:GetAttribute("CurrentCombo")
        end
   
        --locate humanoid animator and run animation
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
     
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
    
        hitboxAttack(npc)
    
    end

return function(conditions)
    local lastTick = tick()
    --set up initial NPCS
    NPCCache = workspace.NPC:GetChildren()
    setupNPCS()
    NPC.ChildAdded:Connect(function()
        --run setup for new NPCS
        NPCCache = workspace.NPC:GetChildren()
        setupNPCS()
    end)
    RunService.Heartbeat:Connect(function()
        if (tick() - lastTick) > conditions.updateTime then
            lastTick = tick()
            for index, npc in pairs(NPCCache) do
                task.spawn(function()
                    if npc then
                        if NPCMemory[npc] == nil then
                            local collider = Instance.new("Part") --create a collider part to get collision
                            collider.Size = Vector3.new(20,5,20)
                            collider.Transparency = 1
                            collider.CFrame = npc.PrimaryPart.CFrame
                            collider.Parent = workspace
            
                            local parts = collider:GetTouchingParts()
                            collider:Destroy()
                            local player
                            for _, part in pairs(parts) do
                                if part.Parent and part.Parent:FindFirstChild("Humanoid") then
                                    if part.Parent == npc then
                                        continue
                                    elseif part.Parent:GetAttribute("IsEnemy") == true then
                                        continue
                                    else
                                        player = part.Parent
                                        break
                                    end
                                end
                            end

                            if player and player.Humanoid.Health > 0 then -- npc found player
                           
                                NPCMemory[npc] = player -- save player to memory for optimization
                                local targetPosition = player.PrimaryPart.CFrame*CFrame.new(0,0,-1)
                                npc.Humanoid:MoveTo(targetPosition.Position)
                                --determine if in range and not cooldown
                                if (npc.PrimaryPart.Position - player.PrimaryPart.Position).Magnitude < 4 then 
                                    if (tick() - npc:GetAttribute("LastAttack")) > npc:GetAttribute("Cooldown") then
                                        npcAttack(npc)
                                    end
                                end
                            end
                        else
                            if NPCMemory[npc] then
                                local targetPosition = NPCMemory[npc].PrimaryPart.CFrame*CFrame.new(0,0,-1.5)
                                npc.Humanoid:MoveTo(targetPosition.Position)
                                if (npc.PrimaryPart.Position - NPCMemory[npc].PrimaryPart.Position).Magnitude < 4 then
                                    if (tick() - npc:GetAttribute("LastAttack")) > npc:GetAttribute("Cooldown") then
                                        npcAttack(npc)
                                    end
                                end
                            else
                                NPCMemory[npc] = nil
                            end
                        end
                    else
                        NPCCache[index] = nil
                        NPCMemory[npc] = nil
                    end
                
                end)
            end
        end

    end)
end




 