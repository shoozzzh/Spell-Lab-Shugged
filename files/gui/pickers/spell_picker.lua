local FILTER_TYPE_SEARCH = 8
local FILTER_TYPE_RECENT = 9
local FILTER_TYPE_IN_INV = 10
local filter_type = filter_type or ACTION_TYPE_PROJECTILE

local action_history = smallfolk.loads( mod_setting_get( "action_history" ) or "{}" )
function new_action_history_entry( action_id )
	local size = #action_history
	if action_history[ size ] == action_id then return end

	action_history[ size + 1 ] = action_id

	action_history_limit = math.max( 1, tonumber( mod_setting_get( "action_history_limit" ) ) or 96 )
	if size > action_history_limit then
		local action_history_limited = {}
		for i = 1, action_history_limit do
			action_history_limited[ i ] = action_history[ size - action_history_limit + i ]
		end
		action_history = action_history_limited
	end
	mod_setting_set( "action_history", smallfolk.dumps( action_history ) )
end

local function clear_action_history()
	action_history = {}
	mod_setting_set( "action_history", smallfolk.dumps( action_history ) )
end

local CHARACTERS_ACTION_ID = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

local fzy = dofile_once( "mods/spell_lab_shugged/files/lib/fzy_lua.lua" )

local current_action_search_needle = dofile( "mods/spell_lab_shugged/files/gui/editable_text.lua" )
local current_action_search_result = {}
local action_search_haystacks = {}
for i, a in pairs( actions ) do
	action_search_haystacks[ i ] = a.id
end
local last_action_search_needle = ""
current_action_search_needle.on_changed = function()
	local search_needle_text = current_action_search_needle.text
	if search_needle_text == last_action_search_needle then return end
	last_action_search_needle = search_needle_text

	if search_needle_text == "" then
		current_action_search_result = {}
		return
	end

	-- TODO: replace for-loop with stream api
	local all_needles_search_result = {}
	for needle in string.gmatch( search_needle_text, "[^ ]+" ) do
		all_needles_search_result[ #all_needles_search_result + 1 ] = fzy.filter( needle, action_search_haystacks, false )
	end

	current_action_search_result = {}
	for _, search_result in ipairs( all_needles_search_result ) do
		for _, search_result_entry in ipairs( search_result ) do
			current_action_search_result[ #current_action_search_result + 1 ] = search_result_entry
		end
	end
	table.sort( current_action_search_result, function( a, b ) return a[3] > b[3] end )
	for i, search_result_entry in ipairs( current_action_search_result ) do
		current_action_search_result[ i ] = action_search_haystacks[ search_result_entry[1] ]
	end
end

local function show_keyboard_key( character, x, y, key_width, clicked_func )
	key_width = key_width - 1 -- gap between keys
	x = x + 0.5
	clicked_func = clicked_func or function()
		current_action_search_needle:insert_character( character )
	end

	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	local button_text = ""
	local text_width,_ = GuiGetTextDimensions( gui, button_text )
	while text_width < key_width do
		button_text = button_text .. "l"
		text_width,_ = GuiGetTextDimensions( gui, button_text )
	end
	button_text = string.sub( button_text, 1, -1 )
	text_width,_ = GuiGetTextDimensions( gui, button_text )
	local bracket_width,_ = GuiGetTextDimensions( gui, "[" )
	GuiAnimateBegin( gui )
		GuiAnimateAlphaFadeIn( gui, 1, 0, 0, true )
		GuiButton( gui, next_id(), x + key_width / 2 - text_width / 2, y, button_text )
		local left_click,right_click = previous_data( gui )
		if left_click or right_click then
			clicked_func( left_click, right_click )
		end
	GuiAnimateEnd( gui )
	local _,_,hover,_,_,_,_,_,_,_,_ = previous_data( gui )
	local character_width,_ = GuiGetTextDimensions( gui, character )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	if hover then
		GuiColorSetForNextWidget( gui, 1, 1, 0.5, 1 )
	else
		GuiColorSetForNextWidget( gui, 1, 1, 1, 0.3 )
	end
	GuiText( gui, x - bracket_width / 3, y, "[" )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	if hover then
		GuiColorSetForNextWidget( gui, 1, 1, 0.5, 1 )
	else
		GuiColorSetForNextWidget( gui, 1, 1, 1, 0.3 )
	end
	GuiText( gui, x + key_width - bracket_width * 2 / 3, y, "]" )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	if hover then
		GuiColorSetForNextWidget( gui, 1, 1, 0.5, 1 )
	end
	GuiButton( gui, next_id(), x + key_width / 2 - character_width / 2, y, character )
end

local spell_search_focused = false

local character_keys = {
	{ "Key_a", "A" },
	{ "Key_b", "B" },
	{ "Key_c", "C" },
	{ "Key_d", "D" },
	{ "Key_e", "E" },
	{ "Key_f", "F" },
	{ "Key_g", "G" },
	{ "Key_h", "H" },
	{ "Key_i", "I" },
	{ "Key_j", "J" },
	{ "Key_k", "K" },
	{ "Key_l", "L" },
	{ "Key_m", "M" },
	{ "Key_n", "N" },
	{ "Key_o", "O" },
	{ "Key_p", "P" },
	{ "Key_q", "Q" },
	{ "Key_r", "R" },
	{ "Key_s", "S" },
	{ "Key_t", "T" },
	{ "Key_u", "U" },
	{ "Key_v", "V" },
	{ "Key_w", "W" },
	{ "Key_x", "X" },
	{ "Key_y", "Y" },
	{ "Key_z", "Z" },
	{ "Key_1", "1" },
	{ "Key_2", "2" },
	{ "Key_3", "3" },
	{ "Key_4", "4" },
	{ "Key_5", "5" },
	{ "Key_6", "6" },
	{ "Key_7", "7" },
	{ "Key_8", "8" },
	{ "Key_9", "9" },
	{ "Key_0", "0" },
	{ "Key_SPACE", " " },
	{ "Key_MINUS", "_" },
}

local Focus_SpellSearch = {
	id = "spell_search",
	on_focused = function() spell_search_focused = true end,
	on_unfocused = function() spell_search_focused = false end,
	on_input = function( keyboard_input )
		if keyboard_input.Key_BACKSPACE then
			current_action_search_needle:left_delete()
		end
		if keyboard_input.Key_DELETE then
			current_action_search_needle:right_delete()
		end
		if keyboard_input.Key_HOME then
			current_action_search_needle:input_anchor_move_to_beginning()
		end
		if keyboard_input.Key_END then
			current_action_search_needle:input_anchor_move_to_end()
		end
		if keyboard_input.Key_LEFT then
			if not keyboard_input.Key_ALT then
				current_action_search_needle:input_anchor_move_left()
			else
				current_action_search_needle:input_anchor_move_to_last_word()
			end
		end
		if keyboard_input.Key_RIGHT then
			if not keyboard_input.Key_ALT then
				current_action_search_needle:input_anchor_move_right()
			else
				current_action_search_needle:input_anchor_move_to_next_word()
			end
		end
		for _, p in ipairs( character_keys ) do
			if keyboard_input[ p[1] ] then
				current_action_search_needle:insert_character( p[2] )
			end
		end
	end,
}

local picker = {}

local keyboard = {
	{ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
	{ "A", "S", "D", "F", "G", "H", "J", "K", "L" },
	{ "Z", "X", "C", "V", "B", "N", "M", "_" },
}

picker.menu = function()
	local show_locked_spells = mod_setting_get( "show_locked_spells" )
	local actions_data_to_show

	if filter_type <= 7 then
		actions_data_to_show_ = sorted_actions[filter_type]
		actions_data_to_show = {}
		for _, action_data in ipairs( actions_data_to_show_ ) do
			if action_data.hide_from_conjurer then
				goto continue
			end
			if not show_locked_spells and not is_action_unlocked( action_data ) then
				goto continue
			end
			actions_data_to_show[ #actions_data_to_show + 1 ] = action_data
			::continue::
		end
	else
		local action_ids_to_show
		if filter_type == FILTER_TYPE_SEARCH then
			action_ids_to_show = current_action_search_result
		elseif filter_type == FILTER_TYPE_RECENT then
			action_ids_to_show = action_history
		elseif filter_type == FILTER_TYPE_IN_INV then
			local unsorted = {}
			-- looks ugly, but that's for the compatiblity with a mod called "Noita Inventory"
			for _, child_id in ipairs( EntityGetAllChildren( player ) or {} ) do
				if EntityGetName( child_id ) == "inventory_full" or EntityGetName( child_id ) == "inventory_quick" then
					for _, child_2_id in ipairs( EntityGetAllChildren( child_id ) or {} ) do
						local item_comp = EntityGetFirstComponentIncludingDisabled( child_2_id, "ItemComponent" )
						local item_action_comp = EntityGetFirstComponentIncludingDisabled( child_2_id, "ItemActionComponent" )
						if item_comp and item_action_comp and EntityHasTag( child_2_id, "card_action" ) then
							unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
						elseif EntityHasTag( child_2_id, "wand" ) and not mod_setting_get( "include_spells_in_non_inv_wand" ) then
							for _, child_3_id in ipairs( EntityGetAllChildren( child_2_id, "card_action" ) or {} ) do
								local item_comp = EntityGetFirstComponentIncludingDisabled( child_3_id, "ItemComponent" )
								local item_action_comp = EntityGetFirstComponentIncludingDisabled( child_3_id, "ItemActionComponent" )
								if item_comp and item_action_comp then
									unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
								end
							end
						end
					end
				end
			end

			local px, py = get_player_or_camera_position()
			for _, card_id in ipairs( EntityGetInRadiusWithTag( px, py, 180, "card_action" ) ) do
				-- exclude those in non-inv wands, because of an issue which nolla is responsible for
				if not mod_setting_get( "include_spells_in_non_inv_wand" ) and EntityGetParent( card_id ) ~= 0 then goto continue end

				local item_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemComponent" )
				local item_action_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemActionComponent" )
				if not item_comp or not item_action_comp then goto continue end

				unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
				::continue::
			end
			if mod_setting_get( "include_spells_in_non_inv_wand" ) then
				for _, wand_id in ipairs( EntityGetInRadiusWithTag( px, py, 180, "wand" ) ) do
					for _, card_id in ipairs( EntityGetAllChildren( wand_id, "card_action" ) or {} ) do
						local item_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemComponent" )
						local item_action_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemActionComponent" )
						if not item_comp or not item_action_comp then goto continue end

						unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
						::continue::
					end
				end
			end

			unsorted[""] = nil
			action_ids_to_show = {}
			for k, _ in pairs( unsorted ) do
				if action_id_to_idx[ k ] then
					action_ids_to_show[ #action_ids_to_show + 1 ] = k
				end
			end

			table.sort( action_ids_to_show, function( a, b ) return action_id_to_idx[ a ] < action_id_to_idx[ b ] end )
		end
		actions_data_to_show = {}
		for i, a in ipairs( action_ids_to_show ) do
			if action_data.hide_from_conjurer then
				goto continue
			end
			if not show_locked_spells and not is_action_unlocked( action_data ) then
				goto continue
			end

			-- actions in FILTER_TYPE_RECENT should be ordered inversely
			if filter_type ~= FILTER_TYPE_RECENT then
				actions_data_to_show[ i ] = action_data[ a ]
			else
				actions_data_to_show[ #action_ids_to_show - i + 1 ] = action_data[ a ]
			end
			::continue::
		end
	end
	
	local interacting = false
	GuiLayoutBeginVertical( gui, 640 * 0.05, 360 * 0.16, true )
		local scroll_ids = {}
		for i = 0, 10 do
			scroll_ids[ i ] = next_id()
		end

		local height = nil
		local height_autofit = true
		if filter_type == FILTER_TYPE_SEARCH then
			if mod_setting_get( "show_screen_keyboard" ) then
				height = 98
			else
				height = 138
			end
			height_autofit = false
		end

		local scroll_table = { do_scroll_table( scroll_ids[ filter_type ], nil,
			height, height_autofit, function( hovered ) interacting = interacting or hovered end,
			actions_data_to_show, function( action )
			local left_click, right_click = do_action_button( action.id, 0, 0, false, do_verbose_tooltip, action.max_uses, nil, show_locked_state, false, true )
			if left_click or right_click then
				local is_unlocked_action = action.spawn_requires_flag and HasFlagPersistent( action.spawn_requires_flag ) 
				if shortcut_check.check( shortcuts.relock, left_click, right_click ) then
					if is_unlocked_action then
						RemoveFlagPersistent( action.spawn_requires_flag )
					end
					return
				end

				if not mod_setting_get( "quick_spell_picker" )
					or not mod_setting_get( "show_wand_edit_panel" ) or not held_wand then
					if not player then return end
					local x, y = EntityGetTransform( player )
					local action_entity = CreateItemActionEntity( action.id, x, y )
					local inventory_full
					local player_child_entities = EntityGetAllChildren( player )
					if not player_child_entities then return end
					for i,child_entity in ipairs( player_child_entities ) do
						if EntityGetName( child_entity ) == "inventory_full" then
							inventory_full = child_entity
							break
						end
					end
					-- set inventory contents
					if inventory_full then
						EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
						EntityAddChild( inventory_full, action_entity )
						GamePrint( GameTextGet( wrap_key( "action_added_to_inventory" ), GameTextGetTranslatedOrNot( action.name ) ) )
						if filter_type ~= FILTER_TYPE_RECENT then
							new_action_history_entry( action.id )
						end
					end
					return
				end
				if not held_wand then return end
				local do_replace = mod_setting_get( "replace_mode" )
				if shift then do_replace = not do_replace end
				local uses_remaining = nil
				if action.max_uses then
					if not world_state_unlimited_spells or action.never_unlimited then
						if not mod_setting_get( "zero_uses" ) then
							uses_remaining = action.max_uses
						else
							uses_remaining = 0
						end
					end
				end
				set_action( access_edit_panel_state( held_wand ), action.id, uses_remaining, do_replace, EntityGetWandCapacity( held_wand ), right_click )
				if filter_type ~= FILTER_TYPE_RECENT then
					new_action_history_entry( action.id )
				end
			end
		end ) }

		if filter_type == FILTER_TYPE_SEARCH then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiZSetForNextWidget( gui, 1 )
			GuiTextInput( gui, next_id(), 3, 10, "", input_bar_width, -1, CHARACTERS_ACTION_ID )
			local _,_,_,_,_,_,text_input_height,_,_,_,_ = previous_data( gui )
			GuiLayoutAddVerticalSpacing( gui, -( text_input_height + 10 ) )

			local keyboard_height = text_input_height
			if mod_setting_get( "show_screen_keyboard" ) then
				keyboard_height = 10 --[[ incorrectly assumed height of text input ]]+ 40
			end

			GuiBeginScrollContainer( gui, next_id(), 0, 8, SCROLL_TABLE_WIDTH, keyboard_height )
				if InputIsMouseButtonJustDown( Mouse_left ) then
					local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
					local mx, my = get_mouse_pos_on_screen()
					if -2 <= mx - x and mx - x <= width + 2 and -2 <= my - y and my - y <= height + 2 then
						interacting = true
					end
				end
				local row_height = 13
				local key_width = 13
				local big_key_width = 1.5 * key_width
				local med_key_width = 0.75 * key_width
				local input_bar_width
				if mod_setting_get( "show_screen_keyboard" ) then
					input_bar_width = 174 - 2 * big_key_width - 2 * med_key_width - 2.5
				else
					input_bar_width = 174 - key_width - 2.5
				end
				if not spell_search_focused then
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
				end
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
				if spell_search_focused or current_action_search_needle.text ~= "" then
					GuiTextInput( gui, next_id(), 0, 0, current_action_search_needle.text, input_bar_width, -1, CHARACTERS_ACTION_ID )
				else
					GuiZSetForNextWidget( gui, -1 )
					GuiTextInput( gui, next_id(), 0, 0, text_get_translated( "spell_picker_searchbox" ), input_bar_width, -1, CHARACTERS_ACTION_ID )
					GuiTextInput( gui, next_id(), 0, 0, "", input_bar_width, -1, CHARACTERS_ACTION_ID )
				end
				local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
				if spell_search_focused or current_action_search_needle.text ~= "" then
					local left_text = current_action_search_needle.text:sub( 1, current_action_search_needle.input_anchor - 1 )
					local input_anchor_offset = GuiGetTextDimensions( gui, left_text )
					GuiLayoutBeginLayer( gui )
					GuiZSetForNextWidget( gui, -1 )
					local image_height = 10
					local scale = text_input_height / image_height
					GuiImage( gui, next_id(), x + 1 + input_anchor_offset, y + 2 * ( text_input_height - 2 ) / ( image_height - 2 ), "mods/spell_lab_shugged/files/gui/input_anchor.png", 1, scale, 0 )
					GuiLayoutEndLayer( gui )
				end
				if InputIsMouseButtonJustDown( Mouse_left ) then
					local mx, my = get_mouse_pos_on_screen()
					if -2 <= mx - x and mx - x <= width + 2 and -2 <= my - y and my - y <= height + 2 then
						change_keyboard_focus( Focus_SpellSearch )
						local width_mouse_pos = mx - x
						local last_substring, substring
						for i = 0, #current_action_search_needle.text do
							substring = string.sub( current_action_search_needle.text, 1, i )
							if GuiGetTextDimensions( gui, substring ) >= width_mouse_pos then
								break
							end
							last_substring = substring
							substring = nil
						end
						if last_substring and not substring then
							current_action_search_needle.input_anchor = #last_substring + 1
						elseif not last_substring and substring then
							current_action_search_needle.input_anchor = #substring + 1
						elseif last_substring and substring then
							if width_mouse_pos - GuiGetTextDimensions( gui, last_substring ) <= GuiGetTextDimensions( gui, substring ) - width_mouse_pos then
								current_action_search_needle.input_anchor = #last_substring + 1
							else
								current_action_search_needle.input_anchor = #substring + 1
							end
						end
					end
				end
				if mod_setting_get( "show_screen_keyboard" ) then
					show_keyboard_key( " ", x + width, y, big_key_width )
					show_keyboard_key( "<", x + width + big_key_width, y, med_key_width, function( left_click, right_click )
						if left_click then
							current_action_search_needle:input_anchor_move_left()
						elseif right_click then
							current_action_search_needle:input_anchor_move_to_last_word()
						end
					end )
					show_keyboard_key( ">", x + width + med_key_width + big_key_width, y, med_key_width, function( left_click, right_click )
						if left_click then
							current_action_search_needle:input_anchor_move_right()
						elseif right_click then
							current_action_search_needle:input_anchor_move_to_next_word()
						end
					end )
					show_keyboard_key( "<-", x + width + 2 * med_key_width + big_key_width, y, big_key_width, function( left_click, right_click )
						if left_click then
							current_action_search_needle:left_delete()
						elseif right_click then
							current_action_search_needle:clear()
						end
					end )

					local ordinal_y = y + row_height
					for i, c in ipairs( keyboard[1] ) do
						show_keyboard_key( c, x + i * key_width - key_width, ordinal_y, key_width )
					end
					for i, c in ipairs( keyboard[2] ) do
						show_keyboard_key( c, x + i * key_width - key_width / 2, ordinal_y + row_height, key_width )
					end
					for i, c in ipairs( keyboard[3] ) do
						show_keyboard_key( c, x + i * key_width, ordinal_y + 2 * row_height, key_width )
					end
					for i = 1, 3 do
						local first_j = 1
						if i == 1 then
							first_j = 0
						end
						for j = first_j, 3 do
							show_keyboard_key( tostring( i * 3 - 3 + j ), x + #keyboard[1] * key_width + j * key_width - key_width / 2, ordinal_y + 2 * row_height - i * row_height + row_height, key_width )
						end
					end
				else
					show_keyboard_key( "X", x + width, y, key_width, function( left_click, right_click )
						current_action_search_needle:clear()
					end )
				end
			GuiEndScrollContainer( gui )
		end
	GuiLayoutEnd( gui )

	local function show_filter( i, tooltip_text, clicked_func )
		if filter_type ~= i then GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent ) end
		GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/type_filter_"..i..".png" )
		local left_click,right_click,hover,_,_,_ = previous_data( gui )
		if clicked_func then
			clicked_func( left_click, right_click )
		end
		GuiTooltip( gui, tooltip_text, "" )
		if hover then filter_type = i end
	end

	GuiLayoutBeginHorizontal( gui, 0, 360 * 0.16, true, 0, 0 )
		GuiLayoutBeginVertical( gui, 640 * 0.01, 0, true )
		for i = 0, 7 do
			show_filter( i, type_text[i] )
		end
		GuiLayoutEnd( gui )
		GuiLayoutBeginVertical( gui, 640 * 0.34 - 20 + 10, 0, true )
			if mod_setting_get( "special_filter_button_align_to" ) == "bottom" then
				for i = 0, 4 do
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_20x20.png" )
				end
			end
		GuiLayoutEnd( gui )
	GuiLayoutEnd( gui )

	if spell_search_focused and filter_type ~= FILTER_TYPE_SEARCH then
		change_keyboard_focus( Focus_PlayerControls )
	elseif InputIsMouseButtonJustDown( Mouse_left ) then
		if not interacting then
			if change_keyboard_focus( Focus_PlayerControls ) then
				block_upcoming_wand_shooting()
			end
		end
	end
end

local function show_filter_button( i, tooltip_text, clicked_func )
	if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/type_filter_"..i..".png" ) then
		filter_type = i
		sound_button_clicked()
	end
	local left_click,right_click,hover,x,y,_ = previous_data( gui )
	if clicked_func then clicked_func( left_click, right_click ) end
	GuiTooltip( gui, tooltip_text, "" )
end

picker.buttons = function()
	local buttons_num = 5
	if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
		buttons_num = buttons_num + 2
	end
	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(buttons_num,4), percent_to_ui_scale_y(2), true )
		if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
			do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/quick_spell_picker.png", "quick_spell_picker" )
		end
		do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/show_locked_spells.png", "show_locked_spells", nil, nil, text_get( "relock_tips", shortcut_texts.relock ) )
		do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/zero_uses.png", "zero_uses" )
		if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
			do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/spell_replacement.png", "replace_mode", "spell_replacement", nil, text_get( "spell_replacement_tips", shortcut_texts.replace_switch_temp ) )
		end
		show_filter_button( FILTER_TYPE_SEARCH, wrap_key( "action_search" ) )
		show_filter_button( FILTER_TYPE_RECENT, text_get( "action_recent", shortcut_texts.clear_action_history ), function( left_click, right_click )
			if shortcut_check.check( shortcuts.clear_action_history, left_click, right_click ) then
				clear_action_history()
				sound_button_clicked()
			end
		end )
		show_filter_button( FILTER_TYPE_IN_INV, wrap_key( "action_in_inv" ) )
	GuiLayoutEnd( gui )
end

return picker