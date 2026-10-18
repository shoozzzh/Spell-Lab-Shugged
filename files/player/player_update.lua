dofile_once "%MOD_PATH%/require.lua"
local settings = require "mod_settings"
local tl = require "tinklin"
local mutils = require "misc_utils"

local player = tl.entity_cur()

options_enabled_last_frame = options_enabled_last_frame or {}
if GlobalsGetValue("%MOD_ID%.refresh_player_state", "0") == "1" then
    options_enabled_last_frame = {}
    GlobalsSetValue("%MOD_ID%.refresh_player_state", "0")
end

---@class player_option
---@field mod_setting_key string
---@field value_initiator fun(player: entity): bool
---@field on_enable fun(player: entity)?
---@field on_disable fun(player: entity)?
---@field on_enabled_update fun(player: entity)?
---@field on_disabled_update fun(player: entity)?

---@class player_opt
---@field mod_setting_key string?
---@field value_initiator nil|fun(player: entity): bool
---@field on_enable fun(player: entity)?
---@field on_disable fun(player: entity)?
---@field on_enabled_update fun(player: entity)?
---@field on_disabled_update fun(player: entity)?

---@type player_option[]
player_options = player_options or (function()
    local result = {}
    local module_list = dofile_once "%MOD_PATH%/files/module_list.lua"
    for _, module_name in ipairs(module_list) do
        local path = "%MOD_PATH%/files/" .. module_name .. "/player_option.lua"
        if not ModDoesFileExist(path) then goto continue end

        ---@type player_option
        local player_option = dofile_once(path)
        result[#result + 1] = player_option

        ::continue::
    end
    return result
end)()

for _, player_option in ipairs(player_options) do
    local enabled = settings.get(player_option.mod_setting_key)
    local enabled_last_frame = options_enabled_last_frame[player_option.mod_setting_key]
    if enabled_last_frame == nil then
        enabled_last_frame = player_option.value_initiator(player)
    end

    if enabled and not enabled_last_frame then
        mutils.call_if_present(player_option.on_enable, player)
    elseif not enabled and enabled_last_frame then
        mutils.call_if_present(player_option.on_disable, player)
    end
    if enabled then
        mutils.call_if_present(player_option.on_enabled_update, player)
    else
        mutils.call_if_present(player_option.on_disabled_update, player)
    end

    options_enabled_last_frame[player_option.mod_setting_key] = enabled
end
