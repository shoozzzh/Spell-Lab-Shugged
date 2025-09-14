if not held_wand then return end

local api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

local data = api.access_data( held_wand )
local actions = api.access_actions( held_wand )
local capacity = data:get_capacity()
local selection = data:get_selection()

local last_taken_slot = maxn( actions.common )
local num_empty_slots
do
	local num_taken_slots = 0
	for i = 0, last_taken_slot do
		if actions.common[ i ] == nil then
			num_taken_slots = num_taken_slots + 1
		end
	end
	if data.vars.autocap_enabled then
		num_empty_slots = math.huge
	else
		num_empty_slots = capacity - num_taken_slots
	end
end

edit_panel_shortcut_args = { nil, actions, data, selection }
operation = nil

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
	local permanent_actions = actions.permanent
	local row = nil
	for i, a in ipairs( permanent_actions ) do
		row = row or {}

		row[ #row + 1 ] = { a, selection[ i ] }
		
		if #row == actions_per_row or i == -num_pa then
			pa_rows[ #pa_row + 1 ] = row
			row = nil
		end
	end
end

for i, content in ipairs( pa_rows ) do
	do_horizontal_centered_button_list( gui, action_func, content, y_first_row + ( #pa_rows - i + 1 ) * ( 20 + 2 ) )
end

do
	local total_count = num_rows_shown * actions_per_row
	local offset_count = row_offset * actions_per_row

	local row = nil
	local first_i, last_i = offset_count + 1, total_count + offset_count
	for i = first_i, last_i do
		row = row or {}

		local a = actions.common[ i ]
		row[ #row + 1 ] = { a, selection[ i ] }
		
		if i == capacity and not data.vars.autocap_enabled then
			do_horizontal_centered_button_list( gui, action_func, row, y_first_row + math.floor( ( i - first_i ) / actions_per_row ) * ( 20 + 2 ) )
			row = nil
			break
		end

		if #row == actions_per_row or i == last_i then
			do_horizontal_centered_button_list( gui, action_func, row, y_first_row + math.floor( ( i - first_i ) / actions_per_row ) * ( 20 + 2 ) )
			row = nil
		end
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

data.vars.row_offset = row_offset

edit_panel_shortcut_args = nil
if operation and not EntityHasTag( held_wand, EditPanelTags.Recording ) then
	api.do_operation( data, actions, operation )
end