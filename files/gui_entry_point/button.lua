local module_path = this_folder()

local button_image = module_path .. "button.png"
local button_width, button_height = get_image_size( button_image )
local button_x, button_y, dragging

return function()
	if not button_x then
		local button_x_ratio = tonumber( mod_setting_get( "gui_entry_point_x_ratio" ) ) or 1
		local button_y_ratio = tonumber( mod_setting_get( "gui_entry_point_y_ratio" ) ) or 0

		button_x = button_x_ratio * ( pop.screen_size[1] - button_width - 3 ) -- -3 for extra space
		button_y = button_y_ratio * ( pop.screen_size[2] - button_height - 3 ) + 3 -- ditto
	end

	button_x, button_y, dragging = pop.draggable_space( button_x, button_y, button_width, button_height, true )

	-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.AlwaysClickable )
	if pop.button( button_x, button_y, button_image ) and not dragging then
		sound_button_clicked()
		is_panel_open = not is_panel_open
	end
	
	if dragging then return end

	pop.tooltip_custom( 3, 10, true )( function( x, y )
		pop.z_mod( -100 )
		pop.text( x, y, wrap_key( ( is_panel_open and "hide" or "show" ) .. "_spell_lab" ) )
		pop.color_next( TextColors.Grey )
		pop.text( x, y + pop.text_line_height, mod_version )
		pop.z_mod( 100 )
	end )
end
