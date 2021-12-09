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
--used to display damage as billboard gui
local function displayDamage(targetChar, damage)
    local displayPart = Instance.new("Part") --part container
    displayPart.Anchored = true
    displayPart.Position = targetChar + Vector3.new(0,2,0)
    displayPart.Transparency = 1
    local billboard = Instance.new("BillboardGui") -- gui container
    billboard.Parent = displayPart
    billboard.Size = UDim2.fromOffset(100,100)
    local scoreText = Instance.new("TextLabel", billboard) -- gui texts
    scoreText.BackgroundTransparency = 1
    scoreText.Size = UDim2.fromScale(1,1)
    scoreText.TextColor3 = Color3.fromRGB(210, 255, 46) --different color than actual player damage display
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
    Debris:AddItem(displayPart, 1) -- clean up

end
-- this will set up NPCs to remove themselves from the cache after death(and remove their bodies)
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
-- get collision and apply damage
local function hitboxAttack(npc)
    local humanoid = NPCMemory[npc].Humanoid --get the humanoid of the enemy player
    local plr = npc -- npc is attacking like another player


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
            animationTrack:Play() -- play the stun animation
        end
        humanoid:TakeDamage(npc:GetAttribute("Damage")) -- apply damage based on npc model attribute
        displayDamage(NPCMemory[npc].PrimaryPart.Position, npc:GetAttribute("Damage")) --display npc damage as gui
        if humanoid.Health <= 0 then
            NPCMemory[npc] = nil
        end

    end
    
end
--create the attack animation for the npc in attack range
local function npcAttack(npc)
    if NPCMemory[npc] then --check the npcs memory to see if the enemy is alive.
        if NPCMemory[npc].Humanoid.Health <= 0 then --if dead, remove the player from the npcs memory and don't attack.
            NPCMemory[npc] = nil
            return
        end
    end
    npc:SetAttribute("LastAttack", tick()) --set the last attack time for cooldown calculation
    local comboCount = npc:GetAttribute("CurrentCombo") --get the npcs last attack state from model attribute
    --tick combo count
    npc:SetAttribute("CurrentCombo", comboCount+1) --tick the combo up in value.
    --check if combo exists in combo map
    if combo[comboCount] == nil then --if the combo doesn't exist reset the combo counter
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
    --call to calculate collision and damage
    hitboxAttack(npc)

end

return function(conditions)
    local lastTick = tick()
    --set up initial NPCS
    NPCCache = workspace.NPC:GetChildren()
    setupNPCS()
    --if new npcs are spawned then r
    NPC.ChildAdded:Connect(function()
        --run setup for new NPCS and reset caches
        for k, v in pairs(NPCMemory) do
            NPCMemory[k] = nil
        end
        NPCCache = workspace.NPC:GetChildren()
        setupNPCS()
    end)
    RunService.Heartbeat:Connect(function()
        if (tick() - lastTick) > conditions.updateTime then --tick AI service
            lastTick = tick()
            for index, npc in pairs(NPCCache) do --for every npc
                task.spawn(function() -- we will spawn a new thread for their behavior
                    if npc then --if the npc still exists
                        if NPCMemory[npc] == nil then -- check if it doesn't have a target in memory
                            --if no target then we will scan for a target with the collision system.
                            local collider = Instance.new("Part") --create a collider part to get collision
                            collider.Size = Vector3.new(20,5,20)
                            collider.Transparency = 1
                            collider.CFrame = npc.PrimaryPart.CFrame
                            collider.Parent = workspace
            
                            local parts = collider:GetTouchingParts()
                            collider:Destroy()
                            -- empty variable to catch if we have found a player
                            local player
                            for _, part in pairs(parts) do
                                if part.Parent and part.Parent:FindFirstChild("Humanoid") then
                                    if part.Parent == npc then -- ignore self
                                        continue
                                    elseif part.Parent:GetAttribute("IsEnemy") == true then --ignore other npcs
                                        continue
                                    else --found player
                                        player = part.Parent
                                        break
                                    end
                                end
                            end

                            if player and player.Humanoid.Health > 0 then -- npc found player
                           
                                NPCMemory[npc] = player -- save player to memory for optimization
                                local targetPosition = player.PrimaryPart.CFrame*CFrame.new(0,0,-1) --calculate target to be just infront of player(but not same position as player)
                                npc.Humanoid:MoveTo(targetPosition.Position)
                                --determine if in range and not cooldown
                                if (npc.PrimaryPart.Position - player.PrimaryPart.Position).Magnitude < 4 then 
                                    if (tick() - npc:GetAttribute("LastAttack")) > npc:GetAttribute("Cooldown") then 
                                        npcAttack(npc)--initiate npc attack
                                    end
                                end
                            end
                        else -- we have a player in npc memory
                            if NPCMemory[npc] then -- if the player character object still exists we will chase.
                                local targetPosition = NPCMemory[npc].PrimaryPart.CFrame*CFrame.new(0,0,-1.5)
                                npc.Humanoid:MoveTo(targetPosition.Position)
                                if (npc.PrimaryPart.Position - NPCMemory[npc].PrimaryPart.Position).Magnitude < 4 then
                                    if (tick() - npc:GetAttribute("LastAttack")) > npc:GetAttribute("Cooldown") then
                                        npcAttack(npc)
                                    end
                                end
                            else --player object probably died or got deleted somehow, remove from memory.
                                NPCMemory[npc] = nil
                            end
                        end
                    else-- somehow the npc doesn't exist, remove it from memory
                        NPCCache[index] = nil
                        NPCMemory[npc] = nil
                    end
                
                end)
            end
        end
    end)
end