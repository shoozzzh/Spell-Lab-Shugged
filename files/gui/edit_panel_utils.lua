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