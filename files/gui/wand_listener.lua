local function get_all_wands_in_inventory()
	if not player then return {} end
	local children = EntityGetAllChildren( player ) or {}
	for key,child in pairs( children ) do
		if EntityGetName( child ) == "inventory_quick" then
			return EntityGetAllChildren( child, "wand" )
		end
	end
end
for _, wand_id in ipairs( get_all_wands_in_inventory() or {} ) do
	local edit_panel_state = access_edit_panel_state( wand_id )
	if not edit_panel_state.get_force_compact_enabled() then return end
	local current_state = edit_panel_state.get()
	local current_permanent_state = edit_panel_state.get_permanent()
	local new_state_table, new_permanent_table = read_state_table_from_wand( wand_id )
	local diff = false

	local i = 1
	local permanent_state_iter_func = state_str_iter_permanent_actions( current_permanent_state )
	local new_permanent = new_permanent_table[ i ]
	local pa = permanent_state_iter_func()
	while new_permanent ~= nil or pa ~= nil do
		if new_permanent ~= pa then
			diff = true
			break
		end
		i = i + 1
		new_permanent = new_permanent_table[ i ]
		pa = permanent_state_iter_func()
	end

	if not diff then
		local j = 1
		local state_iter_func = state_str_iter_actions( current_state )
		local new = new_state_table[ j ]
		local s, a, u = state_iter_func()
		while new ~= nil or s ~= nil do
			if new then
				-- both are just sth like !(a == null ? b == null : a.equals(b))
				-- or more apparently, if a ~= null then return a ~= b else return b ~= null end
				if new[2] ~= nil then
					if new[2] ~= a then
						diff = true
						break
					end
				elseif a and a ~= "" then
					diff = true
					break
				end
				if new[3] ~= nil then
					if new[3] ~= tonumber( u ) then
						diff = true
						break
					end
				else
					if u and u ~= "" then
						diff = true
						break
					end
				end
			else
				if a and a ~= "" then
					diff = true
					break
				end
			end
			j = j + 1
			new = new_state_table[ j ]
			s, a, u = state_iter_func()
		end
	end

	if diff then
		edit_panel_state.set_both( table_to_state_str( new_state_table ), permanent_table_to_state_str( new_permanent_table ), wrap_key( "operation_read_from_wand" ) )
	end
end