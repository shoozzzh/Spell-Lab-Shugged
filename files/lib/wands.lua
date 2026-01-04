dofile_once( "data/scripts/gun/procedural/gun_procedural.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/variables.lua" )

-- override the one from gun_procedural.lua
-- which uses EntityGetFirstComponent instead of EntityGetFirstComponentIncludingDisabled,
-- causing issues
function SetWandSprite( entity_id, ability_comp, item_file, offset_x, offset_y, tip_x, tip_y )

	if( ability_comp ~= nil ) then
		ComponentSetValue( ability_comp, "sprite_file", item_file)
	end

	local sprite_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent", "item" )
	if( sprite_comp ~= nil ) then
		ComponentSetValue( sprite_comp, "image_file", item_file)
		ComponentSetValue( sprite_comp, "offset_x", offset_x )
		ComponentSetValue( sprite_comp, "offset_y", offset_y )
	end

	local hotspot_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "HotspotComponent", "shoot_pos" )
	if( hotspot_comp ~= nil ) then
		ComponentSetValueVector2( hotspot_comp, "offset", tip_x, tip_y )
	end 
end

local WAND_STAT_SETTER = {
	Direct = 1,
	Gun = 2,
	GunAction = 3
}

local WAND_STAT_SETTERS = {
	shuffle_deck_when_empty = WAND_STAT_SETTER.Gun,
	actions_per_round = WAND_STAT_SETTER.Gun,
	speed_multiplier = WAND_STAT_SETTER.GunAction,
	-- deck_capacity = WAND_STAT_SETTER.Gun,
	reload_time = WAND_STAT_SETTER.Gun,
	fire_rate_wait = WAND_STAT_SETTER.GunAction,
	spread_degrees = WAND_STAT_SETTER.GunAction,
	mana_charge_speed = WAND_STAT_SETTER.Direct,
	mana_max = WAND_STAT_SETTER.Direct,
	mana = WAND_STAT_SETTER.Direct,
}

local WANDS = {}

function WANDS.wand_clear_actions( wand )
	local actions = {}
	local children = EntityGetAllChildren( wand, "card_action" ) or {}
	for i,v in ipairs( children ) do
		local item = EntityGetFirstComponentIncludingDisabled( v, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( v, "ItemActionComponent" )
		if item and item_action then
			EntityRemoveFromParent( v )
			EntityKill( v )
		end
	end
	return actions
end

function WANDS.wand_get_actions( wand )
	local actions = {}
	local children = EntityGetAllChildren( wand, "card_action" ) or {}
	for i,v in ipairs( children ) do
		local item = EntityGetFirstComponentIncludingDisabled( v, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( v, "ItemActionComponent" )
		if item and item_action then
			local action_id = ComponentGetValue2( item_action, "action_id" )
			local permanent = ComponentGetValue2( item, "permanently_attached" )
			local locked = ComponentGetValue2( item, "is_frozen" )
			local x, y = ComponentGetValue2( item, "inventory_slot" )
			if action_id ~= nil then
				table.insert( actions, { action_id = action_id, permanent = permanent, locked = locked, x = x, y = y, entity = v, item = item } )
			end
		end
	end
	return actions
end

-- TODO : Deduplicate
function WANDS.wand_get_actions_absolute( wand )
	local actions = {}
	local permanent_actions = {}
	local children = EntityGetAllChildren( wand, "card_action" ) or {}
	local slot_0_taken = false
	local offset = 0
	for i,v in ipairs( children ) do
		local item = EntityGetFirstComponentIncludingDisabled( v, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( v, "ItemActionComponent" )
		if item and item_action then
			local action_id = ComponentGetValue2( item_action, "action_id" )
			local permanent = ComponentGetValue2( item, "permanently_attached" )
			local uses_remaining = ComponentGetValue2( item, "uses_remaining" )
			local locked = ComponentGetValue2( item, "is_frozen" )
			local x, y = ComponentGetValue2( item, "inventory_slot" )
			if action_id then
				if not permanent then
					local index = x
					if x == 0 then
						if slot_0_taken then
							x = i - 1 - #permanent_actions
						else
							slot_0_taken = true
						end
					end

					actions[ x - offset ] = { action_id = action_id, permanent = permanent, locked = locked, x = x, y = y, entity = v, item = item, uses_remaining = uses_remaining }
				else
					if x ~= 0 then
						offset = offset + 1
					end
					permanent_actions[ #permanent_actions + 1 ] = { action_id = action_id, permanent = permanent, locked = locked, x = x, y = y, entity = v, item = item, uses_remaining = uses_remaining }
				end
			end
		end
	end
	return actions, permanent_actions
end

function WANDS.wand_get_actions_all( wand )
	local actions = {}
	for i, a in ipairs( EntityGetAllChildren( wand, "card_action" ) or {} ) do
		local item_comp = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
		local ia_comp   = EntityGetFirstComponentIncludingDisabled( a, "ItemActionComponent" )
		if not item_comp or not ia_comp then goto continue end
		local action_id      = ComponentGetValue2( ia_comp, "action_id" )
		local permanent      = ComponentGetValue2( item_comp, "permanently_attached" )
		local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
		local locked         = ComponentGetValue2( item_comp, "is_frozen" )
		local x, y           = ComponentGetValue2( item_comp, "inventory_slot" )
		if not action_id then goto continue end
		table.insert( actions, {
			action_id      = action_id,
			permanent      = permanent,
			locked         = locked,
			x              = x,
			y              = y,
			uses_remaining = uses_remaining,
		} )
		::continue::
	end
	return actions
end

function WANDS.wand_get_actions_permanent( wand )
	local permanent_actions = {}
	for i,v in ipairs( EntityGetAllChildren( wand, "card_action" ) or {} ) do
		local item        = EntityGetFirstComponentIncludingDisabled( v, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( v, "ItemActionComponent" )
		if not item or not item_action then goto continue end
		local action_id = ComponentGetValue2( item_action, "action_id" )
		local permanent = ComponentGetValue2( item, "permanently_attached" )
		if not action_id or not permanent then goto continue end
		local uses_remaining = ComponentGetValue2( item, "uses_remaining" )
		local locked         = ComponentGetValue2( item, "is_frozen" )
		local x, y           = ComponentGetValue2( item, "inventory_slot" )
		table.insert( permanent_actions, {
			action_id      = action_id,
			locked         = locked,
			x              = x,
			y              = y,
			entity         = v,
			item           = item,
			uses_remaining = uses_remaining
		} )
		::continue::
	end
	return permanent_actions
end

function WANDS.wand_get_num_actions_permanent( wand )
	local num_permanent_actions = 0
	for i, v in ipairs( EntityGetAllChildren( wand, "card_action" ) or {} ) do
		local item        = EntityGetFirstComponentIncludingDisabled( v, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( v, "ItemActionComponent" )
		if not item or not item_action then goto continue end
		local action_id = ComponentGetValue2( item_action, "action_id" )
		local permanent = ComponentGetValue2( item, "permanently_attached" )
		if not action_id or not permanent then goto continue end
		num_permanent_actions = num_permanent_actions + 1
		::continue::
	end
	return num_permanent_actions
end

function WANDS.actions_get_num_permanent( actions )
	local num_permanent_actions = 0
	for _, a in pairs( actions ) do
		if a.permanent then
			num_permanent_actions = num_permanent_actions + 1
		end
	end
	return num_permanent_actions
end

function WANDS.wand_set_actions( wand, actions_table )
	for _,action_id in pairs(actions_table) do
		AddGunAction( wand, action_id )
	end
end

function WANDS.wand_shuffle_actions( wand )
	local actions = {}
	local actions_data = {}
	local children = EntityGetAllChildren( wand, "card_action" ) or {}
	for i,v in ipairs( children ) do
		local item = EntityGetFirstComponentIncludingDisabled( v, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( v, "ItemActionComponent" )
		if item and item_action then
			local action_id = ComponentGetValue2( item_action, "action_id" )
			local permanent = ComponentGetValue2( item, "permanently_attached" )
			local locked = ComponentGetValue2( item, "is_frozen" )
			local x, y = ComponentGetValue2( item, "inventory_slot" )
			if action_id ~= nil and permanent ~= true and locked ~= true then
				table.insert( actions, { action_entity = v, item = item } )
				table.insert( actions_data, { x = x, y = y } )
			end
		end
	end
	local wx, wy = EntityGetTransform( wand )
	SetRandomSeed( GameGetFrameNum(), wx + wy )
	local actions_data_shuffled = {}
	for i, v in ipairs(actions_data) do
		local pos = Random( 1, #actions_data_shuffled + 1 )
		table.insert( actions_data_shuffled, pos, v )
	end
	for i=1,#actions do
		local action = actions[i]
		local action_data = actions_data_shuffled[i]
		ComponentSetValue2( action.item, "inventory_slot", action_data.x, action_data.y )
	end
end

function WANDS.wand_copy_actions( base_wand, copy_wand )
	local actions = WANDS.wand_get_actions( base_wand )
	for index,action_data in pairs( actions ) do
		local action_entity = CreateItemActionEntity( action_data.action_id )
		local item = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
		if action_data.permanent then
			ComponentSetValue2( item, "permanently_attached", true )
		end
		if ComponentSetValue2 and action_data.x ~= nil and action_data.y ~= nil then
			ComponentSetValue2( item, "inventory_slot", action_data.x, action_data.y )
		end
		EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
		EntityAddChild( copy_wand, action_entity )
	end
end

function WANDS.wand_copy_stats( base_wand, copy_wand )
	local base_ability = EntityGetFirstComponentIncludingDisabled( base_wand, "AbilityComponent" )
	local target_ability = EntityGetFirstComponentIncludingDisabled( copy_wand, "AbilityComponent" )
	if base_ability and target_ability then
		for stat,stat_type in pairs( WAND_STAT_SETTERS ) do
			WANDS.ability_component_set_stat( target_ability, stat, WANDS.ability_component_get_stat( base_ability, stat ) )
		end
	end
end

function WANDS.ability_component_get_stat( ability, stat )
	local setter = WAND_STAT_SETTERS[stat]
	if setter ~= nil then
		if setter == WAND_STAT_SETTER.Direct then
			return ComponentGetValue2( ability, stat )
		elseif setter == WAND_STAT_SETTER.Gun then
			return ComponentObjectGetValue2( ability, "gun_config", stat )
		elseif setter == WAND_STAT_SETTER.GunAction then
			return ComponentObjectGetValue2( ability, "gunaction_config", stat )
		end
	end
end

function WANDS.ability_component_set_stat( ability, stat, value )
	local setter = WAND_STAT_SETTERS[stat]
	if setter ~= nil then
		if setter == WAND_STAT_SETTER.Direct then
			ComponentSetValue2( ability, stat, value )
		elseif setter == WAND_STAT_SETTER.Gun then
			ComponentObjectSetValue2( ability, "gun_config", stat, value )
		elseif setter == WAND_STAT_SETTER.GunAction then
			ComponentObjectSetValue2( ability, "gunaction_config", stat, value )
		end
	end
end

function WANDS.ability_component_adjust_stat( ability, stat, callback )
	local setter = WAND_STAT_SETTERS[stat]
	if setter ~= nil then
		local current_value = nil
		if setter == WAND_STAT_SETTER.Direct then
			current_value = ComponentGetValue2( ability, stat )
		elseif setter == WAND_STAT_SETTER.Gun then
			current_value = ComponentObjectGetValue2( ability, "gun_config", stat )
		elseif setter == WAND_STAT_SETTER.GunAction then
			current_value = ComponentObjectGetValue2( ability, "gunaction_config", stat )
		end
		local new_value = callback( current_value )
		if setter == WAND_STAT_SETTER.Direct then
			ComponentSetValue2( ability, stat, new_value )
		elseif setter == WAND_STAT_SETTER.Gun then
			ComponentObjectSetValue2( ability, "gun_config", stat, new_value )
		elseif setter == WAND_STAT_SETTER.GunAction then
			ComponentObjectSetValue2( ability, "gunaction_config", stat, new_value )
		end
	end
end

function WANDS.ability_component_get_stats( ability, stat )
	local stats = {}
	for k,v in pairs( WAND_STAT_SETTERS ) do
		stats[k] = WANDS.ability_component_get_stat( ability, k )
	end
	return stats
end

function WANDS.ability_component_set_stats( ability, stat_value_table )
	for stat,value in pairs(stat_value_table) do
		WANDS.ability_component_set_stat( ability, stat, value )
	end
end

function WANDS.ability_component_adjust_stats( ability, stat_callback_table )
	for stat,callback in pairs(stat_callback_table) do
		WANDS.ability_component_adjust_stat( ability, stat, callback )
	end
end

function WANDS.wand_get_stat( wand, stat )
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	if ability then
		if stat == "deck_capacity" then
			return ComponentObjectGetValue2( ability, "gun_config", "deck_capacity" )
		elseif stat == "capacity" then
			return EntityGetWandCapacity( wand )
		else
			return WANDS.ability_component_get_stat( ability, stat )
		end
	end
end

function WANDS.wand_set_stat( wand, stat, value )
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	if ability then
		if stat == "deck_capacity" then
			ComponentObjectSetValue2( ability, "gun_config", "deck_capacity", value )
		elseif stat == "capacity" then
			ComponentObjectSetValue2( ability, "gun_config", "deck_capacity", value + WANDS.wand_get_num_actions_permanent( wand ) )
		else
			WANDS.ability_component_set_stat( ability, stat, value )
		end
	end
end

function WANDS.wand_adjust_stat( wand, stat, callback )
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	if ability then
		if stat == "deck_capacity" then
			local value = ComponentObjectGetValue2( ability, "gun_config", "deck_capacity" )
			ComponentObjectSetValue2( ability, "gun_config", "deck_capacity", callback( value ) )
		elseif stat == "capacity" then
			local value = ComponentObjectGetValue2( ability, "gun_config", "deck_capacity" )
			ComponentObjectSetValue2( ability, "gun_config", "deck_capacity", callback( value ) )
		else
			WANDS.ability_component_adjust_stat( ability, stat, callback )
		end
	end
end

function WANDS.wand_get_stats( wand, stat )
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	if ability then
		local result = WANDS.ability_component_get_stats( ability, stat )
		result.capacity = EntityGetWandCapacity( wand )
		result.deck_capacity = ComponentObjectGetValue2( ability, "gun_config", "deck_capacity" )
		return result
	end
end

function WANDS.wand_set_stats( wand, stat_value_table )
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	if ability then return WANDS.ability_component_set_stats( ability, stat_value_table ) end
end

function WANDS.wand_adjust_stats( wand, stat_callback_table )
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	if ability then return WANDS.ability_component_adjust_stats( ability, stat_callback_table ) end
end

function WANDS.wand_get_dynamic_wand_data_from_stats( stats )
	local gun = {
		deck_capacity           = stats.deck_capacity,
		actions_per_round       = stats.actions_per_round,
		reload_time             = stats.reload_time,
		shuffle_deck_when_empty = stats.shuffle_deck_when_empty and 1 or 0,
		fire_rate_wait          = stats.fire_rate_wait,
		spread_degrees          = stats.spread_degrees,
		speed_multiplier        = stats.speed_multiplier,
		mana_charge_speed       = stats.mana_charge_speed,
		mana_max                = stats.mana_max,
	}
	return GetWand( gun )
end

function WANDS.wand_get_dynamic_wand_data( wand )
	local stats = WANDS.wand_get_stats( wand )
	stats.deck_capacity = stats.capacity + WANDS.wand_get_num_actions_permanent()
	return WANDS.wand_get_dynamic_wand_data_from_stats( stats )
end

function WANDS.wand_get_data( wand )
	return {
		stats       = WANDS.wand_get_stats( wand ),
		all_actions = WANDS.wand_get_actions_all( wand ),
	}
end

function WANDS.initialize_wand( wand, wand_data, do_clear_actions )
	do_clear_actions = do_clear_actions ~= false
	if do_clear_actions then WANDS.wand_clear_actions( wand ) end
	local ability = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
	local item = EntityGetFirstComponent( wand, "ItemComponent" )
	if wand_data.name then
		ComponentSetValue2( ability, "ui_name", wand_data.name )
		if item then
			ComponentSetValue2( item, "item_name", wand_data.name )
			ComponentSetValue2( item, "always_use_item_name_in_ui", true )
		end
	end

	for stat,value in pairs( wand_data.stats or {} ) do
		WANDS.ability_component_set_stat( ability, stat, value )
	end

	if wand_data.stats.capacity then
		local deck_capacity = wand_data.stats.capacity
		if do_clear_actions then
			deck_capacity = deck_capacity + WANDS.actions_get_num_permanent( wand_data.all_actions or {} )
		else
			deck_capacity = deck_capacity + WANDS.wand_get_num_actions_permanent( wand )
		end
		ComponentObjectSetValue2( ability, "gun_config", "deck_capacity", deck_capacity )
	end

	for stat,range in pairs( wand_data.stat_ranges or {} ) do
		WANDS.ability_component_set_stat( ability, stat, Random( range[1], range[2] ) )
	end

	WANDS.ability_component_set_stat( ability, "mana", WANDS.ability_component_get_stat( ability, "mana_max" ) )

	for _, action in pairs( wand_data.permanent_actions or {} ) do
		AddGunActionPermanent( wand, action.id )
	end

	if wand_data.absolute_actions then
		for x,action in pairs( wand_data.absolute_actions ) do
			local action_entity = CreateItemActionEntity( action.action_id )
			if action_entity then
				local item = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
				if action.locked then
					ComponentSetValue2( item, "is_frozen", true )
				end
				if action.uses_remaining then
					ComponentSetValue2( item, "uses_remaining", action.uses_remaining )
				end
				ComponentSetValue2( item, "inventory_slot", action.x or x, 0 )
				EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
				EntityAddChild( wand, action_entity )
			end
		end
	end

	for _, a in ipairs( wand_data.permanent_actions or {} ) do
		local action_entity = CreateItemActionEntity( a.action_id )
		if action_entity then
			local item = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
			if a.locked then
				ComponentSetValue2( item, "is_frozen", true )
			end
			if a.uses_remaining then
				ComponentSetValue2( item, "uses_remaining", a.uses_remaining )
			end
			ComponentSetValue2( item, "inventory_slot", 0, 0 )
			ComponentSetValue2( item, "permanently_attached", true )
			EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
			EntityAddChild( wand, action_entity )
		end
	end

	for _, a in ipairs( wand_data.all_actions or {} ) do
		local action_entity = CreateItemActionEntity( a.action_id )
		if action_entity then
			local item = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
			if a.locked then
				ComponentSetValue2( item, "is_frozen", true )
			end
			if a.uses_remaining then
				ComponentSetValue2( item, "uses_remaining", a.uses_remaining )
			end
			ComponentSetValue2( item, "inventory_slot", a.x, a.y )
			ComponentSetValue2( item, "permanently_attached", a.permanent )
			EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
			EntityAddChild( wand, action_entity )
		end
	end

	if wand_data.sprite ~= nil then
		SetWandSprite( wand, ability, wand_data.sprite.file, wand_data.sprite.x, wand_data.sprite.y, wand_data.sprite.hotspot.x, wand_data.sprite.hotspot.y )
		EntityRefreshSprite( wand, EntityGetFirstComponent( wand, "SpriteComponent", "item" ) )
	else
		local sprite = EntityGetFirstComponent( wand, "SpriteComponent", "item" )
		local is_special_wand = false
		if sprite then
			local image_file = ComponentGetValue2( sprite, "image_file" )
			if not string.sub( image_file, -13, -1 ):match( "wand_%d%d%d%d%.png" ) then
				is_special_wand = true
			end
		end
		if not is_special_wand then
			local dynamic_wand = WANDS.wand_get_dynamic_wand_data( wand )
			SetWandSprite( wand, ability, dynamic_wand.file, dynamic_wand.grip_x, dynamic_wand.grip_y, ( dynamic_wand.tip_x - dynamic_wand.grip_x ), ( dynamic_wand.tip_y - dynamic_wand.grip_y ) )
			EntityRefreshSprite( wand, EntityGetFirstComponent( wand, "SpriteComponent", "item" ) )
		end
	end
end

function WANDS.wand_explode_action( wand, x, include_permanent_actions, include_frozen_actions, ox, oy )
	local actions = WANDS.wand_get_actions_absolute( wand )
	if actions then
		local action = actions[x]
		if action then
			local action_to_remove = action.entity
			EntityRemoveFromParent( action_to_remove )
			EntityApplyTransform( action_to_remove, EntityGetTransform( wand ) )
			EntitySetComponentsWithTagEnabled( action_to_remove, "enabled_in_hand", false )
			EntitySetComponentsWithTagEnabled( action_to_remove, "enabled_in_inventory", false )
			EntitySetComponentsWithTagEnabled( action_to_remove, "enabled_in_world", true )
			ComponentSetValue2( EntityGetFirstComponent( action_to_remove, "VelocityComponent" ), "mVelocity", Random( -150, 150 ), Random( -250, -100 ) )
			return action_to_remove
		end
	end
end

local function wand_explode_action_impl( wand, action_to_remove, vx, vy )
	EntityRemoveFromParent( action_to_remove )
	EntityApplyTransform( action_to_remove, EntityGetTransform( wand ) )
	EntitySetComponentsWithTagEnabled( action_to_remove, "enabled_in_hand", false )
	EntitySetComponentsWithTagEnabled( action_to_remove, "enabled_in_inventory", false )
	EntitySetComponentsWithTagEnabled( action_to_remove, "enabled_in_world", true )
	ComponentSetValue2( EntityGetFirstComponent( action_to_remove, "VelocityComponent" ), "mVelocity", vx, vy )
end

function WANDS.wand_explode_actions_out_of_bound( wand )
	local deck_capacity = WANDS.wand_get_stat( wand, "deck_capacity" )
	local vx = 0
	for _, a in ipairs( EntityGetAllChildren( wand, "card_action" ) or {} ) do
		local item        = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( a, "ItemActionComponent" )
		if item and item_action then
			local x, _      = ComponentGetValue2( item, "inventory_slot" )
			local permanent = ComponentGetValue2( item, "permanently_attached" )
			if x >= deck_capacity and not permanent then
				wand_explode_action_impl( wand, a, vx, -100 )
				vx = vx + 30
			end
		end
	end
end

function WANDS.wand_check_actions_out_of_bound( wand, deck_capacity )
	for _, a in ipairs( EntityGetAllChildren( wand, "card_action" ) or {} ) do
		local item        = EntityGetFirstComponentIncludingDisabled( a, "ItemComponent" )
		local item_action = EntityGetFirstComponentIncludingDisabled( a, "ItemActionComponent" )
		if item and item_action then
			local x, _      = ComponentGetValue2( item, "inventory_slot" )
			local permanent = ComponentGetValue2( item, "permanently_attached" )
			if x >= deck_capacity and not permanent then
				return false
			end
		end
	end
	return true
end

return WANDS