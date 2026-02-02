local format = dofile_once( mod_path .. "files/format.lua" )

local module_path = module_path()

return function()
	if not mod_setting.get "damage_info" then return end
	-- GuiLayoutAddVerticalSpacing( gui, 360 * 0.05 )
	local x_pos = (pop.screen_size[ 1 ] + 4 * (20 + 2)) * 0.5

	local player_projectiles = EntityGetWithTag "spell_lab_shugged.player_projectile" or {}
	local total_projectile_damage = 0
	local total_projectiles = #player_projectiles
	for _, v in pairs( player_projectiles ) do
		local projectile = EntityGetFirstComponent( v, "ProjectileComponent" )
		if projectile then
			local damage = ComponentGetValue2( projectile, "damage" )
			total_projectile_damage = total_projectile_damage + math.max( damage, 0 )
		end
	end
	pop.pos.next( x_pos, 0 )
	pop.auto_layout_stack( pop.text_line_height, 0 )( function( options )
		pop.text( get_text "damage_info_total_projectile_damage" ..
			format.damage( total_projectile_damage, false, "inf" ) )
		pop.text( get_text "damage_info_total_projectiles_num" .. ("%d"):format( total_projectiles ) )
	end )
end
