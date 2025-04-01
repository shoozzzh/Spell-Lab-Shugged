dofile_once( "mods/spell_lab_shugged/files/lib/entity_xml_parser.lua" )
TYPE_ADJUSTMENT = {
	Add = 1,
	Set = 2,
}
function get_action_metadata( this_action_data )
	if not this_action_data then return end
	local metadata = {
		c = {},
		projectiles = nil,
		shot_effects = {},
	}

	reflecting = true
	local last_projectile_timer_time = nil
	local add_projectile_trigger_timer_injected = function( entity_filename, delay_frames, action_draw_count )
		last_projectile_timer_time = delay_frames
		Reflection_RegisterProjectile( entity_filename )
	end
	Reflection_RegisterProjectile = function( filepath )
		metadata.projectiles = metadata.projectiles or {}
		if metadata.projectiles[filepath] then
			metadata.projectiles[filepath].projectiles = metadata.projectiles[filepath].projectiles + 1
			return
		end
		local xml_content = parse_entity_xml( filepath )
		if not xml_content then
			print( "Spell " .. tostring( this_action_data.action_id ) .. " has a wrong argument in its Reflection_RegisterProjectile(). You might want to blame the author of that spell if you see this" )
			return
		end
		local properties

		local proj_comp = xml_content:first_of( "ProjectileComponent" )
		if proj_comp then
			properties = proj_comp.attr
			local damage_by_type = proj_comp:first_of( "damage_by_type" )
			if damage_by_type then
				for type, value in pairs( damage_by_type.attr ) do
					properties[ "damage_" .. type ] = ( properties[ "damage_" .. type ] or 0 ) + tonumber( value )
				end
			end
			local config_explosion = proj_comp:first_of( "config_explosion" )
			if config_explosion then
				properties.explosion_damage = config_explosion.attr.damage or 5
				properties.explosion_radius = config_explosion.attr.explosion_radius or 20
			else
				properties.explosion_damage = 5
				properties.explosion_radius = 20
			end
		end
		properties = properties or {}
		properties.projectiles = 1

		properties.lifetime_cap = nil
		properties.lifetime_cap2 = nil
		for lifetime_comp in xml_content:each_of( "LifetimeComponent" ) do
			local lifetime = tonumber( lifetime_comp.attr.lifetime )
			if lifetime and lifetime >= 0 then
				local randomize_min = tonumber( lifetime_comp.attr["randomize_lifetime.min"] ) or 0
				local randomize_max = tonumber( lifetime_comp.attr["randomize_lifetime.max"] ) or 0
				local lifetime2 = lifetime + randomize_max
				lifetime = lifetime + randomize_min
				if not properties.lifetime_cap or lifetime < properties.lifetime_cap then
					properties.lifetime_cap = lifetime
				end
				if not properties.lifetime_cap2 or lifetime2 < properties.lifetime_cap2 then
					properties.lifetime_cap2 = lifetime2
				end
			end
		end
		for xray_comp in xml_content:each_of( "MagicXRayComponent" ) do
			local steps_per_frame = tonumber( xray_comp.attr.steps_per_frame )
			local radius = tonumber( xray_comp.attr.radius )
			if steps_per_frame and steps_per_frame >= 0 and radius and radius >= 0 then
				local lifetime = radius / steps_per_frame
				if not properties.lifetime_cap or lifetime < properties.lifetime_cap then
					properties.lifetime_cap = lifetime
				end
				if not properties.lifetime_cap2 or lifetime < properties.lifetime_cap2 then
					properties.lifetime_cap2 = lifetime
				end
			end
		end
		local vel_comp = xml_content:first_of( "VelocityComponent" )
		if vel_comp then
			properties.gravity = vel_comp.attr.gravity_y or 400
			properties.air_friction = vel_comp.attr.air_friction or 0.55
		end

		if last_projectile_timer_time then
			properties.timer_time = last_projectile_timer_time
			last_projectile_timer_time = nil
		end

		metadata.projectiles[filepath] = properties
	end
	local _shot_effects = shot_effects
	local _c = c
		c = {}
		shot_effects = {}
		current_reload_time = 0

		local draws = 0
		local _draw_actions = draw_actions
		draw_actions = function( how_many ) draws = draws + how_many end

		local _EntityLoad = EntityLoad
		EntityLoad = function() end

		reset_modifiers( c )
		ConfigGunShotEffects_Init( shot_effects )

		c.friendly_fire = nil

		shot_effects.spell_lab_shugged_recoil_knockback = shot_effects.recoil_knockback
		shot_effects.recoil_knockback = nil
		shot_effects.spell_lab_shugged_count_recoil_get = 0
		shot_effects.spell_lab_shugged_count_recoil_set = 0
		setmetatable( shot_effects,
			{
				__index = function( t, key )
					if key == "recoil_knockback" then
						rawset( t, "spell_lab_shugged_count_recoil_get", rawget( t, "spell_lab_shugged_count_recoil_get" ) + 1 )
						return rawget( t, "spell_lab_shugged_recoil_knockback" )
					end
					return rawget( t, key )
				end,
				__newindex = function( t, key, value )
					if key == "recoil_knockback" then
						rawset( t, "spell_lab_shugged_count_recoil_set", rawget( t, "spell_lab_shugged_count_recoil_set" ) + 1 )
						rawset( t, "spell_lab_shugged_recoil_knockback", value )
					end
					rawset( t, key, value )
				end,
			}
		)
--[[				do
			local recoil = { shot_effects.recoil_knockback, __class = "spell_lab_shugged_recoil" }
			setmetatable( recoil, {
				__add = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						a[1] = a[1] + b
						return a
					else
						b[1] = b[1] + a
						return b
					end
				end,
				__sub = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						a[1] = a[1] - b
						return a
					else
						b[1] = b[1] - a
						return b
					end
				end,
				__mul = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						a[1] = a[1] * b
						return a
					else
						b[1] = b[1] * a
						return b
					end
				end,
				__div = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						a[1] = a[1] / b
						return a
					else
						b[1] = a / b[1]
						return b
					end
				end,
				__mod = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						a[1] = a[1] % b
						return a
					else
						b[1] = a % b[1]
						return b
					end
				end,
				__pow = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						a[1] = a[1] ^ b
						return a
					else
						b[1] = a ^ b[1]
						return b
					end
				end,
				__unm = function( a )
					a[1] = -a[1]
					return a
				end,
				__eq = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						return a[1] == b
					else
						return a == b[1]
					end
				end,
				__lt = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						return a[1] < b
					else
						return a < b[1]
					end
				end,
				__le = function( a, b )
					if a.__class == "spell_lab_shugged_recoil" then
						return a[1] <= b
					else
						return a <= b[1]
					end
				end,
				__tostring = function( a )
					return tostring( a[1] )
				end
			} )
			shot_effects.recoil_knockback = recoil
		end]]

		local action_action = this_action_data.action
		local action_env = getfenv( action_action )
		action_env.add_projectile_trigger_timer = add_projectile_trigger_timer_injected
		setfenv( action_action, action_env )

		pcall( action_action )

		draw_actions = _draw_actions
		c.draw_actions = draws
		c.reload_time = current_reload_time
		c.mana = this_action_data.mana
		if rawget( shot_effects, "spell_lab_shugged_count_recoil_set" ) == 1 then
			if rawget( shot_effects, "spell_lab_shugged_count_recoil_get" ) == 1 then
				c.spell_lab_shugged_recoil = { value = shot_effects.spell_lab_shugged_recoil_knockback, type = TYPE_ADJUSTMENT.Add }
			elseif rawget( shot_effects, "spell_lab_shugged_count_recoil_get" ) == 0 then
				c.spell_lab_shugged_recoil = { value = shot_effects.spell_lab_shugged_recoil_knockback, type = TYPE_ADJUSTMENT.Set }
			end
		end
		c.lifetime_cap = { nil, nil }
		if #c.extra_entities > 0 then
			string.gsub( c.extra_entities, "[^,]+", function( extra_entity )
				local extra_entity_content = parse_entity_xml( extra_entity )
				if extra_entity_content == nil then return end
				for lifetime_comp in extra_entity_content:each_of( "LifetimeComponent" ) do
					local lifetime = tonumber( lifetime_comp.attr.lifetime )
					if lifetime and lifetime >= 0 then
						local randomize_min = tonumber( lifetime_comp.attr["randomize_lifetime.min"] ) or 0
						local randomize_max = tonumber( lifetime_comp.attr["randomize_lifetime.max"] ) or 0
						local lifetime2 = lifetime + randomize_max
						lifetime = lifetime + randomize_min
						if not c.lifetime_cap[1] or lifetime < c.lifetime_cap[1] then
							c.lifetime_cap[1] = lifetime
						end
						if not c.lifetime_cap[2] or lifetime2 < c.lifetime_cap[2] then
							c.lifetime_cap[2] = lifetime2
						end
					end
				end
			end )
		end
		metadata.c = c

		EntityLoad = _EntityLoad
	c = _c
	shot_effects = _shot_effects
	reflecting = false
	if metadata.projectiles then
		local temp = metadata.projectiles
		metadata.projectiles = {}
		for _, d in pairs( temp ) do
			table.insert( metadata.projectiles, d )
		end
	end
	return metadata
end

if player then EntityRemoveTag( player, "player_unit" ) end

local action_metadata = {}
for _, action in pairs( actions ) do
	action_metadata[ action.id ] = get_action_metadata( action )
end

dofile_once( "mods/spell_lab_shugged/files/gui/extra_modifiers_supported.lua" )
local extra_modifier_metadata = {}
for _, id in pairs( extra_modifiers_supported ) do
	do
		local fake_action = {
			id = "FAKE_ACTION_" .. string.upper( id ),
			mana = 0,
			action = extra_modifiers[ id ],
		}
		local metadata = get_action_metadata( fake_action ).c
		for k, v in pairs( metadata ) do
			if k == "mana" and v == 0 then
				metadata[ k ] = nil
				break
			end
		end
		extra_modifier_metadata[ id ] = metadata

	end
	::continue::
end

if player then EntityAddTag( player, "player_unit" ) end

local metadata_to_show = {
	c = {
		{ "draw_actions"            , wrap_key( "draws" ), 0, function(value) return format_value( value, 0 ) end },
		{ "max_uses"                , wrap_key( "max_uses" ), nil, function(value) return format_value( value, 0 ) end },
		{ "mana"                    , "$inventory_manadrain", nil, function(value) return format_value( value, 0 ) end },
		{ "fire_rate_wait"          , "$inventory_castdelay", 0, function(value) return format_time( value, 3 ) end },
		{ "speed_multiplier"        , "$inventory_mod_speed", 1, function(value) return "x " .. format_value( value, 2 ) end },
		{ "lifetime_add"            , wrap_key( "lifetime_add" ), 0, function(value) return format_value( value, 0, true ) end },
		{ "lifetime_cap"            , wrap_key( "lifetime_cap" ), nil, function(value) return format_range( value[1], value[2] ) end },
		{ "reload_time"             , "$inventory_rechargetime", 0, function(value) return format_time( value, 3 ) end },
		{ "spread_degrees"          , "$inventory_spread", 0, function(value) return GameTextGet( wrap_key( "degrees" ), format_value( value, 3, true, FORMAT.Round ) ) end },
		{ "damage_critical_chance"  , "$inventory_mod_critchance", 0, function(value) return format_value( value, 0, true ) .. "%" end },
		{ "explosion_radius"        , "$inventory_explosion_radius", 0, function(value) return format_value( value, 0, true, FORMAT.Ceiling ) end },
		{ "damage_projectile_add"   , "$inventory_mod_damage", 0, function(value) return format_value( value * 25, 2, true, FORMAT.Ceiling ) end },
		{ "damage_ice_add"          , "$inventory_mod_damage_ice", 0, function(value) return format_value( value * 25, 2, true, FORMAT.Ceiling ) end },
		{ "damage_explosion_add"    , "$inventory_mod_damage_explosion", 0, function(value) return format_value( value * 25, 2, true, FORMAT.Ceiling ) end },
		{ "damage_melee_add"        , "$inventory_mod_damage_melee", 0, function(value) return format_value( value * 25, 2, true, FORMAT.Ceiling ) end },
		{ "damage_electricity_add"  , "$inventory_mod_damage_electric", 0, function(value) return format_value( value * 25, 2, true, FORMAT.Ceiling ) end },
		{ "damage_fire_add"         , "$inventory_mod_damage_fire", 0, function(value) return format_value( value * 25, 2, true, FORMAT.Ceiling ) end },
		{ "friendly_fire"           , wrap_key( "friendly_fire" ), nil, function(value) return wrap_key( value and "enable2" or "disable2" ) end },
		{ "gravity"                 , wrap_key( "gravity" ), 0, function(value) return format_value( value, 0, true ) end },
		{ "spell_lab_shugged_recoil", wrap_key( "recoil" ), nil, function(value)
			if value.type == TYPE_ADJUSTMENT.Set then
				return GameTextGet( wrap_key( "value_set_to" ), format_value( value.value, 0 ) )
			else
				if value.value ~= 0 then
					return format_value( value.value, 0, true )
				else
					return nil
				end
			end
		end },
	},
	projectiles = {
		{ wrap_key( "projectile_num_projectiles" ), function( data ) if data.projectiles ~= nil and tonumber( data.projectiles ) ~= 1 then return format_value( data.projectiles, 0 ) end end },
		{ wrap_key( "projectile_damage_projectile" ), function( data ) if data.damage ~= nil and tonumber( data.damage ) ~= 0 then return format_value( data.damage * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_curse" ), function( data ) if data.damage_curse ~= nil and tonumber( data.damage_curse ) ~= 0 then return format_value( data.damage_curse * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_slice" ), function( data ) if data.damage_slice ~= nil and tonumber( data.damage_slice ) ~= 0 then return format_value( data.damage_slice * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_melee" ), function( data ) if data.damage_melee ~= nil and tonumber( data.damage_melee ) ~= 0 then return format_value( data.damage_melee * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_electricity" ), function( data ) if data.damage_electricity ~= nil and tonumber( data.damage_electricity ) ~= 0 then return format_value( data.damage_electricity * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_explosion" ), function( data ) if data.damage_explosion ~= nil and tonumber( data.damage_explosion ) ~= 0 then return format_value( data.damage_explosion * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_fire" ), function( data ) if data.damage_fire ~= nil and tonumber( data.damage_fire ) ~= 0 then return format_value( data.damage_fire * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_ice" ), function( data ) if data.damage_ice ~= nil and tonumber( data.damage_ice ) ~= 0 then return format_value( data.damage_ice * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_drill" ), function( data ) if data.damage_drill ~= nil and tonumber( data.damage_drill ) ~= 0 then return format_value( data.damage_drill * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_poison" ), function( data ) if data.damage_poison ~= nil and tonumber( data.damage_poison ) ~= 0 then return format_value( data.damage_poison * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_healing" ), function( data ) if data.damage_healing ~= nil and tonumber( data.damage_healing ) ~= 0 then return format_value( data.damage_healing * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_damage_radioactive" ), function( data ) if data.damage_radioactive ~= nil and tonumber( data.damage_radioactive ) ~= 0 then return format_value( data.damage_radioactive * 25, 3, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_speed" ), function( data ) return format_range( data.speed_min, data.speed_max ) end },
		{ wrap_key( "projectile_air_friction" ), function( data ) return data.air_friction end },
		{ wrap_key( "projectile_innate_spread" ), function( data ) if data.direction_random_rad ~= nil and tonumber(data.direction_random_rad) ~= 0 then return GameTextGet( wrap_key( "degrees" ), format_value( data.direction_random_rad * 180 / math.pi, 1, false, FORMAT.Round ) ) end end },
		{ wrap_key( "projectile_gravity" ), function( data ) if data.gravity ~= nil and tonumber(data.gravity) ~= 0 then return data.gravity end end },
		{ wrap_key( "projectile_lifetime" ), function( data )
			if not data.lifetime then return end
			local result
			if not data.lifetime_randomness or data.lifetime_randomness == "0" then
				result = tostring( data.lifetime )
			else
				result = format_range( data.lifetime - data.lifetime_randomness, data.lifetime + data.lifetime_randomness )
			end
			return GameTextGet( wrap_key( "frames" ), result )
		end },
		{ wrap_key( "projectile_lifetime_cap" ), function( data )
			local result = format_range( data.lifetime_cap, data.lifetime_cap2 )
			if result then
				return GameTextGet( wrap_key( "frames" ), result )
			end
		end },
		{ wrap_key( "projectile_friendly_fire" ), function( data ) if data.friendly_fire == "1" then return "$menu_yes" end end },
		{ wrap_key( "projectile_shooter_collision_protection" ), function( data )
			if data.collide_with_shooter_frames and data.collide_with_shooter_frames ~= "-1" then
				return GameTextGet( wrap_key( "frames" ), data.collide_with_shooter_frames )
			end
		end },
		{ wrap_key( "projectile_explosion_enabled" ), function( data ) return "$menu_" .. ( ( data.on_death_explode == "1" or data.on_lifetime_out_explode == "1" ) and "yes" or "no" ) end },
		{ wrap_key( "projectile_explosion_radius" ), function( data ) if data.explosion_radius ~= nil then return format_value( data.explosion_radius, 0 ) end end },
		{ wrap_key( "projectile_explosion_damage" ), function( data ) if data.explosion_damage ~= nil then return format_value( data.explosion_damage * 25, 2, false, FORMAT.Round ) end end },
		{ wrap_key( "projectile_explosion_dont_damage_shooter" ), function( data ) if data.explosion_dont_damage_shooter and data.explosion_dont_damage_shooter ~= "0" then return "$menu_yes" end end },
		{ wrap_key( "projectile_timer_time" ), function( data ) if data.timer_time ~= nil then return GameTextGet( wrap_key( "frames" ), format_value( data.timer_time, 0 ) ) end end },
		{ wrap_key( "projectile_die_on_low_velocity" ), function( data ) if data.die_on_low_velocity == "1" then return data.die_on_low_velocity_limit or "50" end end }
	}
}

function c_metadata_to_lines( this_c_metadata )
	local c_lines = {}
	for _, d in ipairs( metadata_to_show.c ) do
		local value = this_c_metadata[d[1]]
		if value ~= nil and value ~= d[3] then
			local text = tostring( d[4]( value ) )
			if text ~= "nil" then
				table.insert( c_lines, { d[2], text } )
			end
		end
	end
	return c_lines
end

function proj_metadata_to_lines( this_projectiles_metadata )
	local num_lines = 0
	local projectiles_lines = {}
	for proj_index, data in ipairs( this_projectiles_metadata or {} ) do
		local proj_lines = {}
		for _, d in ipairs( metadata_to_show.projectiles ) do
			local value = d[2]( data )
			if value then
				table.insert( proj_lines, { d[1], value } )
			end
		end
		projectiles_lines[ proj_index ] = proj_lines
		num_lines = num_lines + #proj_lines
	end
	num_lines = num_lines + #projectiles_lines
	return projectiles_lines, num_lines
end

return { action_metadata, extra_modifier_metadata, metadata_to_show }