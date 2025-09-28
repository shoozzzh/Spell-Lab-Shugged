dofile_once( "mods/spell_lab_shugged/files/lib/var.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" )
local smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )
local polytools = dofile_once( "mods/spell_lab_shugged/files/lib/polytools/polytools.lua" )

local edit_panel_api = {}

local var_name_prefix = "spell_lab_shugged."

local function view_actions( wand_id )
	local permanent = {}
	local common = {}

	for i, a in ipairs( EntityGetAllChildren( wand_id ) or {} ) do
		local item_comp = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
		local ia_comp   = EntityGetFirstComponentIncludingDisabled( a, "ItemActionComponent" )
		if not item_comp or not ia_comp then goto continue end

		local action_id = ComponentGetValue2( ia_comp, "action_id" )
		if action_id == "" then goto continue end

		local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
		local index
		if ComponentGetValue2( item_comp, "permanently_attached" ) then
			permanent[ #permanent + 1 ] = { action_id, uses_remaining }
		else
			local x, _ = ComponentGetValue2( item_comp, "inventory_slot" )
			if common[ x ] ~= nil then
				local pos = common[ x ]
				pos[ #pos + 1 ] = action_id
				pos[ #pos + 1 ] = uses_remaining
			end
			common[ x ] = { action_id, uses_remaining }
		end

		::continue::
	end
	return { permanent = permanent, common = common }
end

local cached_wand_snapshots = {}

function edit_panel_api.listen_wand_changes()
	local wands_to_listen
	local wand_listener_type = mod_setting_get( "wand_listener_type" )
	if wand_listener_type == "INV" then
		wands_to_listen = get_all_wands_in_inventory()
	elseif wand_listener_type == "HAND" then
		wands_to_listen = { held_wand }
	elseif wand_listener_type == "PANEL" then
		if mod_setting_get( "show_wand_edit_panel" ) then
			wands_to_listen = { held_wand }
		end
	else
		GamePrint( "Something is very wrong!" )
		GamePrintImportant( "Something is very wrong!" )
		print( "Something is very wrong!" )
	end

	for _, wand_id in ipairs( wands_to_listen or {} ) do
		local cached = cached_wand_snapshots[ wand_id ]
		local new = view_actions( wand_id )
	
		if deep_equals( cached, new ) then goto continue end
		cached_wand_snapshots[ wand_id ] = new
		if cached == nil then goto continue end
		if EntityHasTag( wand_id, EditPanelTags.UncachedChanges ) then
			EntityRemoveTag( wand_id, EditPanelTags.UncachedChanges )
			goto continue
		end
		-- if data.vars.force_compact_enabled then goto continue end
		local data = edit_panel_api.access_data( wand_id )
		data:record_new_history( wrap_key( "operation_read_from_wand" ) )
	
		::continue::
	end
	
	for wand_id, _ in pairs( cached_wand_snapshots ) do
		if not EntityGetIsAlive( wand_id ) then
			cached_wand_snapshots[ wand_id ] = nil
		end
	end
end

function edit_panel_api.get_histories( wand_id )
	return EntityGetComponentIncludingDisabled( wand_id, "VariableStorageComponent", EditPanelTags.History ) or {}
end

local var_map = {
	row_offset            = "value_int",
	current_history_index = "value_int",
	autocap_enabled       = "value_bool",
	force_compact_enabled = "value_bool",
}

local selection_var_map = {
	range_start  = "value_int",
	range_end    = "value_int",
	section_name = "value_string",
}

local data_access_funcs = new_prototype()

local history_lens
do
	local history_layout = {
		index          = "value_int",
		state          = "value_string",
		operation_name = "name",
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

function data_access_funcs:record_new_history( operation_name )
	if EntityHasTag( wand_id, EditPanelTags.Recording ) then
		print_error( ("The wand with id %s has already been dumped at frame %d!"):format( wand_id, GameGetFrameNum() ) )
		return
	end
	EntityAddTag( wand_id, EditPanelTags.Recording )

	local limit = math.max( tonumber( mod_setting_get( "wand_edit_panel_history_limit" ) ) or 1 , 1 )
	local max_index, current_index = #edit_panel_api.get_histories( self.entity ), self.vars.current_history_index

	if current_index ~= max_index then
		for _, history_comp in ipairs( edit_panel_api.get_histories( self.entity ) ) do
			if history_lens( history_comp ).index > current_index then
				EntityRemoveComponent( self.entity, history_comp )
			end
		end
		max_index = current_index
	end

	local index = max_index + 1

	local overflow = index - limit
	if overflow > 0 then
		for _, history_comp in ipairs( edit_panel_api.get_histories( self.entity ) ) do
			local idx = history_lens( history_comp ).index
			if idx > overflow then
				history_lens( history_comp ).index = idx - overflow
			else
				EntityRemoveComponent( self.entity, history_comp )
			end
		end
		index = limit
	end

	local history = history_lens( EntityAddComponent2( self.entity, "VariableStorageComponent", {
		_tags = EditPanelTags.History,
	} ) )

	history.index          = index
	history.operation_name = operation_name
	history.state          = edit_panel_api.dump_state( self.entity )

	self.vars.current_history_index = index
end

function data_access_funcs:get_selection()
	return self.selection.section_name, self.selection.range_start, self.selection.range_end
end

function data_access_funcs:get_state_history( index )
	for _, history_comp in ipairs( edit_panel_api.get_histories( self.entity ) ) do
		if history_lens( history_comp ).index == index then
			return history_comp
		end
	end
end

function data_access_funcs:undo()
	if self.vars.current_history_index == 1 then return end
	self.vars.current_history_index = self.vars.current_history_index - 1
	local history_comp = self:get_state_history( self.vars.current_history_index )
	edit_panel_api.load_state( self.entity, history_lens( history_comp ).state )
end

function data_access_funcs:redo()
	if self.vars.current_history_index == #edit_panel_api.get_histories( self.entity ) then return end
	self.vars.current_history_index = self.vars.current_history_index + 1
	local history_comp = self:get_state_history( self.vars.current_history_index )
	edit_panel_api.load_state( self.entity, history_lens( history_comp ).state )
end

function data_access_funcs:peek_undo()
	if self.vars.current_history_index == 1 then return nil end
	return history_lens( self:get_state_history( self.vars.current_history_index ) ).operation_name
end

function data_access_funcs:peek_redo()
	if self.vars.current_history_index == #edit_panel_api.get_histories( self.entity ) then return nil end
	return history_lens( self:get_state_history( self.vars.current_history_index + 1 ) ).operation_name
end

function data_access_funcs:get_capacity()
	if self.vars.autocap_enabled then
		return math.huge
	else
		return EntityGetWandCapacity( self.entity )
	end 
end

function data_access_funcs:get_num_permannt_actions()
	return WANDS.wand_get_stat( self.entity, "deck_capacity" ) - EntityGetWandCapacity( self.entity )
end

function edit_panel_api.access_data( wand_id )
	local data = setmetatable( {
		vars = access_vars( wand_id, var_map, var_name_prefix ),
		selection = access_vars( wand_id, selection_var_map, var_name_prefix ),
		entity = wand_id,
	}, data_access_funcs )

	if not EntityHasTag( wand_id, EditPanelTags.Init ) then
		EntityAddTag( wand_id, EditPanelTags.Init )
		data:record_new_history( wrap_key( "operation_read_from_wand" ) )
	end

	return data
end

edit_panel_api.access_data = memoize( edit_panel_api.access_data )

function edit_panel_api.dump_state( wand_id )
	local state_entity = EntityCreateNew( tostring( wand_id ) ) -- use name to pass wand_id when dumping

	stream_actions( wand_id ).foreach( function( a )
		EntityRemoveFromParent( a )
		EntityAddChild( state_entity, a )
	end )

	-- use this child to run script
	-- because when de-polymorphing, children are spawned in after the parent does
	-- when state entity is just spawned in, triggering the execute_on_added on it
	-- the action children have not been spawned in yet
	local script_child = EntityCreateNew()
	local script = EntityAddComponent2( script_child, "LuaComponent", {
		script_source_file = "mods/spell_lab_shugged/files/entities/return_actions.lua",
		execute_every_n_frame = -1,
	} )
	ComponentSetValue2( script, "execute_on_added", true ) -- make it so it won't run right now
	EntityAddChild( state_entity, script_child )

	-- this doesn't immediately do polymorphing
	-- but generates the serialized data and marks the state entity and its children as dead
	local poly_effect = LoadGameEffectEntityTo( state_entity, "mods/spell_lab_shugged/files/entities/poly_serializer.xml" )

	ModTextFileSetContent_Saved( VFiles.FinishingDumping, "1" )

	local result = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( poly_effect, "GameEffectComponent" ), "mSerializedData" )
	return result
end

function edit_panel_api.load_state( wand_id, state )
	EntityAddTag( wand_id, EditPanelTags.UncachedChanges )
	stream_actions( wand_id ).foreach( delete_action )

	ModTextFileSetContent_Saved( VFiles.WandId, tostring( wand_id ) )

	polytools.load( EntityCreateNew(), state )
end

-- must provide: take( at ), put( action, at )
local abstract_section_mt = new_prototype()

function abstract_section_mt:take_range( range_start, range_end )
	local taken = {}
	for i = range_start, range_end do
		taken[ #taken + 1 ] = self:take( i )
	end
	return taken
end

function abstract_section_mt:put_range( actions, range_start )
	for idx, a in pairs( actions ) do
		self:put( a, idx + range_start - 1 )
	end
end

function abstract_section_mt:reorder( idx_map )
	local temp = {}
	for old_idx, _ in pairs( idx_map ) do
		temp[ k ] = self:take( k )
	end
	for old_idx, new_idx in pairs( idx_map ) do
		self:put( temp[ old_idx ], new_idx )
	end
end

function abstract_section_mt:swap( index_1, index_2 )
	self[ index_1 ], self[ index_2 ] = self[ index_2 ], self[ index_1 ]
end

function abstract_section_mt:on_changed() end

function abstract_section_mt:insert_space( range_start, range_end )
	local size = range_end - range_start + 1
	for i = maxn( self ), range_start, -1 do
		self:swap( i, i + size )
	end
end

function abstract_section_mt:trim_space( range_start, range_end )
	local size = range_end - range_start + 1
	for i = range_end, maxn( self ) do
		self:swap( i, i - size )
	end
end

local permanent_section_mt = new_prototype( abstract_section_mt )

function permanent_section_mt:take( at )
	local taken = self[ at ]
	if not taken then return nil end

	EntityRemoveFromParent( taken )
	local item_comp = EntityGetFirstComponentIncludingDisabled( taken, "ItemComponent" )
	ComponentSetValue2( item_comp, "inventory_slot", 0, 0 )
	ComponentSetValue2( item_comp, "permanently_attached", false )
	self[ at ] = nil

	return taken
end

function permanent_section_mt:put( action, at )
	if self[ i ] then
		print_error( ("trying to put action %d at index %d but it's not empty there!"):format( action, at ) )
		return
	end

	EntityRemoveFromParent( action )
	EntityAddChild( self.wand, action )
	local item_comp = EntityGetFirstComponentIncludingDisabled( action, "ItemComponent" )
	ComponentSetValue2( item_comp, "permanently_attached", true )
	local x, y = EntityGetTransform( self.wand )
	EntitySetTransform( a, x, y )
	self[ at ] = action
end

function permanent_section_mt:on_changed()
	local x, y = EntityGetTransform( self.wand )

	for _, a in ipairs( self ) do
		EntityRemoveFromParent( a )
	end
	for _, a in ipairs( self ) do
		EntityAddChild( self.wand, a )
		EntitySetTransform( a, x, y )

		local item_comp = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
		ComponentSetValue2( item_comp, "permanently_attached", true )
	end
end

local common_section_mt = new_prototype( abstract_section_mt )

function common_section_mt:take( at )
	local taken = self[ at ]
	if not taken then return nil end

	EntityRemoveFromParent( taken )
	local item_comp = EntityGetFirstComponentIncludingDisabled( taken, "ItemComponent" )
	ComponentSetValue2( item_comp, "inventory_slot", 0, 0 )
	self[ at ] = nil

	return taken
end

function common_section_mt:put( action, at )
	if self[ i ] then
		print_error( ("trying to put action %d at index %d but it's not empty there!"):format( action, at ) )
		return
	end

	EntityRemoveFromParent( action )
	EntityAddChild( self.wand, action )
	local x, y = EntityGetTransform( self.wand )
	EntitySetTransform( action, x, y )
	local item_comp = EntityGetFirstComponentIncludingDisabled( action, "ItemComponent" )
	ComponentSetValue2( item_comp, "inventory_slot", at - 1, 0 )
	self[ at ] = action
end

function common_section_mt:swap( index_1, index_2 )
	getmetatable( common_section_mt ).swap( self, index_1, index_2 )
	local item_comp_1 = EntityGetFirstComponentIncludingDisabled( self[ index_1 ], "ItemComponent" )
	local item_comp_2 = EntityGetFirstComponentIncludingDisabled( self[ index_2 ], "ItemComponent" )
	ComponentSetValue2( item_comp_1, "inventory_slot", index_1 - 1, 0 )
	ComponentSetValue2( item_comp_2, "inventory_slot", index_2 - 1, 0 )
end

function edit_panel_api.access_actions( wand_id )
	local common = { wand = wand_id }
	local permanent = { wand = wand_id }

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

return edit_panel_api