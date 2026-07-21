local MOD_ID = "spell_lab_shugged"
local MOD_PATH = "mods/" .. MOD_ID .. "/"

MOD_VERSION = "Shugged v1.8.11"

setmetatable(_G, { __index = { ModTextFileSetContent = ModTextFileSetContent } })

dofile_once(mod_path .. "require.lua")

local mod_setting = require "mod_setting"
local format = require "format"

local fun = require "tinklin".fun

dofile(mod_path .. "libs/polytools/polytools_init.lua").init(mod_path .. "libs/polytools/")

do
    local translations = ModTextFileGetContent(mod_path .. "files/translations.csv")
    local main = "data/translations/common.csv"
    local main_content = ModTextFileGetContent(main)
    if main_content:sub(#main_content, #main_content) ~= "\n" then
        main_content = main_content .. "\n"
    end
    ModTextFileSetContent(main, main_content .. translations:gsub("^[^\n]*\n", "", 1))
end

local default_settings = {
    ["quick_spell_picker"] = true,
    ["spell_replacement"] = true,
    ["show_toggle_options"] = true,
    ["show_locked_spells"] = true,
}

for key, value in pairs(default_settings) do
    if mod_setting.get(key) == nil then
        mod_setting.set(key, value)
    end
end

function OnPlayerSpawned(player_id)
    dofile_once(mod_path .. "libs/controls_freezer.lua").unfreeze()
end

local module_list = dofile_once(mod_path .. "files/module_list.lua")

local module_path_pattern = mod_path .. "files/%s/"

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

local ph_const = {
    ["%%MOD_ID%%"] = MOD_ID,
    ["%%MOD_PATH%%"] = "mods/" .. MOD_ID,
}
local function ph_module(module_id)
    local result = {
        ["%%MODULE_ID%%"] = "%s",
        ["%%MODULE_PATH%%"] = "mods/" .. MOD_ID .. "/files/%s",
        ["%%MODULE_FULL_ID%%"] = MOD_ID .. ".%s",
    }
    for k, v in pairs(result) do
        result[k] = v:format(module_id)
    end
    return result
end
local function ph_file(file)
    local result = {
        ["%%THIS_PATH%%"] = function(file)
            local folder = file:match "^(.*)/[^/]+$"
        end,
    }
    for k, v in pairs(result) do
        result[k] = v(file)
    end
    return result
end

for _, module_id in ipairs(module_list) do
    local module_path   = module_path_pattern:format(module_id)

    local files_used_ph = dofile_once(mod_path .. "files/files_used_ph.lua")

    for _, file in ipairs(files_used_ph or {}) do
        file = module_path .. file
        if not ModDoesFileExist(file) then
            print_error "File does not exist at:"
            print_error(file)
        end

        local content = ModTextFileGetContent(file)

        fun.entries(ph_const)
            :chain(fun.entries(ph_module(module_id)))
            :chain(fun.entries(ph_file(file)))
            :each(function(ph, value)
                ---@cast ph string
                ---@cast value string
                content = content:gsub(ph, value)
            end)

        ModTextFileSetContent(file, content)
    end

    local init_lua = module_path .. 'init.lua'
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
