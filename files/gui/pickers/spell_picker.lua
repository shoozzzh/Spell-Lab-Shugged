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

local current_action_search_needle = ""
local current_action_search_result = {}
local current_action_search_input_anchor = 1

local keyboard = {
	{ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
	{ "A", "S", "D", "F", "G", "H", "J", "K", "L" },
	{ "Z", "X", "C", "V", "B", "N", "M", "_" },
}

local action_search_haystacks = {}
for i, a in pairs( actions ) do
	action_search_haystacks[ i ] = a.id
end

local last_action_search_needle = ""
function search_actions()
	if current_action_search_needle == last_action_search_needle then return end
	last_action_search_needle = current_action_search_needle

	if current_action_search_needle == "" then
		current_action_search_result = {}
		return
	end

	-- TODO: replace for-loop with stream api
	local all_needles_search_result = {}
	for needle in string.gmatch( current_action_search_needle, "[^ ]+" ) do
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

local function insert_character( str, char, index )
	return string.sub( str, 1, index - 1 ) .. char .. string.sub( str, index, -1 )
end

function search_needle_insert_character( char )
	current_action_search_needle = insert_character( current_action_search_needle, char, current_action_search_input_anchor )
	current_action_search_input_anchor = current_action_search_input_anchor + 1
	search_actions()
end

function show_keyboard_key( character, x, y, key_width, clicked_func )
	key_width = key_width - 1 -- gap between keys
	x = x + 0.5
	clicked_func = clicked_func or function()
		search_needle_insert_character( character )
	end

	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.HandleDoubleClickAsClick )
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

local picker = {}
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
						local item_action_comp = EntityGetFirstComponentIncludingDisabled( child_2_id, "ItemActionComponent" )
						if item_action_comp then
							unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
						elseif EntityHasTag( child_2_id, "wand" ) then
							for _, child_3_id in ipairs( EntityGetAllChildren( child_2_id ) or {} ) do
								local item_action_comp = EntityGetFirstComponentIncludingDisabled( child_3_id, "ItemActionComponent" )
								if item_action_comp then
									unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
								end
							end
						end
					end
				end
			end

			local px, py = get_player_or_camera_position()
			for _, card_id in ipairs( EntityGetInRadiusWithTag( px, py, 180, "card_action" ) ) do
				local item_action_comp = EntityGetFirstComponentIncludingDisabled( card_id, "ItemActionComponent" )
				if not item_action_comp then goto continue end

				unsorted[ ComponentGetValue2( item_action_comp, "action_id" ) or "" ] = true
				::continue::
			end

			unsorted[""] = nil
			action_ids_to_show = {}
			for k, _ in pairs( unsorted ) do
				action_ids_to_show[ #action_ids_to_show + 1 ] = k
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
	local adjusted_columns = 8
	
	GuiLayoutBeginVertical( gui, 640 * 0.05, 360 * 0.16, true )
		local scroll_id = next_id() + filter_type
		local rows = math.max( 1, math.ceil( #actions_data_to_show / adjusted_columns ) )
		GuiBeginScrollContainer( gui, scroll_id, 0, 0, 174, filter_type ~= FILTER_TYPE_SEARCH and math.min( rows * 20, 160 ) or 98 )
			local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
			local mx, my = DEBUG_GetMouseWorld()
			mx, my = get_screen_position( mx, my )
			-- extra 2 pixels for the margins
			if -2 <= mx - x and mx - x <= width + 2 and -2 <= my - y and my - y <= height + 2 then
				GuiIdPushString( gui, "NO_MORE_WAND_SWITCHING" )
				GuiAnimateBegin( gui )
				GuiAnimateAlphaFadeIn( gui, 1, 0, 0, true )
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.AlwaysClickable )
				GuiBeginScrollContainer( gui, 2, mx - 25, my - 25, 50, 50, false, 0, 0 )
				GuiEndScrollContainer( gui )
				GuiAnimateEnd( gui )
				GuiIdPop( gui )
				ModTextFileSetContent_Saved( "mods/spell_lab_shugged/scroll_box_hovered.txt", "true" )
			else
				ModTextFileSetContent_Saved( "mods/spell_lab_shugged/scroll_box_hovered.txt", "false" )
			end
			GuiLayoutBeginVertical( gui, 0, 0 )
				local action_index = 1
				local action = actions_data_to_show[action_index]
				while action do
					GuiLayoutBeginHorizontal( gui, 0, 0 )
					local actions_in_row = 0
					while action and actions_in_row < adjusted_columns do
						do_action_button( action.id, 0, 0, false, function( left_click, right_click )
							local is_unlocked_action = action_data.spawn_requires_flag and HasFlagPersistent( action_data.spawn_requires_flag ) 
							if ctrl and shift then
								if is_unlocked_action then
									RemoveFlagPersistent( action.spawn_requires_flag )
								end
								return
							end

							if not mod_setting_get( "quick_spell_picker" ) or not mod_setting_get( "show_wand_edit_panel" ) or not held_wand then
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
							set_action( access_edit_panel_state( held_wand ), action.id, action.max_uses, do_replace, EntityGetWandCapacity( held_wand ), right_click )
							if filter_type ~= FILTER_TYPE_RECENT then
								new_action_history_entry( action.id )
							end
						end, do_verbose_tooltip, action.max_uses, nil, show_locked_state, false, true )
						actions_in_row = actions_in_row + 1
						::continue::

						action_index = action_index + 1
						action = actions_data_to_show[ action_index ]
					end
					GuiLayoutEnd( gui )
					GuiLayoutAddVerticalSpacing( gui, -2 )
					--GuiLayoutAddHorizontalSpacing( gui, -2 )
				end
				if action_index == 1 then -- no actions to show
					GuiText( gui, 0, 0, wrap_key( "spell_picker_nothing" ) )
				end
			GuiLayoutEnd( gui )
		GuiEndScrollContainer( gui )

		if filter_type == FILTER_TYPE_SEARCH then
			GuiBeginScrollContainer( gui, next_id(), 0, 8, 174, 50 )
				local row_height = 13
				local key_width = 13
				local big_key_width = 1.5 * key_width
				local med_key_width = 0.75 * key_width
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
				local input_bar_width = 174 - 2 * big_key_width - 2 * med_key_width - 2.5
				if current_action_search_needle ~= "" then
					local needle_display
					if current_action_search_input_anchor > #current_action_search_needle then
						needle_display = current_action_search_needle
					else
						needle_display = insert_character( current_action_search_needle, "'", current_action_search_input_anchor )
					end
					GuiTextInput( gui, next_id(), 0, 0, needle_display, input_bar_width, -1, CHARACTERS_ACTION_ID )
				else
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
					GuiTextInput( gui, next_id(), 0, 0, text_get_translated( "spell_picker_searchbox" ), input_bar_width, -1, CHARACTERS_ACTION_ID )
				end
				local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
				show_keyboard_key( " ", x + width, y, big_key_width )
				show_keyboard_key( "<", x + width + big_key_width, y, med_key_width, function( left_click, right_click )
					if left_click then
						if current_action_search_input_anchor > 1 then
							current_action_search_input_anchor = current_action_search_input_anchor - 1
						end
					elseif right_click then
						local str_left = string.sub( current_action_search_needle, 1, current_action_search_input_anchor - 1 )
						local last_word_idx, _, _ = string.find( str_left, "[^ ]* *$" )
						if last_word_idx then
							current_action_search_input_anchor = last_word_idx
						end
					end
				end )
				show_keyboard_key( ">", x + width + med_key_width + big_key_width, y, med_key_width, function( left_click, right_click )
					if left_click then
						if current_action_search_input_anchor <= #current_action_search_needle then
							current_action_search_input_anchor = current_action_search_input_anchor + 1
						end
					elseif right_click then
						local str_right = string.sub( current_action_search_needle, current_action_search_input_anchor, -1 )
						local _, next_word_idx, _ = string.find( str_right, "^ *[^ ]*" )
						if next_word_idx then
							current_action_search_input_anchor = current_action_search_input_anchor + next_word_idx
						end
					end
				end )
				show_keyboard_key( "<-", x + width + 2 * med_key_width + big_key_width, y, big_key_width, function( left_click, right_click )
					if left_click then
						if current_action_search_input_anchor >= 2 then
							current_action_search_needle =
								string.sub( current_action_search_needle, 1, current_action_search_input_anchor - 2 )
								.. string.sub( current_action_search_needle, current_action_search_input_anchor, -1 )
							current_action_search_input_anchor = current_action_search_input_anchor - 1
							search_actions()
						end
					elseif right_click then
						current_action_search_needle = ""
						current_action_search_input_anchor = 1
						search_actions()
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
			GuiEndScrollContainer( gui )
		end
	GuiLayoutEnd( gui )

	local function show_filter( i, tooltip_text, clicked_func )
		if filter_type ~= i then GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent ) end
		GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/type_filter_"..i..".png" )
		local _,right_click,hover,_,_,_ = previous_data( gui )
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
			show_filter( FILTER_TYPE_SEARCH, wrap_key( "action_search" ) )
			show_filter( FILTER_TYPE_RECENT, wrap_key( "action_recent" ), function( left_click, right_click )
				if right_click then
					if shift then
						clear_action_history()
					end
				end
			end )
			show_filter( FILTER_TYPE_IN_INV, wrap_key( "action_in_inv" ) )
		GuiLayoutEnd( gui )
	GuiLayoutEnd( gui )
end

picker.buttons = function()
	local buttons_num = 1
	if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
		buttons_num = buttons_num + 6
	end
	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(buttons_num,4), percent_to_ui_scale_y(2), true )
		if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
			do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/quick_spell_picker.png", "quick_spell_picker" )
		end
		do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/show_locked_spells.png", "show_locked_spells", nil, nil, wrap_key( "relock_tips" ) )
		if held_wand and mod_setting_get( "show_wand_edit_panel" ) then
			do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/spell_replacement.png", "replace_mode", "spell_replacement", nil, wrap_key( "spell_replacement_tips" ) )
			show_edit_panel_toggle_options()
		end
	GuiLayoutEnd( gui )
end

return picker