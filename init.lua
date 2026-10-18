local mod_id = "spell_lab_shugged"
local mod_path = "mods/" .. mod_id .. "/"

MOD_VERSION = "Shugged v1.8.11"

setmetatable(_G, { __index = { ModTextFileSetContent = ModTextFileSetContent } })

dofile_once(mod_path .. "require.lua")

do
    local translations = ModTextFileGetContent(mod_path .. "files/translations.csv")
    local main = "data/translations/common.csv"
    local main_content = ModTextFileGetContent(main)
    if main_content:sub(#main_content, #main_content) ~= "\n" then
        main_content = main_content .. "\n"
    end
    ModTextFileSetContent(main, main_content .. translations:gsub("^[^\n]*\n", "", 1))
end

-- local settings = require "mod_settings"

-- local default_settings = {
--     ["spell_picker.quick_spell_picker"] = true,
--     ["replace_mode"] = true,
--     ["show_toggle_options"] = true,
--     ["show_locked_spells"] = true,
-- }

-- for key, value in pairs(default_settings) do
--     if settings.get(key) == nil then
--         settings.set(key, value)
--     end
-- end

-- function OnPlayerSpawned(player_id)
--     dofile_once(mod_path .. "libs/controls_freezer.lua").unfreeze()
-- end

local ph_const = {
    ["%%MOD_ID%%"] = mod_id,
    ["%%MOD_PATH%%"] = "mods/" .. mod_id,
}

local ph_module_pattern = {
    ["%%MODULE_ID%%"] = "%s",
    ["%%MODULE_PATH%%"] = "mods/" .. mod_id .. "/files/%s",
    ["%%MODULE_FULL_ID%%"] = mod_id .. ".%s",
}
local function ph_module(module_id)
    local ph = {}
    for k, v in pairs(ph_module_pattern) do
        ph[k] = v:format(module_id)
    end
    return ph
end

local function ph_file(file)
    return { ["%%THIS_PATH%%"] = file:match "^(.*)/[^/]+$" }
end

---@param file string
---@param module_id string?
local function apply_ph(file, module_id)
    if not ModDoesFileExist(file) then
        print_error "Cannot apply placeholders, because file does not exist at:"
        print_error(file)
    end

    local content = ModTextFileGetContent(file)

    for ph, value in pairs(ph_const) do
        content = content:gsub(ph, value)
    end

    for ph, value in pairs(module_id and ph_module(module_id) or {}) do
        content = content:gsub(ph, value)
    end

    for ph, value in pairs(ph_file(file)) do
        content = content:gsub(ph, value)
    end

    ModTextFileSetContent(file, content)
end

do
    local files_used_ph, _ = dofile_once(mod_path .. "files/files_used_ph.lua")
    for _, file in ipairs(files_used_ph or {}) do
        apply_ph(mod_path .. "files/" .. file)
    end
end

local module_list = dofile_once(mod_path .. "files/module_list.lua")
local module_path_pattern = mod_path .. "files/%s/"

for _, module_id in ipairs(module_list) do
    local module_path = module_path_pattern:format(module_id)
    local files_used_ph = module_path .. "files_used_ph.lua"

    for _, file in ipairs(ModDoesFileExist(files_used_ph) and dofile_once(files_used_ph) or {}) do
        apply_ph(module_path .. file, module_id)
    end
end

---@class callbacks
---@field OnBiomeConfigLoaded fun()?
---@field OnCountSecrets (fun(): total: integer, found: integer)?
---@field OnMagicNumbersAndWorldSeedInitialized fun()?
---@field OnModInit fun()?
---@field OnModPostInit fun()?
---@field OnModPreInit fun()?
---@field OnModSettingsChanged fun()?
---@field OnPausePreUpdate fun()?
---@field OnPausedChanged fun(is_paused: boolean, is_inventory_pause: boolean)?
---@field OnPlayerDied fun(player_entity: entity_id)?
---@field OnPlayerSpawned fun(player_entity: entity_id)?
---@field OnWorldInitialized fun()?
---@field OnWorldPostUpdate fun()?
---@field OnWorldPreUpdate fun()?

local callbacks = {
    OnBiomeConfigLoaded = {},
    OnCountSecrets = {},
    OnMagicNumbersAndWorldSeedInitialized = {},
    OnModInit = {},
    OnModPostInit = {},
    OnModPreInit = {},
    OnModSettingsChanged = {},
    OnPausePreUpdate = {},
    OnPausedChanged = {},
    OnPlayerDied = {},
    OnPlayerSpawned = {},
    OnWorldInitialized = {},
    OnWorldPostUpdate = {},
    OnWorldPreUpdate = {},
}

for _, module_id in ipairs(module_list) do
    local module_path = module_path_pattern:format(module_id)
    local init_lua    = module_path .. 'init.lua'
    if not ModDoesFileExist(init_lua) then goto continue end

    ---@type callbacks
    local module_callbacks = dofile(init_lua) or {}

    for name, funcs in pairs(callbacks) do
        funcs[#funcs + 1] = module_callbacks[name]
    end

    ::continue::
end

for name, funcs in pairs(callbacks) do
    if #funcs > 0 then
        _G[name] = function(...)
            for _, f in ipairs(funcs) do f(...) end
        end
    end
end
