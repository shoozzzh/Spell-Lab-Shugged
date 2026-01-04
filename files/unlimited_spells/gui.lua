if not world_state_unlimited_spells then
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
end
if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/unlimited_spells.png" ) then
	sound_button_clicked()
	if EntityGetIsAlive( world_state ) then
		local comp_worldstate = EntityGetFirstComponent( world_state, "WorldStateComponent" )
		ComponentSetValue2( comp_worldstate, "perk_infinite_spells", not world_state_unlimited_spells )
	end
	if not world_state_unlimited_spells then
		if not mod_setting_get( "zero_uses" ) then
			GameRegenItemActionsInPlayer( player )
		end
		local inventory2 = EntityGetFirstComponent( player, "Inventory2Component" )
		if inventory2 ~= nil then
			ComponentSetValue2( inventory2, "mForceRefresh", true )
			ComponentSetValue2( inventory2, "mActualActiveItem", 0 )
		end
	end
end
GuiTooltip( gui, text_get_translated( world_state_unlimited_spells and "disable" or "enable" ) .. text_get_translated( "$perk_unlimited_spells" ), "" )
