--[[
    This script is responsible for chatted commands
]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

return function()
    local Prefix = "/" 
    
    game.Players.PlayerAdded:Connect(function(plr)
        plr.Chatted:Connect(function(msg)
            local loweredString = string.lower(msg)
            local args = string.split(loweredString," ")--split the chatted message to scan from required elements
            if args[1] == Prefix.."spawnenemy" then  --if the chat resembles this command then do this command
                for i=1, args[2] do -- for the count specified create npc clones
                    local enemy = Assets.Enemies.Dummy:Clone() --support can be added to do different enemies but this only has 1 enemy
                    local placementCFrame = plr.Character.PrimaryPart.CFrame * CFrame.new(0,3,4*(i+1))
                    enemy:SetPrimaryPartCFrame(placementCFrame)
                    enemy.Parent = workspace.NPC
                end
            end
        end)
    end)
end
