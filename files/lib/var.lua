local function find_var_comp( entity_id, var_name )
	local var_comps = EntityGetComponentIncludingDisabled( entity_id, "VariableStorageComponent" )
	if not var_comps or #var_comps == 0 then
		return
	end
	for _, var_comp in ipairs( var_comps ) do
		if ComponentGetValue2( var_comp, "name" ) == var_name then
			return var_comp
		end
	end
end

function get_var_comp( entity_id, var_name )
	local result = find_var_comp( entity_id, var_name )
	if result then
		return result, true
	end
	return EntityAddComponent2( entity_id, "VariableStorageComponent", { name = var_name } ), false
end

function read_var( entity_id, var_name, var_type )
	local var_comp = find_var_comp( entity_id, var_name )
	if var_comp then
		return ComponentGetValue2( var_comp, var_type )
	end
end

function read_and_update_var( entity_id, var_name, var_type, updator )
	local var_comp = find_var_comp( entity_id, var_name )
	local result = ComponentGetValue2( var_comp, var_type )
	if result then
		ComponentSetValue2( var_comp, var_type, updator( result ) )
	end
	return result
end

function replace_var( entity_id, var_name, var_type, new_value )
	local var_comp = find_var_comp( entity_id, var_name )
	local result = ComponentGetValue2( var_comp, var_type )
	ComponentSetValue2( var_comp, var_type, new_value )
	return result
end

function get_and_update_var( entity_id, var_name, var_type, update_fn, default_old_value )
	local var_comp, exists = get_var_comp( entity_id, var_name )
	local result = exists and ComponentGetValue2( var_comp, var_type ) or default_old_value
	ComponentSetValue2( var_comp, var_type, update_fn( result ) )
	return result
end

function write_var( entity_id, var_name, var_type, value )
	ComponentSetValue2( get_var_comp( entity_id, var_name ), var_type, value )
end

local unique_thing = {}
local vars_access_mt = {
	__index = function( t, k )
		local comp, type = unpack( rawget( t, 1 )[ k ] )
		return ComponentGetValue2( comp, type )
	end,
	__newindex = function( t, k, v )
		local comp, type = unpack( rawget( t, 1 )[ k ] )
		ComponentSetValue2( comp, type, v )
	end,
}

function access_vars( entity_id, var_map, var_name_prefix )
	local var_comps = {}
	for var_name, var_type in pairs( var_map ) do
		var_comps[ var_name ] = { get_var_comp( entity_id, var_name_prefix .. var_name ), var_type }
	end
	return setmetatable( { var_comps }, vars_access_mt )
end