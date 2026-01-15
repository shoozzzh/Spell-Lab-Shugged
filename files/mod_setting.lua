local key_prefix = "spell_lab_shugged."

local ms = {}

---@generic T
---@param key string
---@param value_default T
---@return T
function ms.get( key, value_default )
	local value = ModSettingGet( key_prefix .. key )
	if type( value ) ~= type( value_default ) then
		return value_default
	end
	return value
end

---@param key string
---@param value boolean|string|number|nil
function ms.set( key, value )
	ModSettingSet( key_prefix .. key, value )
end

---@class mod_setting_item
local item_mt = {}

---@return boolean|string|number|nil
function item_mt:get()
	return ModSettingGet( self[1] )
end

---@param value boolean|string|number|nil
function item_mt:set( value )
	ms.set( self[1], value )
end

---@param key string
---@return mod_setting_item
function ms.item( key )
	return setmetatable( { key_prefix .. key }, item_mt )
end

return ms
