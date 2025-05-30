local saved_spell_groups = {}
local saved_spell_group_data = mod_setting_get( "saved_spell_groups" )
if saved_spell_group_data ~= nil then
	local loaded_spell_groups = smallfolk.loads( saved_spell_group_data )
	for k,v in pairs( loaded_spell_groups ) do
		if #v > 0 then
			table.insert( saved_spell_groups, v )
		end
	end
end

local function serialize_saved_spell_groups()
	if saved_spell_groups ~= nil then
		mod_setting_set( "saved_spell_groups", smallfolk.dumps( saved_spell_groups ) )
	end
end

local picker = {}
local selected_spell_group_index = 0
picker.menu = function()
	GuiLayoutBeginVertical( gui, 640 * 0.05, 360 * 0.16, true )
		do_scroll_table( next_id(), nil, nil, true, nil, saved_spell_groups, function( saved_spell_group, index )
			GuiImageButton( gui, next_id(), 2, 2, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_16x16.png" )
			local left_click,right_click,_,x,y,_,_,_,_,_,_ = previous_data( gui )
			if shortcut_check.check( shortcuts.select, left_click, right_click ) then
				if selected_spell_group_index ~= index then
					selected_spell_group_index = index
				else
					selected_spell_group_index = 0
				end
			elseif shortcut_check.check( shortcuts.deselect, left_click, right_click ) then
				if selected_spell_group_index == index then
					selected_spell_group_index = 0
				end
			elseif shortcut_check.check( shortcuts.swap, left_click, right_click ) then
				if selected_spell_group_index ~= index then
					saved_spell_groups[ selected_spell_group_index ], saved_spell_groups[ index ] =
						saved_spell_groups[ index ], saved_spell_groups[ selected_spell_group_index ]
					selected_spell_group_index = index
				end
			end
			do_custom_tooltip( function()
				do_simple_common_action_list( saved_spell_group, #saved_spell_group )
				GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1.0 )
				GuiText( gui, 0, 0, text_get_translated( "spell_group_select" ) )
			end, 3, -0.5 )

			local spell_box
			if selected_spell_group_index == index then
				spell_box = "mods/spell_lab_shugged/files/gui/buttons/spell_box_active.png"
			else
				spell_box = "mods/spell_lab_shugged/files/gui/buttons/transparent_20x20.png"
			end
			GuiImage( gui, next_id(), -20, 0, spell_box, 1, 1, 0 )

			local i = 1
			while i <= 4 and i <= #saved_spell_group do
				local action_id = saved_spell_group[ i ][1]

				local this_action_data = action_data[ action_id ]
				local action_sprite = ( this_action_data and this_action_data.sprite )
					and this_action_data.sprite or "data/ui_gfx/gun_actions/_unidentified.png"

				local spell_box = { "mods/spell_lab_shugged/files/gui/buttons/spell_box", "", ".png" }
				if this_action_data then spell_box[2] = "_" .. this_action_data.type or "" end

				local x_offset, y_offset
				if i == 1 then x_offset, y_offset = 1, 1
				elseif i == 2 then x_offset, y_offset = 10, 1
				elseif i == 3 then x_offset, y_offset = 1, 10
				elseif i == 4 then x_offset, y_offset = 10, 10
					if i < #saved_spell_group then
						action_sprite = "mods/spell_lab_shugged/files/gui/buttons/more_spells.png"
						spell_box[2] = ""
					end
				end
				x_offset, y_offset = x_offset - 1.5, y_offset - 1.5

				if this_action_data then
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
					GuiZSetForNextWidget( gui, -2 )
					GuiImage( gui, next_id(), x + x_offset, y + y_offset, action_sprite, 1.0, 0.5, 0 )
				end
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
				GuiZSetForNextWidget( gui, -1 )
				GuiImage( gui, next_id(), x + x_offset - 1, y + y_offset - 1, table.concat( spell_box ), 1.0, 0.5, 0 )

				i = i + 1
			end
		end, 8 )
	GuiLayoutEnd( gui )
end

picker.buttons = function()
	local buttons_num = 1
	if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
		buttons_num = buttons_num + 3
	end
	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(buttons_num,4), percent_to_ui_scale_y(2), true )
		if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/save_wand.png" ) then
				if not held_wand then return end
				sound_button_clicked()
				local edit_panel_state = access_edit_panel_state( held_wand )
				local actions_to_save = {}
				for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
					if s then
						if u == "" then u = nil end
						table.insert( actions_to_save, { a, u } )
					end
				end
				if #actions_to_save > 0 then
					table.insert( saved_spell_groups, 1, actions_to_save )
					serialize_saved_spell_groups()
				end
			end
			GuiTooltip( gui, wrap_key( "spell_group_box_save" ), "" )
		end

		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/delete_wand.png" ) then
			if selected_spell_group_index ~= 0 then
				sound_button_clicked()
				table.remove( saved_spell_groups, selected_spell_group_index )
				serialize_saved_spell_groups()
			end
		end
		GuiTooltip( gui, wrap_key( "spell_group_box_delete" ), "" )

		if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
			local left_click, right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/load_into_wand.png" )
			if left_click or right_click then
				local saved_spell_group = saved_spell_groups[ selected_spell_group_index ]
				local do_replace = mod_setting_get( "replace_mode" )
				if shortcut_check.check( shortcuts.replace_switch_temp ) then do_replace = not do_replace end
				if saved_spell_group and held_wand then
					sound_button_clicked()
					set_action_group( access_edit_panel_state( held_wand ), saved_spell_group, do_replace, EntityGetWandCapacity( held_wand ), right_click )
				end
			end
			GuiTooltip( gui, wrap_key( "spell_group_box_load" ), "" )
			do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/spell_replacement.png",
				"replace_mode", "spell_replacement", nil,
				text_get( "spell_replacement_tips", shortcut_texts.replace_switch_temp )
			)
		end
	GuiLayoutEnd( gui )
end

return picker