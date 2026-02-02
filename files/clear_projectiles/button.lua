local module_path = this_folder()

local function silent_kill( proj_id )
	for _, proj_comp in ipairs( EntityGetComponentIncludingDisabled( proj_id, "ProjectileComponent" ) or {} ) do
		ComponentSetValue2( proj_comp, "on_death_explode", false )
		ComponentSetValue2( proj_comp, "on_lifetime_out_explode", false )
	end
	for _, expl_comp in ipairs( EntityGetComponentIncludingDisabled( proj_id, "ExplosionComponent" ) or {} ) do
		ComponentSetValue2( expl_comp, "trigger", "ON_CREATE" )
	end
	for _, litn_comp in ipairs( EntityGetComponentIncludingDisabled( proj_id, "LightningComponent" ) or {} ) do
		EntitySetComponentIsEnabled( proj_id, litn_comp, false )
	end
	EntityKill( proj_id )
end

return function()
	if pop.button( module_path .. "button.png" ) then
		sound_button_clicked()

		for _, proj_id in ipairs( EntityGetWithTag "projectile" or {} ) do
			silent_kill( proj_id )
		end
		for _, proj_id in ipairs( EntityGetWithTag "player_projectile" or {} ) do
			silent_kill( proj_id )
		end
	end
	pop.tooltip( wrap_key "clear_projectiles" )
end
