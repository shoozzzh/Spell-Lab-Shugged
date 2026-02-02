mod_id = "spell_lab_shugged"
mod_path = "mods/" .. mod_id .. "/"

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

local finfo = jit.util.funcinfo

local extract_folder = memoize( function( source )
	return source:match "^(.*/)"
end )

---@return string
function this_folder()
	return extract_folder( finfo( setfenv( 2, getfenv( 2 ) ) ).source )
end

local extract_module_path = memoize( function( source )
	return source:match "^(mods/[^/]+/files/[^/]+/)"
end )

---@return string
function module_path()
	return extract_module_path( finfo( setfenv( 2, getfenv( 2 ) ) ).source )
end

local key_prefix = "$" .. mod_id .. "_"
---@param key string
function wrap_key( key )
	if key == nil then
		local caller = finfo( setfenv( 3, getfenv( 3 ) ) ).source
		print_error( caller )
	end
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
			result = cached[ 1 ]
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
	local mask = setmetatable( dofile_mask( e ), { __index = getfenv( 2 ) } )
	setmetatable( e, { __index = mask } )
	setfenv( f, e )()

	local globals = {}
	for k, v in pairs( e ) do
		globals[ k ] = v
	end

	return globals
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return color
function rgba( r, g, b, a )
	return { r = r, g = g, b = b, a = a }
end

function maxn( t )
	local result = table.maxn( t )
	if result == 0 and not t[ 0 ] then return -1 end
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
