dofile_once "mods/spell_lab_shugged/files/misc_utils.lua"

local module_path = module_path()
dofile_once( module_path .. "utils.lua" )

function damage_received( damage, message, entity_thats_responsible, is_fatal )
	local entity_id = GetUpdatedEntityID()
	local now = GameGetFrameNum()

	local vars = access_vars( entity_id )

	local damage_model = EntityGetFirstComponent( entity_id, "DamageModelComponent" )
	if damage_model then
		ComponentSetValue2( damage_model, "max_hp", 4 )
		ComponentSetValue2( damage_model, "hp", math.max( 4, damage * 1.1 ) )
	end

	local last_hit_frame = vars.last_hit_frame
	vars.last_hit_frame = now
	local reset = (now - last_hit_frame > 180)

	local first_hit_frame
	if reset then
		vars.first_hit_frame = now
		first_hit_frame = now
	else
		first_hit_frame = vars.first_hit_frame
	end

	vars.current_dps = vars.current_dps + damage

	if vars.current_dps > (reset and 0 or vars.highest_dps_comp) then
		vars.highest_dps_comp = vars.current_dps
	end

	vars.total_damage = (reset and 0 or vars.total_damage) + damage

	local average_dps = vars.total_damage / (now - first_hit_frame + 1) * 60

	vars.this_frame_damage = (last_hit_frame == now and vars.this_frame_damage or 0) + damage

	local child_id = EntityGetAllChildren( entity_id, "dummy_target_child" )[ 1 ]
	if not EntityGetIsAlive( child_id ) then return end

	set_text( child_id, "total_damage", vars.total_damage )
	set_text( child_id, "average_dps", average_dps )
	set_text( child_id, "last_frame_damage", vars.this_frame_damage )

	EntitySetComponentsWithTagEnabled( child_id, "invincible", true )
end
