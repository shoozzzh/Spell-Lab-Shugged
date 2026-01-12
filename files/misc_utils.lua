local mod_id = "spell_lab_shugged"

local key_prefix = "$" .. mod_id .. "_"
local mod_settings_prefix = mod_id .. "."

---@param key string
function wrap_key( key )
	return key_prefix .. key
end

---@param key string
function get_text( key )
	return GameTextGetTranslatedOrNot( wrap_key( key ) )
end

---@param key string
function mod_setting_get( key )
	return ModSettingGet( mod_settings_prefix .. key )
end

---@param key string
---@param value boolean|string|number|nil
function mod_setting_set( key, value )
	ModSettingSet( mod_settings_prefix .. key, value )
end

---@param f fun( ... )|nil
---@return any
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

local function dofile_mask( env )
	local loadonce, loaded = {}, {}
	local mask = {}
	mask.do_mod_appends = function( filepath )
		for _, filepath in ipairs( ModLuaFileGetAppends( filepath ) ) do
			mask.dofile( filepath )
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
