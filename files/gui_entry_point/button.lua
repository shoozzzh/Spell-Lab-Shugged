local module_path = module_path()

local button_image = module_path .. "button.png"
local button_width, button_height = get_image_size( button_image )
local button_x, button_y, dragging, last_dragging

return function()
	if not button_x then
		button_x = tonumber( mod_setting.get "gui_entry_point_x" ) or (pop.screen_size[ 1 ] - button_width - 3)
		button_y = tonumber( mod_setting.get "gui_entry_point_y" ) or 3
	end

	pop.pos.next( button_x, button_y )
	button_x, button_y, dragging = pop.draggable_space( button_width, button_height, true )
	if last_dragging and not dragging then
		mod_setting.set( "gui_entry_point_x", button_x )
		mod_setting.set( "gui_entry_point_y", button_y )
	end
	last_dragging = dragging

	pop.pos.next( button_x, button_y )
	if pop.button( button_image ) and not dragging then
		sound_button_clicked()
		is_panel_open = not is_panel_open
	end

	if dragging then return end

	pop.tooltip_custom( 3, 10, true )( function()
		pop.auto_layout_stack( 0, pop.text_line_height )( function()
			pop.z_mod( -100 )

			pop.text( wrap_key( (is_panel_open and "hide" or "show") .. "_spell_lab" ) )

			pop.color_next( TextColors.Grey )
			pop.text( mod_version )

			pop.color_next( TextColors.Grey )
			pop.text( wrap_key "entry_point_desc" )

			pop.z_mod( 100 )
		end )
	end )
end
