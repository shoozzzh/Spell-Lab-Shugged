function get_held_wand()
	if not player then return end
	local wands
	for _, child_id in ipairs( EntityGetAllChildren( player ) or {} ) do
		if EntityGetName( child_id ) == "inventory_quick" then
			wands = EntityGetAllChildren( child_id, "wand" )
			break
		end
	end
	if not wands or #wands == 0 then return end
	local inv2 = EntityGetFirstComponent( player, "Inventory2Component" )
	local active_item = ComponentGetValue2( inv2, "mActiveItem" )
	for _, wand_id in pairs( wands ) do
		if wand_id == active_item then
			return wand_id
		end
	end
end

function get_all_wands_in_inventory()
	if not player then return end

	local children = EntityGetAllChildren( player )
	if not children then return end

	for _, child in pairs( children ) do
		if EntityGetName( child ) == "inventory_quick" then
			return EntityGetAllChildren( child, "wand" )
		end
	end
end

function force_refresh_held_wands()
	if not player then return end
	local inv2_comp = EntityGetFirstComponent( player, "Inventory2Component" )
	if not inv2_comp then return end
	ComponentSetValue2( inv2_comp, "mForceRefresh", true )
	ComponentSetValue2( inv2_comp, "mActualActiveItem", 0 )
	ComponentSetValue2( inv2_comp, "mDontLogNextItemEquip", true )
end

function clear_held_wand_wait()
	if not held_wand then return false end
	local ab_comp = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
	if not ab_comp then return false end
	ComponentSetValue2( ab_comp, "mReloadFramesLeft", 0 )
	ComponentSetValue2( ab_comp, "mNextFrameUsable", now )
	ComponentSetValue2( ab_comp, "mReloadNextFrameUsable", now )
	return true
end

function block_upcoming_wand_shooting()
	if not held_wand then return end
	local ab_comp = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
	if not ab_comp then return end
	ComponentSetValue2( ab_comp, "mReloadFramesLeft", math.max( 10, ComponentGetValue2( ab_comp, "mReloadFramesLeft" ) ) )
	ComponentSetValue2( ab_comp, "mNextFrameUsable", math.max( now + 10, ComponentGetValue2( ab_comp, "mNextFrameUsable" ) ) )
	ComponentSetValue2( ab_comp, "mReloadNextFrameUsable", math.max( now + 10, ComponentGetValue2( ab_comp, "mReloadNextFrameUsable" ) ) )
end

function is_action_unlocked( action )
	if action then
		return not action.spawn_requires_flag or HasFlagPersistent( action.spawn_requires_flag )
	end
	return false
end

local stream = dofile_once( mod_path .. "libs/stream.lua" )

function stream_actions( wand_id )
	return stream( EntityGetAllChildren( wand_id ) or {} )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemComponent" ) ~= nil end )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemActionComponent" ) ~= nil end )
end
