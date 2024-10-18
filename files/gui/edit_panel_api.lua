local edit_panel_access_cache = {}
function access_edit_panel_state( wand_id, dont_cache )
	local cache = edit_panel_access_cache[ wand_id ]
	if cache then
		return cache
	end
	local result = access_edit_panel_state_impl( wand_id )
	if not dont_cache then
		edit_panel_access_cache[ wand_id ] = result
	end
	return result
end

function read_state_table_from_wand( wand_id )
	local actions, permanent_actions = WANDS.wand_get_actions_absolute( wand_id )
	local _actions = {}
	for i = 0, maxn( actions ) do
		local a = actions[ i ]
		if a then
			local uses_remaining
			local this_action_data = action_data[ a.action_id ]
			if this_action_data.max_uses and this_action_data.max_uses ~= -1  then -- don't give it a -1 pls
				if world_state_unlimited_spells and not this_action_data.never_unlimited then -- Should be unlimited, but being limited
					uses_remaining = nil
				elseif a.uses_remaining == -1 then -- Should be limited, but being unlimited
					uses_remaining = this_action_data.max_uses
				else -- just normal case
					uses_remaining = a.uses_remaining
				end
			else
				uses_remaining = nil
			end
			_actions[ i + 1 ] = { false, a.action_id, uses_remaining }
		else
			_actions[ i + 1 ] = { false }
		end
	end
	local _permanent_actions = {}
	for i, a in ipairs( permanent_actions ) do
		table.insert( _permanent_actions, a.action_id )
	end
	return _actions, _permanent_actions
end

function read_state_from_wand( wand_id )
	local a, pa = read_state_table_from_wand( wand_id )
	return table_to_state_str( a ), permanent_table_to_state_str( pa )
end

function access_edit_panel_state_impl( wand_id )
	local row_offset_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_row_offset" ) or
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_row_offset",
			value_int = 0,
		} )
	local history_max_index_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_history_max_index" ) or
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_history_max_index",
			value_int = 0,
		} )
	local current_history_index_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_current_history_index" ) or
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_current_history_index",
			value_int = 0,
		} )
	local function get_all_history_comps()
		return EntityGetComponentIncludingDisabled( wand_id, "VariableStorageComponent", "spell_lab_shugged_edit_panel_history" ) or {}
	end
	local function new_state_history( new_state, new_permanent_state, operation_name )
		local history_limit = math.max( mod_setting_get( "wand_edit_panel_history_limit" ), 1 )
		local history_max_index = ComponentGetValue2( history_max_index_comp, "value_int" )
		local current_history_index = ComponentGetValue2( current_history_index_comp, "value_int" )
		if current_history_index ~= history_max_index then
			for _, history_comp in ipairs( get_all_history_comps() ) do
				if ComponentGetValue2( history_comp, "value_int" ) > current_history_index then
					EntityRemoveComponent( wand_id, history_comp )
				end
			end
			history_max_index = current_history_index
		end
		local new_history_index = history_max_index + 1
		local offset = new_history_index - history_limit
		if offset > 0 then
			for _, history_comp in ipairs( get_all_history_comps() ) do
				local index = ComponentGetValue2( history_comp, "value_int" )
				if index > offset then
					ComponentSetValue2( history_comp, "value_int", index - offset )
				else
					EntityRemoveComponent( wand_id, history_comp )
				end
			end
			new_history_index = history_limit
		end
		local include_permanent = new_permanent_state and new_permanent_state ~= ""
		if include_permanent then
			new_state = string.format( "%s|%s", new_state, new_permanent_state )
		end
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "spell_lab_shugged_edit_panel_history",
			name = operation_name,
			value_int = new_history_index,
			value_string = new_state,
			value_bool = include_permanent,
		} )
		ComponentSetValue2( history_max_index_comp, "value_int", new_history_index )
		ComponentSetValue2( current_history_index_comp, "value_int", new_history_index )
	end
	local data_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel" )
	local permanent_data_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_permanent" )
	if not data_comp or not permanent_data_comp then
		local state_str, permanent_state_str = read_state_from_wand( wand_id )
		data_comp = EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel",
			value_string = state_str,
		} )
		permanent_data_comp = EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_permanent",
			value_string = permanent_state_str,
		} )

		new_state_history( state_str, permanent_state_str, wrap_key( "operation_read_from_wand" ) )
	end
	local autocap_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_autocap_enabled" ) or
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_autocap_enabled",
			value_bool = false,
		} )
	local force_compact_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_force_compact_enabled" ) or
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_force_compact_enabled",
			value_bool = false,
		} )
	local sync_flag_comp = get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_sync_flag" ) or
		EntityAddComponent2( wand_id, "VariableStorageComponent", {
			_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
			name = "spell_lab_shugged_edit_panel_sync_flag",
			value_bool = false,
		} )
	local function get_saved_state_history( index )
		for _, history_comp in ipairs( get_all_history_comps() ) do
			if ComponentGetValue2( history_comp, "value_int" ) == index then
				return ComponentGetValue2( history_comp, "value_bool" ), ComponentGetValue2( history_comp, "value_string" ), ComponentGetValue2( history_comp, "name" )
			end
		end
	end
	local function use_history_state( include_permanent, history_state )
		local history_permanent_state = nil
		if include_permanent then
			history_state, history_permanent_state = string.match( history_state, "([^|]*)|([^|]*)" )
		end
		-- who cares about uses of permanent actions
		ComponentSetValue2( permanent_data_comp, "value_string", history_permanent_state or "" )
		local history_actions = {}
		for s, a, u in state_str_iter_actions( history_state ) do
			local this_action_data = action_data[ a ]
			if not this_action_data then
				u = nil
			elseif this_action_data.max_uses then
				if world_state_unlimited_spells and not this_action_data.never_unlimited then
					u = nil
				elseif not u or u == "" then
					u = this_action_data.max_uses
				end
			end
			table.insert( history_actions, { s, a, u } )
		end
		ComponentSetValue2( data_comp, "value_string", table_to_state_str( history_actions ) )
		ComponentSetValue2( sync_flag_comp, "value_bool", true )
	end
	return {
		get = function()
			return ComponentGetValue2( data_comp, "value_string" )
		end,
		set = function( new_state, operation_name )
			while string.sub( new_state, -3, -1 ) == ",:," do
				new_state = string.sub( new_state, 1, -3 )
			end
			ComponentSetValue2( data_comp, "value_string", new_state )
			ComponentSetValue2( sync_flag_comp, "value_bool", true )

			new_state_history( new_state, nil, operation_name )
		end,
		get_permanent = function()
			return ComponentGetValue2( permanent_data_comp, "value_string" )
		end,
		set_both = function( new_state, new_permanent_state, operation_name )
			while string.sub( new_state, -3, -1 ) == ",:," do
				new_state = string.sub( new_state, 1, -3 )
			end
			while string.sub( new_permanent_state, -2, -1 ) == ",," do
				new_permanent_state = string.sub( new_permanent_state, 1, -2 )
			end
			ComponentSetValue2( data_comp, "value_string", new_state )
			ComponentSetValue2( permanent_data_comp, "value_string", new_permanent_state )
			ComponentSetValue2( sync_flag_comp, "value_bool", true )

			new_state_history( new_state, new_permanent_state, operation_name )
		end,
		need_sync = function()
			return ComponentGetValue2( sync_flag_comp, "value_bool" )
		end,
		force_sync = function()
			ComponentSetValue2( sync_flag_comp, "value_bool", true )
		end,
		done_sync = function()
			ComponentSetValue2( sync_flag_comp, "value_bool", false )
		end,
		undo = function()
			local current_history_index = ComponentGetValue2( current_history_index_comp, "value_int" )
			if current_history_index == 1 then return end
			current_history_index = current_history_index - 1
			ComponentSetValue2( current_history_index_comp, "value_int", current_history_index )

			local include_permanent, history_state = get_saved_state_history( current_history_index )
			use_history_state( include_permanent, history_state )
		end,
		redo = function()
			local current_history_index = ComponentGetValue2( current_history_index_comp, "value_int" )
			if current_history_index == ComponentGetValue2( history_max_index_comp, "value_int" ) then return end
			current_history_index = current_history_index + 1
			ComponentSetValue2( current_history_index_comp, "value_int", current_history_index )

			local include_permanent, history_state = get_saved_state_history( current_history_index )
			use_history_state( include_permanent, history_state )
		end,
		peek_undo = function()
			local current_history_index = ComponentGetValue2( current_history_index_comp, "value_int" )
			if current_history_index == 1 then return nil end
			local _, _, operation_name = get_saved_state_history( current_history_index )
			return operation_name
		end,
		peek_redo = function()
			local current_history_index = ComponentGetValue2( current_history_index_comp, "value_int" )
			if current_history_index == ComponentGetValue2( history_max_index_comp, "value_int" ) then return nil end
			local _, _, operation_name = get_saved_state_history( current_history_index + 1 )
			return operation_name
		end,
		get_current_history_index = function()
			local current_history_index = ComponentGetValue2( current_history_index_comp, "value_int" )
			local history_max_index     = ComponentGetValue2( history_max_index_comp, "value_int" )
			return current_history_index, history_max_index
		end,
		get_offset = function()
			return ComponentGetValue2( row_offset_comp, "value_int" )
		end,
		set_offset = function( row_offset )
			ComponentSetValue2( row_offset_comp, "value_int", row_offset )
		end,
		get_autocap_enabled = function()
			return ComponentGetValue2( autocap_comp, "value_bool" )
		end,
		set_autocap_enabled = function( enabled )
			ComponentSetValue2( autocap_comp, "value_bool", enabled )
		end,
		get_force_compact_enabled = function()
			return ComponentGetValue2( force_compact_comp, "value_bool" )
		end,
		set_force_compact_enabled = function( enabled )
			ComponentSetValue2( force_compact_comp, "value_bool", enabled )
		end,
	}
end
function table_to_state_str( t )
	local maxnt = maxn( t )
	if maxnt == -1 then return "" end
	for i = 1, maxnt do
		if t[ i ] then
			t[ i ] = format_action_str( t[ i ][1], t[ i ][2], t[ i ][3] )
		else
			t[ i ] = ":,"
		end
	end
	return table.concat( t )
end
function permanent_table_to_state_str( t )
	if #t == 0 then return "" end
	return table.concat( t, "," ) .. ","
end
function state_str_iter_actions( state_str )
	local f = string.gmatch( state_str, "(@?)([^,%:]*)%:(-?%d*)," )
	return function()
		local s, a, u = f()
		if u == -1 then
			u = nil
		end
		return s and s ~= "", a, u
	end
end
function state_str_iter_permanent_actions( state_str )
	return string.gmatch( state_str, "([^,]*)," )
end
function format_action_str( selected, action_id, uses_remaining )
	if uses_remaining == nil or uses_remaining == -1 then
		uses_remaining = ""
	end
	return string.format( "%s%s:%s,", ( selected and selected ~= "" ) and "@" or "", action_id or "", tostring( uses_remaining or "" ) )
end
function reload_state_for_wand( wand_id )
	edit_panel_access_cache[ wand_id ] = nil
	EntityRemoveComponent( wand_id, get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel" ) )
	EntityRemoveComponent( wand_id, get_variable_storage_component( wand_id, "spell_lab_shugged_edit_panel_permanent" ) )
end