local edit_panel_api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

local function get_all_wands_in_inventory()
	if not player then return end

	local children = EntityGetAllChildren( player )
	if not children then return end

	for _, child in pairs( children ) do
		if EntityGetName( child ) == "inventory_quick" then
			return EntityGetAllChildren( child, "wand" )
		end
	end
end

local function view_actions( wand_id )
	local permanent = {}
	local common = {}

	local offset = 0
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
			if x == 0 then
				offset = offset + 1
			end
			common[ x + offset ] = { action_id, uses_remaining }
		end

		::continue::
	end
	return { permanent = permanent, common = common }
end

local function deep_equals( a, b )
	local tipe = type( a )
	if tipe ~= type( b ) then return false end

	if tipe == "table" then
		for k, v in pairs( a ) do
			if not deep_equals( v, b[ k ] ) then
				return false
			end
		end
		return true
	else
		return a == b
	end
end

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

local stored_action_views = {}

for _, wand_id in ipairs( wands_to_listen or {} ) do
	
	local stored = stored_action_views[ wand_id ]
	local from_wand = view_actions( wand_id )

	if not stored then
		stored_action_views[ wand_id ] = from_wand
		goto continue
	end

	local data = edit_panel_api.access_data( wand_id )
	if data.vars.force_compact_enabled then goto continue end

	if not deep_equals( stored, from_wand ) then
		stored_action_views[ wand_id ] = from_wand
		data:new_state_history(
			wrap_key( "operation_read_from_wand" ), edit_panel_api.dump_state( wand_id ), data.vars.selection
		)
	end

	::continue::
end

for wand_id, _ in pairs( stored_action_views ) do
	if not EntityGetIsAlive( wand_id ) then
		stored_action_views[ wand_id ] = nil
	end
end