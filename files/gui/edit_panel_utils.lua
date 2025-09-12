function fit_into_capacity( current_actions, times_inserting, max_capacity )
	local empty_slots_taken = 0
	for i = max_capacity + times_inserting, 1, -1 do
		if empty_slots_taken == times_inserting then return true end
		local a = current_actions[ i ]
		if not a or a[2] == "" then
			empty_slots_taken = empty_slots_taken + 1
			table.remove( current_actions, i )
		end
	end
	return empty_slots_taken == times_inserting
end

function set_action( edit_panel_state, action_id, uses_remaining, do_replace, max_capacity, left_insert )
	if edit_panel_state.get_autocap_enabled() then
		max_capacity = nil
	end
	local current_actions = {}
	local set = false
	local times_inserting = 0
	for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
		if s then
			if left_insert then
				table.insert( current_actions, { true, action_id, uses_remaining } )
			end
			if not do_replace and a ~= "" then
				table.insert( current_actions, { false, a, u } )
				times_inserting = times_inserting + 1
			end
			if not left_insert then
				table.insert( current_actions, { true, action_id, uses_remaining } )
			end
			set = true
		else
			table.insert( current_actions, { s, a, u } )
		end
	end
	if not set then
		times_inserting = times_inserting + 1
		if not left_insert then
			table.insert( current_actions, { false, action_id, uses_remaining } )
		else
			table.insert( current_actions, 1, { false, action_id, uses_remaining } )
		end
	end
	if not do_replace and max_capacity then
		if not fit_into_capacity( current_actions, times_inserting, max_capacity ) then
			GamePrint( text_get_translated( "no_enough_space" ) )
			return
		end
	end
	edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_set_action" ) )
end
function set_action_group( edit_panel_state, action_group, do_replace, max_capacity, left_insert )
	if edit_panel_state.get_autocap_enabled() then
		max_capacity = nil
	end
	local current_actions = {}
	local i = 1
	local last_insert_index = 1
	local set = false
	local times_inserting = 0
	for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
		local action_to_set = action_group[ i ]
		if action_to_set and s then
			if left_insert then
				table.insert( current_actions, { true, action_to_set[1], action_to_set[2] } )
			end
			if not do_replace and a ~= "" then
				table.insert( current_actions, { false, a, u } )
				times_inserting = times_inserting + 1
			end
			if not left_insert then
				table.insert( current_actions, { true, action_to_set[1], action_to_set[2] } )
			end
			i = i + 1
			last_insert_index = #current_actions
			set = true
		else
			table.insert( current_actions, { s, a, u } )
		end
	end
	if i <= #action_group then
		if not set then
			last_insert_index = 0
		end
		if not left_insert then
			for j = i, #action_group do
				table.insert( current_actions, { true, action_group[ j ][1], action_group[ j ][2] } )
				times_inserting = times_inserting + 1
			end
		else
			for j = #action_group, i, -1 do
				table.insert( current_actions, last_insert_index + 1, { true, action_group[ j ][1], action_group[ j ][2] } )
				times_inserting = times_inserting + 1
			end
		end
	end
	if not do_replace and max_capacity then
		if not fit_into_capacity( current_actions, times_inserting, max_capacity ) then
			GamePrint( text_get_translated( "no_enough_space" ) )
			return
		end
	end
	edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_set_action_group" ) )
end

local api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

local function empty_slot_scanner( actions )
	local pointer = -1
	return function()
		while true do
			pointer = pointer + 1
			if pointer >= capacity then
				if data.vars.autocap_enabled then
					return pointer
				end
				return nil
			end
			if not actions[ pointer ] then
				return pointer
			end
		end
	end
end

local permanent_action_button_shortcuts = {
	[ shortcuts.always_cast ] = function( i, actions, data, selection )
		local empty_slot = empty_slot_scanner( actions ).next_empty_slot()
		if not empty_slot then
			GamePrint( text_get_translated( "demotion_no_space" ) )
			return
		end

		local manipulations = {}
		for j = 0, empty_slot - 1 do
			manipulations[ j ] = { Manipulation.Move, j + 1 }
		end
		manipulations[ i ] = { Manipulation.Move, 0 }
		
		operation = {
			manipulations = manipulations,
			name = wrap_key( "operation_demote_permanent_action" ),
		}
	end,
}
local action_button_shortcuts = {
	[ shortcuts.always_cast ] = function( i, actions, data, selection )
		local promoted = actions[ i ]
		if not promoted then return end

		local to = -1
		while actions[ to ] do
			to = to + 1
		end

		operation = {
			manipulations = { [ i ] = { Manipulation.Move, to } },
			name = wrap_key( "operation_promote_permanent_action" ),
		}
	end,
	[ shortcuts.expand_selection_left ] = function( i, actions, data, selection )
		for j = i - 1, 0, -1 do
			if selection[ j ] then
				break
			end
			selection[ j ] = true
		end
		operation = {
			selection = selection,
			name = wrap_key( "operation_select" ),
		}
	end,
	[ shortcuts.expand_selection_right ] = function( i, actions, data, selection )
		local next_selected
		for j = i + 1, maxn( selection ) do
			if selection[ j ] then
				next_selected = j
				break
			end
		end

		if next_selected then
			for j = i + 1, next_selected do
				selection[ j ] = true
			end
			operation = {
				selection = selection,
				name = wrap_key( "operation_select" ),
			}
		end
	end,
	[ shortcuts.duplicate ] = function( i, actions, data, selection )
		local num_selected = 0
		for _, _ in pairs( selection ) do
		end

		local current_actions = {}
		local selected_indexes = {}
		local index = 1
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { false, a, u } )
			if s then
				table.insert( selected_indexes, index )
			end
			index = index + 1
		end
		if current_actions[ i ] and current_actions[ i ][1] then
			return
		end
		local first = selected_indexes[1]
		if not first then return end
		local offset = i - first
		if not edit_panel_state.get_autocap_enabled() then
			for j, index in ipairs( selected_indexes ) do
				local the_other = index + offset
				if the_other > capacity then
					return
				end
			end
		end
		local selected_actions = {}
		for j, index in ipairs( selected_indexes ) do
			selected_actions[ j ] = { true, current_actions[ index ][2], current_actions[ index ][3] }
		end
		for j, index in ipairs( selected_indexes ) do
			current_actions[ index + offset ] = selected_actions[ j ]
		end
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_duplicate_action" ) )
	end,
	[ shortcuts.multi_select ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { s, a, u } )
		end
		if current_actions[ i ] then
			current_actions[ i ][1] = not current_actions[ i ][1]
		else
			current_actions[ i ] = { true }
		end
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_select" ) )
	end,
	[ shortcuts.delete_action ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { s, a, u } )
		end
		if current_actions[ i ] then
			local a = current_actions[ i ][2]
			if a and a ~= "" then
				new_action_history_entry( a )
			end
		end
		current_actions[ i ] = { true }
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_delete_action_slot" ) )
	end,
	[ shortcuts.delete_slot ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { s, a, u } )
		end
		if current_actions[ i ] then
			local a = current_actions[ i ][2]
			if a and a ~= "" then
				new_action_history_entry( a )
			end
		end
		table.remove( current_actions, i )
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_delete_action_slot" ) )
	end,
	[ shortcuts.swap ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		local indexes_to_swap = {}
		local index = 1
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { s, a, u } )
			if s then
				table.insert( indexes_to_swap, index )
			end
			index = index + 1
		end
		local first = indexes_to_swap[1]
		if not first then return end
		local offset = i - first
		if selected then
			local temp = {}
			for j, index in ipairs( indexes_to_swap ) do
				temp[ j ] = current_actions[ index ]
			end
			local size = #indexes_to_swap
			for j = 1, size - offset do
				current_actions[ indexes_to_swap[ j + offset ] ] = temp[ j ]
			end
			for j = 1, offset do
				current_actions[ indexes_to_swap[ j ] ] = temp[ size - offset + j ]
			end
		else
			if not edit_panel_state.get_autocap_enabled() then
				for j, index in ipairs( indexes_to_swap ) do
					local the_other = index + offset
					if the_other > capacity then
						return
					end
				end
			end
			for j, index in ipairs( indexes_to_swap ) do
				local the_other = index + offset
				local temp = current_actions[ the_other ]
				current_actions[ the_other ] = current_actions[ index ]
				current_actions[ index ] = temp
			end
		end
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_swap_actions" ) )
	end,
	[ shortcuts.override ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		local indexes_to_swap = {}
		local index = 1
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { s, a, u } )
			if s then
				table.insert( indexes_to_swap, index )
			end
			index = index + 1
		end
		local first = indexes_to_swap[1]
		if not first then return end
		local offset = i - first
		if not edit_panel_state.get_autocap_enabled() then
			for j, index in ipairs( indexes_to_swap ) do
				local the_other = index + offset
				if the_other > capacity then
					return
				end
			end
		end
		local selected_actions = {}
		for j, index in ipairs( indexes_to_swap ) do
			selected_actions[ j ] = current_actions[ index ]
		end
		for j, index in ipairs( indexes_to_swap ) do
			current_actions[ index + offset ] = selected_actions[ j ]
			current_actions[ index ] = { false }
		end
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_override_actions" ) )
	end,
	[ shortcuts.select ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { false, a, u } )
		end
		if current_actions[ i ] then
			current_actions[ i ][1] = true
		else
			current_actions[ i ] = { true }
		end
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_select" ) )
	end,
	[ shortcuts.deselect ] = function( edit_panel_state, i, action_id, capacity )
		local current_actions = {}
		for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
			table.insert( current_actions, { s, a, u } )
		end
		if current_actions[ i ] then
			current_actions[ i ][1] = false
		else
			current_actions[ i ] = { false }
		end
		edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_deselect" ) )
	end,
}

function do_real_sprite_action( gui, x, y, i, action_entity, selected )
	if not EntityGetIsAlive( action_entity ) then return end

	local item_comp = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
	if not item_comp then return end

	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	GuiImageButton( gui, next_id(), x, y, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_20x20.png" )

	local sprite_file = ComponentGetValue2( item_comp, "ui_sprite" )
	local world_x, world_y = get_world_position( x, y )
	GameCreateSpriteForXFrames( sprite_file, world_x, world_y, false, 0, 0, 2, true )

	if ComponentGetValue2( item_comp, "permanently_attached" ) then
		GameCreateSpriteForXFrames(
			"data/ui_gfx/inventory/icon_gun_permanent_actions.png", world_x - 2, world_y - 2, false, 0, 0, 2, true
		)
	end
end

function do_panel_action( gui, x, y, i, action_entity, selected )
	local action_id, action_type = "", nil
	local this_action_data, this_action_metadata
	do
		if not EntityGetIsAlive( action_entity ) then goto done	end

		local ia_comp = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemActionComponent" )
		if not ia_comp then goto done end

		action_id = ComponentGetValue2( ia_comp, "action_id" )
		this_action_data, this_action_metadata = action_data[ action_id ], action_metadata[ action_id ]
		action_type = this_action_data.type
	end
	::done::

	local sprite_file = "mods/spell_lab_shugged/files/gui/buttons/empty_spell.png"
	local name, uses_remaining = "", nil
	local is_permanent = false
	do
		if not EntityGetIsAlive( action_entity ) then goto done_2 end

		local item_comp = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
		if not item_comp then goto done_2 end

		sprite_file    = ComponentGetValue2( item_comp, "ui_sprite" )
		name           = ComponentGetValue2( item_comp, "item_name" )
		uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )

		is_permanent = ComponentGetValue2( item_comp, "permanently_attached" )

		if not ModDoesFileExist( sprite_file ) then
			sprite_file = "mods/spell_lab_shugged/files/gui/buttons/missing_sprite.png"
		end
	end
	::done_2::
	
	if is_permanent then
		note = note .. "\n" .. text_get( "spell_box_permanent_tips", shortcut_texts.always_cast )
	end

	local this_action_data     = action_data[ action_id ]
	local this_action_metadata = action_metadata[ action_id ]

	local left_click, right_click, hover = do_action_button( x, y, selected, action_type, sprite_file )
	if this_action_data and this_action_metadata and hover then
		force_do_custom_tooltip( function()
			GuiLayoutBeginVertical( gui, 0, 0 )
			if this_action_data then
				local title = GameTextGetTranslatedOrNot( this_action_data.name )
				if uses_remaining then
					title = ("%s(%s)"):format( title, tostring( uses_remaining ) )
				end
				GuiText( gui, 0, 0, title )
			end

			do_least_tooltip( this_action_data, this_action_metadata )

			local note
			if selected then
				note = text_get( "spell_box_commmon_tips_selected", shortcut_texts.deselect )
			else
				note = text_get( "spell_box_commmon_tips", shortcut_texts.select )
			end
			GuiDimText( gui, 0, 0, note )
			GuiLayoutEnd( gui )
		end, 2, -2, true, x, y, 20 )
	end

	show_uses_remaining( x, y, uses_remaining )
	if is_permanent then
		show_permanent_icon( x, y )
	end

	edit_panel_shortcut_args[1] = i
	if is_permanent then
		detect_shortcuts(
			gui, action_button_shortcuts, shortcut_used_keys, left_click, right_click, hover, edit_panel_shortcut_args
		)
	else
		detect_shortcuts(
			gui, permanent_action_button_shortcuts, shortcut_used_keys, left_click, right_click, hover, edit_panel_shortcut_args
		)
	end
end