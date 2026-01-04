GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spawn_target_dummy.png" )
do
	local snap_gird_size = 10
	local left_click,right_click,hover = previous_data( gui )
	if alt and hover then
		local x, y = get_player_or_camera_position()
		x = math.floor( x / snap_gird_size + 0.5 ) * snap_gird_size
		y = math.floor( y / snap_gird_size + 0.5 ) * snap_gird_size

		-- nolla why do you have to do this
		GameCreateSpriteForXFrames( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target.png", x, y, false, 14, 10.5, 2, true )
	end
	if left_click or right_click then
		local x, y = get_player_or_camera_position()
		if alt then
			x = math.floor( x / snap_gird_size + 0.5 ) * snap_gird_size
			y = math.floor( y / snap_gird_size + 0.5 ) * snap_gird_size
		end
		if left_click then
			EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target.xml", x, y )
		elseif right_click then
			EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target_final.xml", x, y )
		end
		sound_button_clicked()
	end
end
-- GuiTooltip( gui, wrap_key( "spawn_target_dummy" ), wrap_key( "spawn_target_dummy_description" ) )
do_custom_tooltip( function()
	GuiText( gui, 0, 0, wrap_key( "spawn_target_dummy" ) )
	GuiText( gui, 0, 0, wrap_key( "spawn_target_dummy_description" ) )
	GuiLayoutAddVerticalSpacing( gui, 6 )
	GuiText( gui, 0, 0, wrap_key( "target_dummy_numbers_are" ) )
	GuiColorSetForNextWidget( gui, color(0,207,40,255) )
	GuiText( gui, 0, 0, wrap_key( "target_dummy_last_frame_damage" ) )
	GuiColorSetForNextWidget( gui, color(208,208,248,255) )
	GuiText( gui, 0, 0, wrap_key( "target_dummy_average_dps" ) )
	GuiColorSetForNextWidget( gui, color(255,85,0,255) )
	GuiText( gui, 0, 0, wrap_key( "target_dummy_total_damage" ) )
	GuiColorSetForNextWidget( gui, color(208,208,248,255) )
	GuiText( gui, 0, 0, wrap_key( "target_dummy_dps" ) )
	GuiColorSetForNextWidget( gui, color(126,126,126,255) )
	GuiText( gui, 0, 0, wrap_key( "target_dummy_highest_dps" ) )
end, 3, 0, true )
