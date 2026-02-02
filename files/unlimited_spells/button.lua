local module_path = this_folder()

return function()
	if not world_state_unlimited_spells then
		pop.option_next "DrawSemiTransparent"
	end
	if pop.button( module_path .. "button.png" ) then
		sound_button_clicked()
		if EntityGetIsAlive( world_state ) then
			local comp_worldstate = EntityGetFirstComponent( world_state, "WorldStateComponent" )
			ComponentSetValue2( comp_worldstate, "perk_infinite_spells", not world_state_unlimited_spells )
		end
		if not world_state_unlimited_spells then
			if not mod_setting.get "zero_uses" then
				GameRegenItemActionsInPlayer( player )
			end
			local inventory2 = EntityGetFirstComponent( player, "Inventory2Component" )
			if inventory2 ~= nil then
				ComponentSetValue2( inventory2, "mForceRefresh", true )
				ComponentSetValue2( inventory2, "mActualActiveItem", 0 )
			end
		end
	end
	pop.tooltip(
		get_text( world_state_unlimited_spells and "disable" or "enable" ) .. get_text "$perk_unlimited_spells" )
end
