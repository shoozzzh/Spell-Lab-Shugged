dofile_once( "mods/spell_lab_shugged/files/lib/var.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/stream.lua" )
local smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )
local polytools = dofile_once( "mods/spell_lab_shugged/files/lib/polytools/polytools.lua" )

local edit_panel_api = {}

local var_name_prefix = "spell_lab_shugged."
local tag_init = "spell_lab_shugged.edit_panel_init"
local tag_dumping = "spell_lab_shugged.dumping_this_wand"
local tag_history = "spell_lab_shugged.history"
local vfile_wand_id = "mods/spell_lab_shugged/vfiles/load_to_this_wand.txt"

local function create_action( action_id, uses_remaining )
	local action = CreateItemActionEntity( action_id )
	EntitySetComponentsWithTagEnabled( action, "enabled_in_world", false )

	if not uses_remaining then return end

	local max_uses = action_data[ data[1] ].max_uses
	if not max_uses or max_uses <= 0 then return end

	local never_unlimited = action_data[ data[1] ].never_unlimited
	if world_state_unlimited_spells and not never_unlimited then return end

	local item_comp = EntityGetFirstComponentIncludingDisabled( action, "ItemComponent" )
	ComponentSetValue2( item_comp, "uses_remaining", uses_remaining )
end

local function delete_action( action_entity )
	EntityRemoveFromParent( action_entity )
	EntityKill( action_entity )
end

local function dump_selection( selection )
	local str = {}
	for slot, _ in pairs( selection ) do
		if selection[ slot ] then
			str[ #str + 1 ] = tostring( slot )
		end
	end
	return table.concat( str, "," )
end

local function load_selection( selection_str )
	local selection = {}
	for str in selection_str:gmatch( "([^,]+)," ) do
		selection[ tonumber( str ) ] = true
	end
	return selection
end

local function stream_actions( wand_id )
	return stream( EntityGetAllChildren( wand_id ) or {} )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemComponent" ) ~= nil end )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemActionComponent" ) ~= nil end )
end

local var_map = {
	row_offset            = "value_int",
	current_history_index = "value_int",
	autocap_enabled       = "value_bool",
	force_compact_enabled = "value_bool",
	selection             = "value_string",
}

local data_access_funcs = {}

local function get_histories( wand_id )
	return EntityGetComponentIncludingDisabled( wand_id, "ItemChestComponent", tag_history ) or {}
end

local history_lens
do
	local history_layout = {
		index          = "level",
		state_str      = "actions",
		selection_str  = "action_uses_remaining",
		operation_name = "other_entities_to_spawn",
	}
	
	local history_lens_mt = {
		__call = function( lens, comp )
			rawset( lens, 1, comp )
			return lens
		end,
		__index = function( lens, key )
			return ComponentGetValue2( rawget( lens, 1 ), history_layout[ key ] )
		end,
		__newindex = function( lens, key, value )
			ComponentSetValue2( rawget( lens, 1 ), history_layout[ key ], value )
		end,
	}
	history_lens = setmetatable( {}, history_lens_mt )
end

function data_access_funcs:new_state_history( operation_name, state_str, selection_str )
	local limit = math.max( mod_setting_get( "wand_edit_panel_history_limit" ), 1 )
	local max_index, current_index = #get_histories( self.entity ), self.vars.current_history_index

	if current_index ~= max_index then
		for _, history_comp in ipairs( get_histories( self.entity ) ) do
			if history_lens( history_comp ).index > current_index then
				EntityRemoveComponent( self.entity, history_comp )
			end
		end
		max_index = current_index
	end

	local index = max_index + 1

	local overflow = index - limit
	if overflow > 0 then
		for _, history_comp in ipairs( get_histories( self.entity ) ) do
			local idx = history_lens( history_comp ).index
			if idx > overflow then
				history_lens( history_comp ).index = idx - overflow
			else
				EntityRemoveComponent( self.entity, history_comp )
			end
		end
		new_index = limit
	end

	local history = history_lens( EntityAddComponent2( self.entity, "ItemChestComponent", {
		_tags = tag_history,
		_enabled = false,
	} ) )

	history.index          = index
	history.state_str      = state_str
	history.selection_str  = selection_str
	history.operation_name = operation_name

	self.vars.current_history_index = index
end

function data_access_funcs:get_selection()
	return load_selection( self.vars.selection )
end

function data_access_funcs:get_state_history( index )
	for _, history_comp in ipairs( get_histories( self.entity ) ) do
		if history_lens( history_comp ).index == index then
			return history_comp
		end
	end
end

function data_access_funcs:undo()
	if self.vars.current_history_index == 1 then return end
	self.vars.current_history_index = self.vars.current_history_index - 1
	local history_comp = self:get_state_history( self.vars.current_history_index )
	edit_panel_api.load_state( wand_id, history_lens( history_comp ).state_str )
	self.vars.selection_str = history_lens( history_comp ).selection_str
end

function data_access_funcs:redo()
	if self.vars.current_history_index == #get_histories( self.entity ) then return end
	self.vars.current_history_index = self.vars.current_history_index + 1
	local history_comp = self:get_state_history( self.vars.current_history_index )
	edit_panel_api.load_state( wand_id, history_lens( history_comp ).state_str )
	self.vars.selection_str = history_lens( history_comp ).selection_str
end

function data_access_funcs:peek_undo()
	if self.vars.current_history_index == 1 then return nil end
	return history_lens( self:get_state_history( self.vars.current_history_index ) ).operation_name
end

function data_access_funcs:peek_redo()
	if self.vars.current_history_index == #get_histories( self.entity ) then return nil end
	return history_lens( self:get_state_history( self.vars.current_history_index + 1 ) ).operation_name
end

function data_access_funcs:get_capacity()
	return EntityGetWandCapacity( self.entity )
end

function data_access_funcs:get_num_permannt_actions()
	return WANDS.wand_get_stat( self.entity, "deck_capacity" ) - self:get_capacity()
end

data_access_funcs.__index = data_access_funcs

function edit_panel_api.access_data( wand_id )
	local data_init = not EntityAddTag( entity_id, tag_init )

	if data_init then
		EntityLoadToEntity( "mods/spell_lab_shugged/files/entities/wand_data_holder.xml", wand_id )
		EntityAddTag( entity_id, tag_init )
	end

	local data = setmetatable( {
		vars = access_vars( wand_id, var_map, var_name_prefix ),
		entity = wand_id,
	}, data_access_funcs )

	if data_init then
		data:new_state_history(
			wrap_key( "operation_read_from_wand" ), edit_panel_api.dump_state( wand_id ), data.vars.selection
		)
	end

	return data
end

edit_panel_api.access_data = memoize( edit_panel_api.access_data )

function edit_panel_api.dump_state( wand_id )
	if EntityHasTag( wand_id, tag_dumping ) then
		error( ("The wand with id %s has already been dumped at frame %d!"):format( wand_id, GameGetFrameNum() ) )
	end
	EntityAddTag( wand_id, tag_dumping )
	print( ("dumping wand %d at frame %d"):format( wand_id, GameGetFrameNum() ) )

	local state_entity = EntityCreateNew()
	EntityAddComponent2( state_entity, "VariableStorageComponent", { value_int = wand_id } )
	EntityAddComponent2( state_entity, "LuaComponent", {
		script_source_file = "mods/spell_lab_shugged/files/entities/return_actions.lua",
		execute_every_n_frame = -1,
		execute_on_added = true,
		execute_on_removed = true,
		mNextExecutionTime = now,
	} )
	EntityAddComponent2( state_entity, "LifetimeComponent", {
		lifetime = 1,
		serialize_duration = true,
	} )

	stream_actions( wand_id ).foreach( function( a )
		EntityRemoveFromParent( a )
		EntityAddChild( state_entity, a )
	end )

	return polytools.save( state_entity )
end

function edit_panel_api.load_state( wand_id, state )
	stream_actions( wand_id ).foreach( delete_action )

	ModTextFileSetContent( vfile_wand_id, tostring( wand_id ) )

	polytools.load( EntityCreateNew(), state )
end

local permanent_section_mt = {}
function permanent_section_mt:apply_changes( changes )
	for _, i in ipairs( changes.removal ) do
		delete_action( self[ i ] )
		self[ i ] = nil
	end

	local temp = {}
	for k, v in pairs( changes.reordering ) do
		temp[ k ] = self[ k ]
		self[ k ] = nil
	end
	for old_idx, new_idx in pairs( changes.reordering ) do
		self[ new_idx ] = temp[ old_idx ]
	end

	for _, data in ipairs( changes.addition ) do
		local idx, action_id, uses_remaining = unpack( data )
		if self[ idx ] ~= nil then
			error( ("trying to create action %s at %d but that slot has been already taken!"):format( action_id, idx ) )
		end
		self[ idx ] = create_action( action_id, uses_remaining )
	end

	if #self == 0 then return end
	local wand_id = EntityGetParent( self[1] )
	local x, y = EntityGetTransform( wand_id )

	for _, a in pairs( self ) do
		EntityRemoveFromParent( a )
	end
	for i = 1, maxn( self ) do
		local a = self[ i ]
		if a then
			EntityAddChild( wand_id, a )
			EntitySetTransform( a, x, y )

			local item_comp = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
			ComponentSetValue2( item_comp, "permanently_attached", true )
		end
	end
end
permanent_section_mt.__index = permanent_section_mt

local common_section_mt = {}
function common_section_mt:apply_changes( changes )
	for _, i in ipairs( changes.removal ) do
		delete_action( self[ i ] )
		self[ i ] = nil
	end

	local temp = {}
	for k, v in pairs( changes.reordering ) do
		temp[ k ] = self[ k ]
		self[ k ] = nil
	end
	for old_idx, new_idx in pairs( changes.reordering ) do
		self[ new_idx ] = temp[ old_idx ]
	end

	for _, data in ipairs( changes.addition ) do
		local idx, action_id, uses_remaining = unpack( data )
		if self[ idx ] ~= nil then
			error( ("trying to create action %s at %d but that slot has been already taken!"):format( action_id, idx ) )
		end
		self[ idx ] = create_action( action_id, uses_remaining )
	end
	
	local wand_id
	for _, first in pairs( self ) do
		wand_id = EntityGetParent( first )
		break
	end
	if wand_id == nil then return end
	local x, y = EntityGetTransform( wand_id )

	for idx, a in pairs( self ) do
		EntitySetTransform( a, x, y )
		EntityAddChild( wand_id, a )
		local item_comp = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
		ComponentSetValue2( item_comp, "inventory_slot", idx - 1, 0 )
	end
end
common_section_mt.__index = common_section_mt

function edit_panel_api.access_actions( wand_id )
	local common = {}
	local permanent = {}

	stream_actions( wand_id )
		.foreach( function( a )
			local item_comp = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )

			if ComponentGetValue2( item_comp, "permanently_attached" ) then
				permanent[ #permanent + 1 ] = a
				return
			end

			local x, _ = ComponentGetValue2( item_comp, "inventory_slot" )
			common[ x + 1 ] = a
		end )

	setmetatable( common, common_section_mt )
	setmetatable( permanent, permanent_section_mt )

	return { common = common, permanent = permanent }
end

function edit_panel_api.do_operation( data, actions, operation )
	if operation.selection then
		data.vars.selection = dump_selection( operation.selection )
	end
	if operation.common then
		actions.common:apply_changes( unpack( operation.common ) )
	end
	if operation.permanent then
		actions.permanent:apply_changes( unpack( operation.permanent ) )
	end
	
	data:new_state_history( edit_panel_api.dump_state( data.entity ), data.vars.selection, operation.name )
end

return edit_panel_api