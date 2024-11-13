local entity_id = GetUpdatedEntityID()
if ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
	EntityRemoveFromParent( entity_id )
	EntitySetTransform( entity_id, 14600, -8000 )
	EntityApplyTransform( entity_id, 14600, -8000 )
	EntityKill( entity_id )
end