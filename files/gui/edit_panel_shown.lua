if not held_wand then return end

local gui_pos = dofile_once( "mods/spell_lab_shugged/files/lib/gui_pos.lua" )

do
	local refresh_cache = false
	if edit_panel_cache == nil then 
		refresh_cache = true
	elseif edit_panel_last_frame_shown ~= now - 1 then
		refresh_cache = true
	elseif edit_panel_cache.wand ~= held_wand then
		refresh_cache = true
	end

	if refresh_cache then
		edit_panel_cache = {
			wand = held_wand,
			dragging_selection = false,
			selecting = false,
		}
	end
	edit_panel_last_frame_shown = now
end
local cache = edit_panel_cache

local api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

local data = api.access_data( held_wand )
local actions = api.access_actions( held_wand )
local capacity = data:get_capacity()
local selected_section, selection_start, selection_end = data:get_selection()
local function is_selected( section_name, index )
	return selected_section == section_name and selection_start <= index and index <= selection_end
end

edit_panel_shortcut_args = { nil, actions, data, selection }

local function set_i( i )
	edit_panel_shortcut_args[1] = i
end

local actions_per_row = math.floor( screen_width / ( 20 + 2 ) - 3 )
do
	local actions_per_row_limit = tonumber( mod_setting_get( "wand_edit_panel_max_actions_per_row" ) )
	if actions_per_row_limit and actions_per_row_limit ~= 0 then
		actions_per_row = math.min( actions_per_row, actions_per_row_limit )
	end
end
local num_rows_shown_limit = tonumber( mod_setting_get( "wand_edit_panel_max_rows" ) ) or 5

local row_offset = data.vars.row_offset
local num_rows_shown
local reached_last_row
do
	if data.vars.autocap_enabled then
		num_rows_shown = num_rows_shown_limit
		reached_last_row = false
		goto done
	end

	local num_rows_all = math.ceil( capacity / actions_per_row )
	
	if num_rows_all <= num_rows_shown_limit then
		num_rows_shown = num_rows_all
		reached_last_row = true
		row_offset = 0
		goto done
	end

	num_rows_shown = num_rows_shown_limit
	
	if num_rows_shown + row_offset > num_rows_all then
		row_offset = math.max( num_rows_all - num_rows_shown, 0 )
	end
	
	reached_last_row = num_rows_shown + row_offset == num_rows_all
end
::done::

local y_baseline = screen_height * 0.96 + 2
local y_first_row = y_baseline - num_rows_shown * ( 20 + 2 )

local create_real_sprite = mod_setting_get( "gif_mode" )

local action_func = create_real_sprite and do_real_sprite_panel_action or do_panel_action

local pa_rows = {}
do
	local row = nil
	for i, a in ipairs( actions.permanent ) do
		row = row or {}

		row[ #row + 1 ] = { a, is_selected( "permanent", i ) }
		
		if #row == actions_per_row then
			pa_rows[ #pa_rows + 1 ] = row
			row = nil
		end
	end

	if row ~= nil then
		pa_rows[ #pa_rows + 1 ] = row
	end
end

do
	local num_pa_rows = #pa_rows
	for i, row in ipairs( pa_rows ) do
		do_horizontal_centered_button_list( gui, action_func, row, y_first_row - ( num_pa_rows - i + 1 ) * ( 20 + 2 ), set_i )
	end
end

local common_rows = {}

do
	local total_count = num_rows_shown * actions_per_row
	local offset_count = row_offset * actions_per_row

	local row = nil
	local first_i, last_i = offset_count + 1, total_count + offset_count
	for i = first_i, last_i do
		row = row or {}

		local a = actions.common[ i ]
		if cache.dragging_section == "common" and i == cache.dragging_index then
			row[ #row + 1 ] = { 0, false }
		else
			row[ #row + 1 ] = { a, is_selected( "common", i ) }
		end
		
		local row_end = #row == actions_per_row or i == last_i
		local action_end = i == capacity

		if row_end or action_end then
			common_rows[ #common_rows + 1 ] = row
			row = nil
		end

		if action_end then break end
	end
end

do
	for i, row in ipairs( common_rows ) do
		do_horizontal_centered_button_list(
			gui, action_func, row, y_first_row + ( i - 1 ) * ( 20 + 2 ), set_i
		)
	end
end

if row_offset > 0 then
	if GuiImageButton( gui, next_id(), horizontal_centered_x(1), y_first_row - ( #pa_rows + 1 ) * ( 20 + 2 ), "", "mods/spell_lab_shugged/files/gui/buttons/pageup.png" ) then
		row_offset = row_offset - 1
	end
end

if not reached_last_row then
	if GuiImageButton( gui, next_id(), horizontal_centered_x(1), y_baseline, "", "mods/spell_lab_shugged/files/gui/buttons/pagedown.png" ) then
		row_offset = row_offset + 1
	end
end

edit_panel_shortcut_args = nil

local left_just_down  = InputIsMouseButtonJustDown( Mouse_left )
local left_holding    = InputIsMouseButtonDown( Mouse_left )
local left_just_up    = InputIsMouseButtonJustUp( Mouse_left )
local right_just_down = InputIsMouseButtonJustDown( Mouse_right )
local right_holding   = InputIsMouseButtonDown( Mouse_right )
local right_just_up   = InputIsMouseButtonJustUp( Mouse_right )


if left_just_down or left_holding or left_just_up then
	local mouse_x, mouse_y = gui_pos.get_pos_on_screen( gui, DEBUG_GetMouseWorld() )
	local pa_first_row = y_first_row - #pa_rows * ( 20 + 2 )

	local hovered_section, hovered_index
	if pa_first_row - ( 20 + 2 ) <= mouse_y and mouse_y < pa_first_row then -- just above permanent actions
		hovered_section = "permanent"

		local num_pa = 0
		for _, row in ipairs( pa_rows ) do
			num_pa = num_pa + #row
		end
		hovered_index = num_pa
	elseif pa_first_row <= mouse_y and mouse_y < y_first_row then -- among permanent actions
		hovered_section = "permanent"

		local row = math.ceil( ( mouse_y - pa_first_row ) / ( 20 + 2 ) )
		local row_length = #pa_rows[ row ]

		local offset = horizontal_centered_x( #pa_rows[ row ] )
		local column = math.ceil( ( mouse_x - offset ) / ( 20 + 2 ) )
		column = math.max( column, 1 )
		column = math.min( column, row_length )

		hovered_index = ( row - 1 ) * actions_per_row + column
	elseif y_first_row <= mouse_y and mouse_y < y_baseline then -- among common actions
		hovered_section = "common"

		local row = math.ceil( ( mouse_y - y_first_row ) / ( 20 + 2 ) )
		local row_length = #common_rows[ row ]

		local offset = horizontal_centered_x( row_length )
		local column = math.ceil( ( mouse_x - offset ) / ( 20 + 2 ) )
		column = math.max( column, 1 )
		column = math.min( column, row_length )

		hovered_index = ( row - 1 ) * actions_per_row + column
	elseif y_baseline <= mouse_y and mouse_y < y_baseline + ( 20 + 2 ) then -- below common actions
		hovered_section = "common"
		hovered_index = math.min( capacity, ( row_offset + num_rows_shown ) * actions_per_row )
	end

	if not hovered_section then goto not_hovering end

	if left_just_down then
		if is_selected( hovered_section, hovered_index ) then
			cache.dragging_selection = true
		elseif data.selection.section_name ~= "" then
			data.selection.section_name = ""
			data.selection.range_start = -1
			data.selection.range_end = -1
		else
			data.selection.section_name = hovered_section
			data.selection.range_start = hovered_index
			data.selection.range_end = hovered_index
			cache.selecting = true
		end
	elseif left_holding then
		if cache.selecting and data.selection.section_name == hovered_section then
			if hovered_index <= data.selection.range_start then
				data.selection.range_start = hovered_index
			else
				data.selection.range_end = hovered_index
			end
		end
	elseif left_just_up then
		if cache.selecting then
			cache.selecting = false
		elseif cache.dragging_selection then
			cache.dragging_selection = false
			local selected_section, selection_start, selection_end = data:get_selection()
			move_actions( actions[ selected_section ], selection_start, selection_end, actions[ hovered_section ], hovered_index + 1 )

			data.selection.section_name = hovered_section
			data.selection.range_start = hovered_index
			data.selection.range_end = hovered_index + selection_end - selection_start

			data:record_new_history( wrap_key( "operation_set_action" ) )
		end
	elseif right_just_down then -- TODO
	end

	::not_hovering::
end

data.vars.row_offset = row_offset