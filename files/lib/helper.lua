local mod_settings_prefix = "spell_lab_shugged."

function mod_setting_get( key )
	return ModSettingGet( mod_settings_prefix .. key )
end
function mod_setting_set( key, value )
	return ModSettingSet( mod_settings_prefix .. key, value )
end
function wrap_setting_key( key )
	return mod_settings_prefix .. key
end

local transl_key_prefix = "$spell_lab_shugged_"

function wrap_key( key )
	if string.sub( key, 1, 1 ) == "$" then
		return key
	end
	return transl_key_prefix .. key
end
function text_get_translated( key )
	return GameTextGetTranslatedOrNot( wrap_key( key ) )
end
function text_get( key, ... )
	return GameTextGet( wrap_key( key ), ... )
end

do
	local function c( h )
		return ( h + 1 ) / 256
	end
	function color( r, g, b, a )
		return c( r ), c( g ), c( b ), c( a )
	end
end

function maxn( t )
	local result = table.maxn( t )
	if result == 0 and not t[0] then return -1 end
	return result
end

local function thousands_separator( value_text )
	local formatted = value_text
	local num_separators = 0
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function ten_thousands_separator( value_text )
	local formatted = value_text
	local num_separators = 0
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

function word_wrap( str, wrap_size )
	if GameTextGetTranslatedOrNot( "$current_language" ) ~= "English" then
		return str
	end
	if wrap_size == nil then wrap_size = 60 end
	local last_space_index = 1
	local last_wrap_index = 0
	for i=1,#str do
		if str:sub(i,i) == " " then
			last_space_index = i
		end
		if str:sub(i,i) == "\n" then
			last_space_index = i
			last_wrap_index = i
		end
		if i - last_wrap_index > wrap_size then
			str = str:sub(1,last_space_index-1) .. "\n" .. str:sub(last_space_index + 1)
			last_wrap_index = i
		end
	end
	return str
end

local not_a_gui = GuiCreate()
function center_text( text )
	return GuiGetTextDimensions( not_a_gui, text, 1, 0, "mods/spell_lab_shugged/files/font/font_small_numbers.xml", true ) / 2
end

zh_cn_languages = {
	["简体中文"] = true,
	["喵体中文"] = true,
	["汪体中文"] = true,
	["完全汉化"] = true,
}

function separator( text )
	return ( zh_cn_languages[ GameTextGetTranslatedOrNot( "$current_language" ) ]
	and ten_thousands_separator or thousands_separator )( text )
end

FORMAT = {
	Floor = 0,
	Round = 1,
	Ceiling = 2
}

local inf = 1 / 0
local threshold = 10 ^ 10
function format_damage( damage, never_use_scientific_notation, result_inf )
	if damage == inf then
		return result_inf or "∞"
	end
	damage = damage * 25
	if not never_use_scientific_notation and ( damage > threshold or -damage > threshold ) then
		return string.format( "%.10e", damage )
	end
	return separator( string.format( "%.2f", damage ) )
end

function format_value( value, decimals, show_sign, format )
	local text = ""
	if value ~= nil then
		if show_sign and value > 0 then
			text = "+"
		end
		local rounder = math.floor
		local value_offset = 0
		if format == FORMAT.Ceiling then
			rounder = math.ceil
		elseif format == FORMAT.Round then
			value_offset = 0.5
		end
		local power = math.pow( 10, decimals )
		text = text .. tostring( rounder( value * power + value_offset ) / power )
	else
		return "missing"
	end
	return text
end

function format_time( time, digits )
	digits = digits or 2
	return format_value( time / 60, digits, true, FORMAT.Round ) .. " s (" .. GameTextGet( wrap_key( "frames" ), format_value( time, 0 ) ) .. ")"
end

function format_range( min, max )
	if not min or not max then return nil end
	if min ~= max then
		return min .. " - " .. max
	else
		return tostring( min )
	end
end

function get_player_or_camera_position()
	if player then
		x, y = EntityGetTransform( player )
		return x, y
	end
	return GameGetCameraPos()
end

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

function optional_call( f, ... )
	if f then return f( ... ) end
end

function memoize( f )
	return setmetatable( {}, {
		__call = function( self, arg )
			local cache = self[ arg ]
			if cache ~= nil then return cache end
			local result = f( arg )
			self[ arg ] = result
			return result
		end,
	} )
end

local function dofile_wrapped( filepath, environment )
	local f = loadfile( filepath )
	local e = environment or {}
	setfenv( f, e )()
	return e
end

function get_globals( filepath )
	local g = _G
	local captured_globals = {}
	local mt = {
		__index = g,
		__newindex = function( e, k, v )
			rawset( e, k, v )
			captured_globals[ k ] = v
		end,
	}
	return dofile_wrapped( filepath, setmetatable( {}, mt ) )
end

get_globals = memoize( get_globals )

Type_Adjustment = {
	Add = 1,
	Set = 2,
}