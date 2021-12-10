--const
local COLLISION_DETECTION_SIZE = Vector3.new(5,5,5)

local collisionDetection = {}
--creates the actual collision box
local function createCollisionBox(collisionCFrame : CFrame, collisionDetectionSize : Vector3)
    local collider = Instance.new("Part") --create a collider part to get collision
    collider.Size = collisionDetectionSize or COLLISION_DETECTION_SIZE
    collider.Transparency = 1
    collider.CFrame = collisionCFrame
    collider.Parent = workspace
    return collider
end
-- scans the collision results, breaking the scan once a target is found.
function collisionDetection.getEnemyCollision(collisionIgnoreObject : Model, collisionCFrame : CFrame, collisionDetectionSize : Vector3)
    if collisionIgnoreObject == nil then 
        warn("The object being ignored in the collision does not exist, aborting collision")
        return 
    end
    if not(collisionCFrame) then
        collisionCFrame = collisionIgnoreObject.HumanoidRootPart and collisionIgnoreObject.HumanoidRootPart.CFrame
        warn("Collision CFrame not specified, this will result in unintended positioning of the collision.")
    end
    --get the collision
    local collider = createCollisionBox(collisionCFrame, collisionDetectionSize)
    local collisionResults = collider:GetTouchingParts()
    collider:Destroy()
   
    -- filter collisions for results
    for _, collision in pairs(collisionResults) do
        if collision.Parent and collision.Parent:FindFirstChild("Humanoid") then
            if collision.Parent == collisionIgnoreObject then -- ignore self
                continue
            elseif collisionIgnoreObject:GetAttribute("IsEnemy") and collision.Parent:GetAttribute("IsEnemy") == true then --ignore other npcs
                continue
            else --found player return that
                return collision.Parent
            end
        end
    end
    -- returns nil if no results
    return nil
end

return collisionDetection