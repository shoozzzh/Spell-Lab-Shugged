local mod_id = "spell_lab_shugged"

local key_prefix = "$" .. mod_id .. "_"
---@param key string
function wrap_key( key )
	return key_prefix .. key
end

---@param key string
function get_text( key )
	return GameTextGetTranslatedOrNot( wrap_key( key ) )
end

---@param f fun( ... )|nil
---@return any
function optional_call( f, ... )
	if f then return f( ... ) end
end

---@generic T: fun()
---@param f T
---@return T
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

local function dofile_mask( env )
	local loadonce, loaded = {}, {}
	local mask = {}
	mask.do_mod_appends = function( filepath )
		for _, append_filepath in ipairs( ModLuaFileGetAppends( filepath ) ) do
			mask.dofile( append_filepath )
		end
	end
	mask.dofile_once = function( filepath )
	    local result
	    local cached = loadonce[ filepath ]
	    if cached ~= nil then
	        result = cached[1]
	    else
	        local f, err = loadfile( filepath )
	        if f == nil then return f, err end
	        setfenv( f, env )
	        result = f()
	        loadonce[ filepath ] = { result }
	        mask.do_mod_appends( filepath )
	    end
	    return result
	end
	mask.dofile = function( filepath )
	    local f = loaded[ filepath ]
	    if f == nil then
	    	local err
	        f, err = loadfile( filepath )
	        if f == nil then return f, err end
	        setfenv( f, env )
	        loaded[ filepath ] = f
	    end
	    local result = f()
	    mask.do_mod_appends( filepath )
	    return result
	end

	return mask
end

---@return table<string,any>
function get_globals( filepath, extra_globals )
	local f, err = loadfile( filepath )
	if f == nil then
		print_error( err )
		return {}
	end

	local e = extra_globals or {}
	local mask = setmetatable( dofile_mask( e ), { __index = getfenv(2) } )
	setmetatable( e, { __index = mask } )
	setfenv( f, e )()

	local globals = {}
	for k, v in pairs( e ) do
		globals[ k ] = v
	end

	return globals
end

local extract_folder = memoize( function( source )
	return source:match("^(.*/)")
end )

local finfo = jit.util.funcinfo

---@return string
function this_folder()
	return extract_folder( finfo( setfenv( 2, getfenv(2) ) ).source )
end

local function c( h )
	return ( h + 1 ) / 256
end

function color( r, g, b, a )
	return c( r ), c( g ), c( b ), c( a )
end

function maxn( t )
	local result = table.maxn( t )
	if result == 0 and not t[0] then return -1 end
	return result
end

local gui_measurer = GuiCreate()

---@param text string
---@param scale number?
---@param font string?
---@param is_pixel bool?
---@return number, number
function get_text_size( text, scale, font, is_pixel )
	return GuiGetTextDimensions( gui_measurer, text, scale, 2, font or "", is_pixel )
end

---@param image_filename string
---@param scale number?
---@return number, number
function get_image_size( image_filename, scale )
	return GuiGetImageDimensions( gui_measurer, image_filename, scale or 1 )
end

function is_cur_lang_cn()
	local cur_lang = GameTextGet "$current_language"
	if cur_lang:find "中文" or cur_lang:find "汉化" then
		return true
	end
	return false
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

dofile_once( mod_path .. "libs/stream.lua" )

function stream_actions( wand_id )
	return stream( EntityGetAllChildren( wand_id ) or {} )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemComponent" ) ~= nil end )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemActionComponent" ) ~= nil end )
end

function deep_equals( a, b )
	local tipe = type( a )
	if tipe ~= type( b ) then return false end

	if tipe == "table" then
		for k, v in pairs( a ) do
			if not deep_equals( v, b[ k ] ) then
				return false
			end
		end
		for k, v in pairs( b ) do
			if a[ k ] == nil then
				return false
			end
		end
		return true
	else
		return a == b
	end
end

function new_prototype( parent )
	local t = {}
	t.__index = t
	if parent then
		setmetatable( t, parent )
	end
	return t
end

