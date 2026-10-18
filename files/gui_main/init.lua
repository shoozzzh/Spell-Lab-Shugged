print "[spell lab] setting up GUI"

local pop = require "pop"
local gui_elems = require "gui.elems"
local settings = require "mod_settings"
local mutils = require "misc_utils"
local tr_utils = require "tr_utils"
local common_val = require "common_values"

-- dofile_once "%MOD_PATH%/files/wand_spell_utils.lua"
WANDS = dofile_once "%MOD_PATH%/libs/wands.lua"

local entry_point = dofile_once "%MODULE_PATH%/entry_point/button.lua"

-- keyboard_focus = dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_focus.lua" )

-- wand_stats = dofile( "mods/spell_lab_shugged/files/gui/wand_stats.lua" )

-- local edit_panel_api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

local menus = require "gui_main.menus"
-- dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )

local function gen_module_button_utils(module_name)
    local button_sprite = "%MOD_PATH%/files/" .. module_name .. "/button.png"
    local setting_item = module_name .. ".enabled"

    ---@class mb_utils
    local button_utils = {
        ---@param name string?
        ---@param desc string?
        ---@vararg string desc_lines
        ---@return boolean left_click
        ---@return boolean right_click
        button_toggle = function(name, desc, ...)
            name = name or tr_utils.get(module_name)
            desc = desc or tr_utils.try(module_name .. ".desc")
            if desc then
                return gui_elems.button_setting_toggle(button_sprite, setting_item, name, desc, ...)
            else
                return gui_elems.button_setting_toggle(button_sprite, setting_item, name, ...)
            end
        end,
        button = function()
            return pop.button(button_sprite)
        end,
        button_menus = function()
            return menus:button(module_name, button_sprite)
        end,
    }
    return button_utils
end

gen_module_button_utils = mutils.memoize(gen_module_button_utils)

local module_button_path = "%MOD_PATH%/files/%s/button.lua"
local function module_button(module_name)
    dofile_once(module_button_path:format(module_name))(gen_module_button_utils(module_name))
end

local function module_button_fns(modules)
    local button_fns = {}
    for _, module_name in ipairs(modules) do
        button_fns[#button_fns + 1] = function()
            module_button(module_name)
        end
    end
    return button_fns
end

local menus_line = module_button_fns {
    "terrain_spell_lab", --[[ "spell_picker", "wand_picker", "wand_box", "spell_group_box", ]]
    "shot_effects", "toggles_toggle", "damage_info", --[[ "wand_edit_panel", ]]
}

local functions_line = module_button_fns {
    "shortcuts", "clear_projectiles", "wand_ready", "wand_clear", "twwe_and_nwt",
    "hp_fixer", "target_dummy", "dummy_transforming", "convenient_wand",
}

local toggles_line = module_button_fns {
    "wand_no_shooting", "no_annoying_effects", "protection_all", "no_polymorphing",
    "no_recoil", "unlimited_spells", "creative_mode_flight", "all_seeing_eye",
}

local function show_gui()
    pop.pos.push(pop.screen_size[1] / 2 + 80, pop.screen_size[2] * 0.02)

    local layout = pop.layout_stack(0, 20 + 2)
    layout:next(function() gui_elems.line_of_buttons(menus_line) end)

    layout:next(function() gui_elems.line_of_buttons(functions_line) end)

    if settings.get "show_toggle_options" then
        layout:next(function() gui_elems.line_of_buttons(toggles_line) end)
    end

    -- if mod_setting_get( "show_wand_edit_panel" ) and held_wand then
    -- 	GuiLayoutBeginLayer( gui )
    -- 	local x, y = horizontal_centered_x(-9,4) + 5, 360 * 0.02 + percent_to_ui_scale_y(2)
    -- 	GuiLayoutBeginVertical( gui, x, y, true )
    -- 	show_edit_panel_toggle_options()
    -- 	GuiLayoutEnd( gui )
    -- 	GuiLayoutEndLayer( gui )
    -- end

    -- do_active_picker_buttons()

    -- do_active_picker_menu()

    -- if mod_setting_get( "show_wand_edit_panel" ) then
    -- 	dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" )
    -- end

    pop.pos.pop()
end

---@type callbacks
local callbacks = {}

function callbacks.OnWorldPreUpdate()
    -- ctrl = InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL)
    -- shift = InputIsKeyDown(Key_LSHIFT) or InputIsKeyDown(Key_RSHIFT)
    -- alt = InputIsKeyDown(Key_LALT) or InputIsKeyDown(Key_RALT)

    pop.start_frame()

    common_val.update()

    pop.option.NoPositionTween = true
    pop.option.HandleDoubleClickAsClick = true
    pop.option.ClickCancelsDoubleClick = true

    local is_panel_open = entry_point()

    -- edit_panel_api.listen_wand_changes()

    -- keyboard_focus.update()

    dofile_once "%MODULE_PATH%/entry_point/button.lua" ()

    if is_panel_open and not GameIsInventoryOpen() and common_val.player and not GameHasFlagRun "gkbrkn_config_menu_open" then
        show_gui()
    else
        -- keyboard_focus.change_to( "player_controls" )
    end
end

print "[spell lab] done setting up GUI"

return callbacks
