--[[
    This script is responsible for chatted commands
]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local commands = {}

function commands:init()

    local Prefix = "/" 
    
    game.Players.PlayerAdded:Connect(function(plr)

        plr.Chatted:Connect(function(msg)
     
            local loweredString = string.lower(msg)
            local args = string.split(loweredString," ")
            if args[1] == Prefix.."spawnenemy" then

                for i=1, args[2] do
                    local enemy = Assets.Enemies.Dummy:Clone()
                    local placementCFrame = plr.Character.PrimaryPart.CFrame * CFrame.new(0,3,4*(i+1))
                    enemy:SetPrimaryPartCFrame(placementCFrame)
                    enemy.Parent = workspace.NPC
                end
                
    
            end
        end)

    end)

end
return commands