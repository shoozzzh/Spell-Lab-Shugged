local module_path = this_folder()

return function()
	local left_click, right_click = pop.button( module_path .. "button.png" )
	do
		local snap_gird_size = 10
		if alt and pop.prev_hovered() then
			local x, y = get_player_or_camera_position()
			x = math.floor( x / snap_gird_size + 0.5 ) * snap_gird_size
			y = math.floor( y / snap_gird_size + 0.5 ) * snap_gird_size

			-- nolla why do you have to do this
			GameCreateSpriteForXFrames( module_path .. "dummy_target/dummy_target.png", x, y,
				false, 14, 10.5, 2, true )
		end
		if left_click or right_click then
			local x, y = get_player_or_camera_position()
			if alt then
				x = math.floor( x / snap_gird_size + 0.5 ) * snap_gird_size
				y = math.floor( y / snap_gird_size + 0.5 ) * snap_gird_size
			end
			if left_click then
				EntityLoad( module_path .. "dummy_target/dummy_target.xml", x, y )
			elseif right_click then
				EntityLoad( module_path .. "dummy_target/dummy_target_final.xml", x, y )
			end
			sound_button_clicked()
		end
	end
	pop.tooltip_custom( 3, 0, true )( function()
		pop.auto_layout_stack( 0, pop.text_line_height )( function( options )
			pop.text( wrap_key "spawn_target_dummy" )
			pop.text( wrap_key "spawn_target_dummy_description" )

			pop.pos.push( 0, 6 )

			pop.text( wrap_key "target_dummy_numbers_are" )
			pop.color_next( rgba( 0, 207, 40, 255 ) )
			pop.text( wrap_key "target_dummy_last_frame_damage" )
			pop.color_next( rgba( 208, 208, 248, 255 ) )
			pop.text( wrap_key "target_dummy_average_dps" )
			pop.color_next( rgba( 255, 85, 0, 255 ) )
			pop.text( wrap_key "target_dummy_total_damage" )
			pop.color_next( rgba( 208, 208, 248, 255 ) )
			pop.text( wrap_key "target_dummy_dps" )
			pop.color_next( rgba( 126, 126, 126, 255 ) )
			pop.text( wrap_key "target_dummy_highest_dps" )
		end )
	end )
end
