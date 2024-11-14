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
			for _, p in ipairs( saved_spell_group ) do
				do_action_button( p[1], 0, 0, selected_spell_group_index == index, function()
					if selected_spell_group_index ~= index then
						selected_spell_group_index = index
					else
						selected_spell_group_index = 0
					end
				end, function()
					local common_actions = {}
					for i, pair in ipairs( saved_spell_group ) do
						common_actions[ i - 1 ] = pair[ 1 ]
					end
					do_simple_common_action_list( common_actions, #saved_spell_group - 1 )
				end, p[2], text_get_translated( "spell_group_select" ), nil, true )
			end
		end, 1 )
	GuiLayoutEnd( gui )
end

picker.buttons = function()
	local buttons_num = 1
	if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
		buttons_num = buttons_num + 7
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
				if shift then do_replace = not do_replace end
				if saved_spell_group and held_wand then
					sound_button_clicked()
					set_action_group( access_edit_panel_state( held_wand ), saved_spell_group, do_replace, EntityGetWandCapacity( held_wand ), right_click )
				end
			end
			GuiTooltip( gui, wrap_key( "spell_group_box_load" ), "" )
			do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/spell_replacement.png", "replace_mode", "spell_replacement", nil, wrap_key( "spell_replacement_tips" ) )
			show_edit_panel_toggle_options()
		end
	GuiLayoutEnd( gui )
end

return picker