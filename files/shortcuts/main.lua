local sc_tostring = require "shortcuts.tostring"
local settings = require "mod_settings"
local tr = require "tr"
local tr_utils = require "tr_utils"

local sc = {}

sc.detector = require "shortcuts.detector"

sc.table = {
    -- select = { "Mouse_left" },
    -- deselect = { "Mouse_right" },
    -- multi_select = { "Key_CTRL", "Mouse_left" },
    -- expand_selection_left = { "Key_CTRL", "Key_ALT", "Mouse_left" },
    -- expand_selection_right = { "Key_CTRL", "Key_ALT", "Mouse_right" },
    -- swap = { "Key_ALT", "Mouse_left" },
    -- override = { "Key_ALT", "Mouse_right" },
    -- duplicate = { "Key_ALT", "Key_SHIFT", "Mouse_left" },
    -- delete_action = { "Key_SHIFT", "Mouse_left" },
    -- delete_slot = { "Key_SHIFT", "Mouse_right" },
    -- always_cast = { "Key_CTRL", "Key_SHIFT", "Mouse_left" },
    -- left_delete = { "Key_BACKSPACE" },
    -- right_delete = { "Key_DELETE" },
    -- undo = { "Key_CTRL", "Key_z" },
    -- redo = { "Key_CTRL", "Key_y" },
    -- relock = { "Key_CTRL", "Key_SHIFT", "Mouse_left" },
    -- show_wand_stats = { "Key_CTRL" },
    -- replace_switch_temp = { "Key_SHIFT" },
    -- replace_switch = {},
    -- confirm = { "Key_SHIFT" },
    -- clear_action_history = { "Key_SHIFT", "Mouse_right" },
    dummy_transform = { "Key_SHIFT" },
    modifier_key_1 = { "Key_CTRL" },
    modifier_key_2 = { "Key_SHIFT" },
    modifier_key_3 = { "Key_ALT" },
}

---@type table<string,string>
sc.text = {}

sc.edit_panel_shortcut_tips = ""

local last_cur_lang = GameTextGet "$current_language"

local function reload_text()
    for name, v in pairs(sc.table) do
        sc.text[name] = sc_tostring(v, last_cur_lang)
    end

    sc.edit_panel_shortcut_tips = tr.shortcut_tips:text()
    for name, v in pairs(sc.table) do
        sc.edit_panel_shortcut_tips = sc.edit_panel_shortcut_tips:gsub("{" .. name .. "}", sc.text[name])
    end
end

---@param shortcut string
---@return shortcut
local function deser(shortcut)
    ModTextFileSetContent("mods/shortcut_set.lua", "return " .. shortcut)
    return loadfile "mods/shortcut_set.lua" ()
end

local function reload()
    for name, _ in pairs(sc.table) do
        local value = settings.get("shortcut." .. name)
        if value == nil then goto continue end

        local status, value = pcall(deser, value)
        if not status or (value == nil) then goto continue end

        sc.table[name] = value
        ::continue::
    end

    if not settings.get "shortcut_strict" then
        sc.used_keys = {}

        local set = {}
        for _, shortcut in pairs(sc.table) do
            for _, key in ipairs(shortcut) do
                set[key] = true
            end
        end
        set.Mouse_left = nil
        set.Mouse_right = nil
        for key, _ in pairs(set) do
            sc.used_keys[#sc.used_keys + 1] = key
        end
    else
        sc.used_keys = nil
    end

    reload_text()
end

reload()

function sc.update()
    if GameGetFrameNum() % 60 ~= 0 then return end
    if settings.get "shortcut_changed" then
        settings.set("shortcut_changed", false)
        reload()
    end

    local cur_lang = tr_utils.get "$current_language"
    if cur_lang ~= last_cur_lang then
        last_cur_lang = cur_lang
        reload_text()
    end
end

return sc
