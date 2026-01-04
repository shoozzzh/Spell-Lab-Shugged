if not ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then return end

local tag = "spell_lab_shugged.about_to_remove_toxic_status"

local entity_id = GetUpdatedEntityID()

if not EntityHasTag( entity_id, tag ) then
	ComponentSetValue2( GetUpdatedComponentID(), "mNextExecutionTime", GameGetFrameNum() )
	EntityAddTag( entity_id, tag )
	return
end

if not EntityHasTag( EntityGetParent( entity_id ), "player_unit" ) then return end

EntityRemoveFromParent( entity_id )
EntitySetTransform( entity_id, 14600, -8000 )
EntityApplyTransform( entity_id, 14600, -8000 )
EntityKill( entity_id )

EntityRemoveComponent( entity_id, GetUpdatedComponentID() )
