if not ModSettingGet "%MODULE_FULL_ID%.enabled" then return end

local tag = "%MODULE_FULL_ID%.about_to_self_remove"

local entity_id = GetUpdatedEntityID()

if not EntityHasTag(entity_id, tag) then
    ComponentSetValue2(GetUpdatedComponentID(), "mNextExecutionTime", GameGetFrameNum())
    EntityAddTag(entity_id, tag)
    return
end

if not EntityHasTag(EntityGetParent(entity_id), "player_unit") then return end

EntityRemoveFromParent(entity_id)
EntitySetTransform(entity_id, 14600, -8000)
EntityApplyTransform(entity_id, 14600, -8000)
EntityKill(entity_id)

EntityRemoveComponent(entity_id, GetUpdatedComponentID())
