if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wand.png" ) then
	if held_wand then
		sound_button_clicked()
		WANDS.wand_clear_actions( held_wand )
	end
end
GuiTooltip( gui, wrap_key( "clear_held_wand" ), "" )
