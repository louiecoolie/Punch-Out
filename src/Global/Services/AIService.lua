--[[
    This service is a runtime service that will
    cycle through the AIs to issue updates.
]]
-- services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- modules
local collisionDetection = require(ReplicatedStorage.Modules.CollisionDetection)
local attackCreator = require(ReplicatedStorage.Modules.AttackCreator)
-- data
local NPCContainer = workspace.NPC
local NPCCache = {}
local NPCMemory = {}
--callback sent to clear dead player from npc memory
local function targetDeathCallback(npc)
    return function(npc)
        if NPCMemory[npc] then
			NPCMemory[npc] = nil
		end
    end
end
-- this will set up NPCs to remove themselves from the cache after death(and remove their bodies)
local function setupNPCS()
    task.spawn(function()
        for index, npc in pairs(NPCCache) do
            if not(npc.PrimaryPart) then
                npc.PrimaryPart = npc.HumanoidRootPart
            end
            npc.Humanoid.Died:Connect(function()
                NPCCache[index] = nil
                NPCMemory[npc] = nil
                npc:Destroy()
            end)
        end
    end)
end

local function moveNPC(npc, target)
    if target.PrimaryPart == nil then
        target.PrimaryPart = target.HumanoidRootPart
    end

    local targetPosition = target.PrimaryPart.CFrame*CFrame.new(0,0,-1.5) --calculate target to be just infront of player(but not same position as player)
    npc.Humanoid:MoveTo(targetPosition.Position)
end

local function checkAttackRange(npc, target)
    if target.PrimaryPart == nil then
        target.PrimaryPart = target.HumanoidRootPart
    end
    if (npc.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude < 4 then 
        if (tick() - npc:GetAttribute("LastAttack")) > npc:GetAttribute("Cooldown") then 
            -- run the attack
            attackCreator:Attack(npc, target, npc:GetAttribute("Damage"), targetDeathCallback(npc), Color3.fromRGB(210, 255, 46))
        end
    end
end

return function(conditions)
    local lastTick = tick()
    --set up initial NPCS
    NPCCache = workspace.NPC:GetChildren()
    setupNPCS()
    --if new npcs are spawned then run setup again
    NPCContainer.ChildAdded:Connect(function()
        --run setup for new NPCS and reset caches
        for k, v in pairs(NPCMemory) do
            NPCMemory[k] = nil
        end
        NPCCache = workspace.NPC:GetChildren()
        setupNPCS()
    end)
    --start the main thread for the animation system
    RunService.Heartbeat:Connect(function()
        if (tick() - lastTick) > conditions.updateTime then --tick AI service
            lastTick = tick()
            for index, npc in pairs(NPCCache) do --for every npc 
                task.spawn(function() -- we will spawn a new thread for their behavior
                    if npc == nil then -- if npc does not exist but is in memory, remove from memory and kill this thread.
                        NPCCache[index] = nil
                        NPCMemory[npc] = nil
                        return 
                    end 
              
                    if NPCMemory[npc] == nil then -- check if it doesn't have a target in memory
                        --if no target then we will scan for a target with the collision system.
                        local player = collisionDetection.getEnemyCollision(npc, npc.PrimaryPart.CFrame, Vector3.new(20,5,20))
                        if player == nil then return end --kill this thread if no results
                        if player and player.Humanoid.Health > 0 then -- npc found an alive player
                         
                            NPCMemory[npc] = player -- save player to memory for optimization
                            moveNPC(npc, player) --move npc toward player
                            checkAttackRange(npc, player)--determine if in range and not cooldown, attack if conditions met
                        end
                    else -- we have a player in npc memory
                        if NPCMemory[npc].Humanoid and NPCMemory[npc].Humanoid.Health <= 0 then -- check if player is dead
                            NPCMemory[npc] = nil
                            return
                        end
                        if NPCMemory[npc] then -- if the player character object still exists we will chase.
                            moveNPC(npc, NPCMemory[npc])
                            checkAttackRange(npc,NPCMemory[npc] )
                        end
                    end
                end)
            end
        end
    end)
end