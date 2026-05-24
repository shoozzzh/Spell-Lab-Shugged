dofile_once "mods/spell_lab_shugged/files/misc_utils.lua"
local mod_setting = dofile_once(mod_path .. "files/mod_setting.lua")

local player_id = GetUpdatedEntityID()

options_enabled_last_frame = options_enabled_last_frame or {}
if GlobalsGetValue("spell_lab_shugged.refresh_player_state", "0") == "1" then
	options_enabled_last_frame = {}
	GlobalsSetValue("spell_lab_shugged.refresh_player_state", "0")
end

---@class player_option
---@field mod_setting_key string
---@field value_initiator fun(player_id: entity_id): bool
---@field on_enable fun(player_id: entity_id)?
---@field on_disable fun(player_id: entity_id)?
---@field on_enabled_update fun(player_id: entity_id)?
---@field on_disabled_update fun(player_id: entity_id)?

---@class player_opt
---@field mod_setting_key string?
---@field value_initiator nil|fun(player_id: entity_id): bool
---@field on_enable fun(player_id: entity_id)?
---@field on_disable fun(player_id: entity_id)?
---@field on_enabled_update fun(player_id: entity_id)?
---@field on_disabled_update fun(player_id: entity_id)?

---@type player_option[]
player_options = player_options or (function()
	local result = {}
	local module_list = dofile_once(mod_path .. "files/module_list.lua")
	for _, module_name in ipairs(module_list) do
		local path = mod_path .. "files/" .. module_name .. "/player_option.lua"
		if not ModDoesFileExist(path) then goto continue end

		---@type player_option
		local player_option = dofile_once(path)
		result[#result + 1] = player_option

		::continue::
	end
	return result
end)()

for _, player_option in ipairs(player_options) do
	local enabled = mod_setting.get(player_option.mod_setting_key)
	local enabled_last_frame = options_enabled_last_frame[player_option.mod_setting_key]
	if enabled_last_frame == nil then
		enabled_last_frame = player_option.value_initiator()
	end

	if enabled and not enabled_last_frame then
		optional_call(player_option.on_enable, player_id)
	elseif not enabled and enabled_last_frame then
		optional_call(player_option.on_disable, player_id)
	end
	if enabled then
		optional_call(player_option.on_enabled_update, player_id)
	else
		optional_call(player_option.on_disabled_update, player_id)
	end

	options_enabled_last_frame[player_option.mod_setting_key] = enabled
end
