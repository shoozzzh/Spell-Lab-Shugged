local controls_freezer = {}

function controls_freezer.freeze()
	for _, player in ipairs( EntityGetWithTag( "player_unit" ) or {} ) do
		local controls_disabler = EntityCreateNew()
		EntityAddTag( controls_disabler, "spell_lab_shugged_controls_disabler" )
		EntityAddTag( controls_disabler, "spell_lab_shugged_non_toxic_status" )
		EntityAddChild( player, controls_disabler )
		EntityAddComponent2( controls_disabler, "InheritTransformComponent" )
		EntityAddComponent2( controls_disabler, "GameEffectComponent", {
			frames = -1,
			disable_movement = true,
			effect = "FROZEN",
		} )
	end
end

function controls_freezer.unfreeze()
	for _, controls_disabler in ipairs( EntityGetWithTag( "spell_lab_shugged_controls_disabler" ) ) do
		local effect_comp = EntityGetFirstComponentIncludingDisabled( controls_disabler, "GameEffectComponent" )
		ComponentSetValue2( effect_comp, "frames", 1 )
	end
end

return controls_freezer