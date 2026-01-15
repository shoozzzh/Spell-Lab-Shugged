local key_prefix = "spell_lab_shugged."

local mod_setting = {}

local get = ModSettingGet

---@generic T
---@param key string
---@param value_default T
---@return T
local get_or_default = function( key, value_default )
	local value = ModSettingGet( key )
	if type( value ) ~= type( value_default ) then
		return value_default
	end
	return value
end

local set = ModSettingSet

---@return boolean|string|number|nil
function mod_setting.get( key )
	return get( key_prefix .. key )
end

---@generic T
---@param key string
---@param value_default T
---@return T
function mod_setting.get_or_default( key, value_default )
	return get_or_default( key_prefix .. key, value_default)
end

---@param key string
---@param value boolean|string|number|nil
function mod_setting.set( key, value )
	return set( key_prefix .. key, value )
end

---@class mod_setting_item
local item_mt = {}

---@return boolean|string|number|nil
function item_mt:get()
	return get( self[1] )
end

---@generic T
---@param value_default T
---@return T
function item_mt:get_or_default( value_default )
	return get_or_default( self[1], value_default )
end

---@param value boolean|string|number|nil
function item_mt:set( value )
	return set( self[1], value )
end

---@param key string
---@return mod_setting_item
function mod_setting.item( key )
	return setmetatable( { key_prefix .. key }, item_mt )
end

return mod_setting
