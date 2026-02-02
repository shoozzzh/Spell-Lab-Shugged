local module_path = this_folder()

return function()
	if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) == "0" then
		pop.option_next "DrawSemiTransparent"
	end
	pop.button( module_path .. "button.png" )

	do
		local left_click, right_click = pop.prev_clicked()
		if left_click then
			sound_button_clicked()
			if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) == "0" then
				local px, py = EntityGetTransform( player )
				GlobalsSetValue( "spell_lab_shugged_checkpoint_x", ("%.0f"):format( px ) )
				GlobalsSetValue( "spell_lab_shugged_checkpoint_y", ("%.0f"):format( py ) )
				EntityApplyTransform( player, 14600, -6050 )
				GameSetCameraPos( 14600, -6050 )
			else
				if not shift then
					local cx = tonumber( GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) )
					local cy = tonumber( GlobalsGetValue( "spell_lab_shugged_checkpoint_y", "0" ) ) - 10
					EntityApplyTransform( player, cx, cy )
					GameSetCameraPos( cx, cy )
				else
					EntityApplyTransform( player, 250, -100 )
					GameSetCameraPos( 250, -100 )
				end
				GlobalsSetValue( "spell_lab_shugged_checkpoint_x", "0" )
				GlobalsSetValue( "spell_lab_shugged_checkpoint_y", "0" )
			end
		elseif right_click then
			if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) ~= "0" then
				sound_button_clicked()
				EntityLoad( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
			end
		end
	end
	if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) == "0" then
		pop.tooltip( wrap_key( "enter_spell_lab" ) )
	else
		pop.tooltip( wrap_key( "leave_spell_lab" ), wrap_key( "reload_spell_lab" ) )
	end
end
