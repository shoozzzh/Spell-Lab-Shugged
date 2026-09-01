dofile_once "data/scripts/lib/utilities.lua"
dofile_once "data/scripts/lib/mod_settings.lua"

-- mod_settings_version = 1
mod_settings_version = 2

do
    ---@type fun()[]
    local upgrades = {}
    upgrades[1] = function()
        local simple = {
            ["action_button_click_sound"] = "general.action_button_click_sound",
            ["action_history"] = "spell_picker.action_history",
            ["action_history_limit"] = "spell_picker.action_history_limit",
            ["all_seeing_eye_lighting"] = "all_seeing_eye.brightening",
            ["all_seeing_eye_fog_of_war_removing"] = "all_seeing_eye.fog_of_war_removing",
            ["better_all_seeing_eye"] = "all_seeing_eye.enabled",
            ["button_click_sound"] = "general.button_click_sound",
            ["creative_mode_flight"] = "creative_mode_flight.enabled",
            ["creative_mode_flight_speed_faster"] = "creative_mode_flight.speed_faster",
            ["creative_mode_flight_speed_no_clip"] = "creative_mode_flight.speed_no_clip",
            ["creative_mode_flight_speed_normal"] = "creative_mode_flight.speed_normal",
            ["disable_casting"] = "wand_no_shooting.enabled",
            ["disable_death"] = "",
            ["disable_toxic_statuses"] = "no_annoying_effects.enabled",
            ["edit_wands_everywhere"] = "",
            ["filter_buttons_trigger"] = "spell_picker.filter_buttons_trigger",
            ["gif_mode"] = "wand_edit_panel.gif_mode",
            ["invincible"] = "protection_all.enabled",
            ["migrated_wand_box_data_from_spell_lab"] = "wand_box.auto_migrated_data_from.spell_lab",
            ["migrated_wand_box_data_from_ecsgui"] = "wand_box.auto_migrated_data_from.ecsgui",
            ["no_polymorphing"] = "no_polymorphing.enabled",
            ["no_recoil"] = "no_recoil.enabled",
            ["no_weather"] = "no_weather.enabled",
            ["quick_spell_picker"] = "spell_picker.try_put_in_panel",
            ["replace_mode"] = "spell_picker.replace_mode",
            ["show_locked_spells"] = "spell_picker.show_locked_spells",
            ["toggle_options"] = "toggle_options.showing",
            ["show_wand_edit_panel"] = "wand_edit_panel.showing",
            ["special_filter_button_align_to"] = "",
            ["unlimited_spells"] = "unlimited_spells.enabled",
            ["wand_box_page_max_index"] = "wand_box.last_page_index",
            ["wand_edit_panel_history_limit"] = "wand_edit_panel.history_limit",
            ["wand_edit_panel_max_actions_per_row"] = "wand_edit_panel.max_actions_per_row",
            ["wand_edit_panel_max_rows"] = "wand_edit_panel.max_rows",
            ["wand_listener_type"] = "wand_edit_panel.wand_listener_type",
            ["wand_picker_precise_mode"] = "wand_picker.precise_mode",
            ["zero_uses"] = "spell_picker.zero_uses",
        }
        local prefix = {
            ["shortcut_"] = "shortcut.",
            ["wand_box_page_"] = "wand_box.page_",
        }
        for old_key, new_key in pairs(simple) do
            old_key = "spell_lab_shugged." .. old_key
            local value = ModSettingGet(old_key)
            if value == nil then goto continue end
            ModSettingRemove(old_key)
            if new_key ~= "" then
                new_key = "spell_lab_shugged." .. new_key
                ModSettingSetNextValue(new_key, value, false)
            end
            ::continue::
        end
        for old_key_prefix, new_key_prefix in pairs(prefix) do
            old_key_prefix = "spell_lab_shugged." .. old_key_prefix
            new_key_prefix = "spell_lab_shugged." .. new_key_prefix
            local old_prefix_length = #old_key_prefix
            for i = 0, ModSettingGetCount() - 1 do
                local old_key, value = ModSettingGetAtIndex(i)
                if old_key == nil or value == nil then goto continue end
                if old_key:sub(1, old_prefix_length) ~= old_key_prefix then goto continue end

                local new_key = new_key_prefix .. old_key:sub(old_prefix_length + 1, -1)
                ModSettingRemove(old_key)
                ModSettingSetNextValue(new_key, value, false)
                ::continue::
            end
        end
    end

    local _version = ModSettingGet "spell_lab_shugged._version"
    if _version < mod_settings_version then
        for i = _version, mod_settings_version - 1 do
            upgrades[i]()
        end
    end
end

local cc = (function() -- clikclak.lua, you may wanna fold these
    local clikclak = {}

    function clikclak.load_lang(settings, lang)
        local function get_text(key)
            return lang[key] or ('Missing text for key "' .. key .. '"')
        end
        local function recursive(setting)
            if setting.id then
                setting.ui_name = get_text(setting.id)
                setting.ui_description = get_text(setting.id .. ".desc")

                if setting.values_raw then
                    setting.values = {}
                    for _, v in ipairs(setting.values_raw) do
                        setting.values[#setting.values + 1] = { v, get_text(setting.id .. ".values." .. v) }
                    end
                end
                setting.scope = setting.scope or MOD_SETTING_SCOPE_RUNTIME
            elseif setting.category_id then
                setting.ui_name = get_text(setting.category_id)
                setting.ui_description = get_text(setting.category_id .. ".desc")
                for _, s in ipairs(setting.settings) do
                    recursive(s)
                end
            end
        end

        for _, s in ipairs(settings) do
            recursive(s)
        end
    end

    local function extra(self, extra_fields)
        for k, v in pairs(extra_fields) do
            self[k] = v
        end
        return self
    end
    clikclak.extra = extra -- for user extensions

    ---@param id string
    ---@return fun(values: string[], value_default: string?): table
    function clikclak.enum(id)
        return function(values, value_default)
            return {
                id = id,
                value_default = value_default or values[1],
                values_raw = values,
                extra = extra,
            }
        end
    end

    ---@param id string
    ---@return fun(value_default: boolean): table
    function clikclak.checkbox(id)
        return function(value_default)
            return {
                id = id,
                value_default = value_default,
                extra = extra,
            }
        end
    end

    local function get_next_value(mod_id, setting)
        return ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))
    end

    local function set_next_value(mod_id, setting, value)
        return ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), value, false)
    end

    local function mod_setting_number_better(mod_id, gui, in_main_menu, im_id, setting)
        local value = get_next_value(mod_id, setting)
        if type(value) ~= "number" then value = setting.value_default or 0.0 end

        if setting.value_min == nil or setting.value_max == nil or setting.value_default == nil then
            GuiText(gui, mod_setting_group_x_offset, 0,
                setting.ui_name .. " - not all required values are defined in setting definition")
            return
        end

        local value_new = GuiSlider(gui, im_id, mod_setting_group_x_offset, 0,
            setting.ui_name, value, setting.value_min, setting.value_max, setting.value_default,
            0, setting.value_formatter(value), 64)
        if value ~= value_new then
            set_next_value(mod_id, setting, value_new)
            mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, value, value_new)
        end

        mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
    end

    ---@param id string
    ---@return fun(value_default: number, value_min: number, value_max: number, value_formatter: fun(value: number): string): table
    function clikclak.slider(id)
        return function(value_default, value_min, value_max, value_formatter)
            return {
                id = id,
                value_default = value_default,
                value_min = value_min,
                value_max = value_max,
                value_formatter = value_formatter,
                ui_fn = mod_setting_number_better,
                extra = extra,
            }
        end
    end

    ---@param id string
    ---@return fun(value_default: integer|string, max_length: integer): table
    function clikclak.input_int(id)
        return function(value_default, max_length)
            return {
                id = id,
                value_default = tostring(value_default),
                text_max_length = max_length,
                allowed_characters = "0123456789",
                extra = extra,
            }
        end
    end

    ---@param id string
    ---@return fun(settings: table[]): table
    function clikclak.cat(id)
        return function(settings)
            return {
                category_id = id,
                settings = settings,
                foldable = true,
                _folded = true,
                extra = extra,
            }
        end
    end

    return clikclak
end)()

local _ = (function() -- shortcut_setting.lua
    local function a(b)
        if not b then return "{}" end
        local c = { '{"' }
        for d = 1, #b do c[d + 1] = b[d] end; c[#c + 1] = '"}'
        return table.concat(c, '","')
    end; local function e(b)
        ModTextFileSetContent("mods/shortcut_set.lua", "return " .. b)
        return loadfile "mods/shortcut_set.lua" ()
    end; local f = (function()
        local g = {
            MINUS = "-",
            EQUALS = "=",
            LEFTBRACKET = "[",
            RIGHTBRACKET = "]",
            BACKSLASH = "\\",
            NONUSHASH = "#",
            SEMICOLON =
            ";",
            APOSTROPHE = "'",
            GRAVE = "`",
            COMMA = ",",
            PERIOD = ".",
            SLASH = "/",
            NUMLOCKCLEAR = "NUMLOCK",
            KP_DIVIDE =
            "/",
            KP_MULTIPLY = "*",
            KP_MINUS = "-",
            KP_PLUS = "+",
            KP_PERIOD = ".",
            NONUSBACKSLASH = "\\",
            APPLICATION =
            "MENU",
            POWER = "SHUTDOWN",
            KP_EQUALS = "=",
            KP_COMMA = ",",
            KP_EQUALSAS400 = "=",
            KP_LEFTPAREN = "(",
            KP_RIGHTPAREN =
            ")",
            KP_LEFTBRACE = "{",
            KP_RIGHTBRACE = "}",
            KP_XOR = "^",
            KP_POWER = "SHUTDOWN",
            KP_PERCENT = "%",
            KP_LESS =
            "<",
            KP_GREATER = ">",
            KP_AMPERSAND = "&",
            KP_DBLAMPERSAND = "&&",
            KP_VERTICALBAR = "|",
            KP_DBLVERTICALBAR = "||",
            KP_COLON =
            ":",
            KP_HASH = "#",
            KP_AT = "@",
            KP_EXCLAM = "!",
            KP_PLUSMINUS = "+-",
            LGUI = "LEFT WINDOWS",
            RGUI =
            "RIGHT WINDOWS",
        }
        local h = {
            Key_CTRL = "Ctrl",
            Key_SHIFT = "Shift",
            Key_ALT = "Alt",
            JOY_BUTTON_0 = "$input_xboxbutton_a",
            JOY_BUTTON_1 =
            "$input_xboxbutton_b",
            JOY_BUTTON_2 = "$input_xboxbutton_x",
            JOY_BUTTON_3 = "$input_xboxbutton_y",
            Mouse_x1 =
            "$input_mousebutton4",
            Mouse_x2 = "$input_mousebutton5",
        }
        local i = { ["简体中文"] = { Mouse_left = "左键", Mouse_right = "右键" }, DEFAULT = { Mouse_left = "Left-click", Mouse_right = "Right-click" } }
        do
            local j = { "喵体中文", "汪体中文", "完全汉化" }
            for k, l in ipairs(j) do i[l] = i["简体中文"] end
        end; local function m(n, d)
            local o = h[n]
            if o then return GameTextGetTranslatedOrNot(o) end; local p = i[d] or i.DEFAULT; o = p[n]
            if o then return o end; if n:find "^Mouse_" then
                return GameTextGet("$input_" .. n:gsub("_", ""):lower())
                    :upper()
            elseif n:find "^Key_" then
                local q = n:sub(5):upper()
                o = g[q]
                if o then return o end; local r = 0; o, r = q:gsub("^KP_", "KEYPAD ")
                if r > 0 then return o end; o, r = q:gsub("^AC_", "AC ")
                if r > 0 then return o end; return q
            elseif n:find "^JOY_BUTTON_" then
                local o = GameTextGet("$input_xboxbutton_" .. n:sub(12):lower())
                if n:find "%d%d_DOWN$" then
                    o = o .. " DOWN"
                elseif n:find "%d%d_MOVED$" then
                    o = o .. " MOVED"
                else
                    o = ("(%s)")
                        :format(o)
                end; return o
            end; return GameTextGet "$menuoptions_configurecontrols_keyname_unknown"
        end; local s = { Key_CTRL = -100, Key_ALT = -99, Key_SHIFT = -98, DEFAULT = 0, Mouse_left = 99, Mouse_right = 100 }
        local function t(u)
            table.sort(u,
                function(v, w)
                    local x = s[v] or s.DEFAULT; local y = s[w] or s.DEFAULT; if x ~= y then return x < y end; local z = #
                        v; local A = #w; if z ~= A then return z > A end; return v < w
                end)
        end; function shortcut_tostring(u, d)
            local B = {}
            for C, l in pairs(u) do B[C] = l end; local D = B[#B]
            B[#B] = nil; t(B)
            B[#B + 1] = D; local E = {}
            for k, F in ipairs(B) do E[#E + 1] = m(F, d) end; return table.concat(E, " + ")
        end
    end)()
    local G = (function()
        local g, h = unpack((function()
            local i = loadfile "data/scripts/debug/keycodes.lua"
            local j = {}
            setfenv(i, j)()
            local k = { Mouse = {}, Keyboard = {}, Joystick = {} }
            for l, m in pairs(j) do
                if l:find "^Mouse_" then
                    k.Mouse[l] = m
                elseif l:find "^Key_" then
                    k.Keyboard[l] = m
                elseif l:find "^JOY_BUTTON_" then
                    k.Joystick[l] =
                        m
                end
            end; local n = { "JOY_BUTTON_0", "JOY_BUTTON_1", "JOY_BUTTON_2", "JOY_BUTTON_3" }
            for d, o in ipairs { j, k.Mouse, k.Keyboard, k.Joystick } do for d, p in ipairs(n) do o[p] = nil end end; return {
                j, k }
        end)())
        local q = {}
        local r = {}
        for s, t in pairs(h.Keyboard) do
            r[s] = { function() return InputIsKeyDown(t) end, function()
                return
                    InputIsKeyJustDown(t)
            end }
        end; for s, t in pairs(h.Mouse) do
            if s ~= "Mouse_left" or s ~= "Mouse_right" then
                r[s] = { function()
                    return
                        InputIsMouseButtonDown(t)
                end, function() return InputIsMouseButtonJustDown(t) end }
            end
        end; do
            local u = { Key_ALT = { "Key_LALT", "Key_RALT" }, Key_CTRL = { "Key_LCTRL", "Key_RCTRL" }, Key_SHIFT = { "Key_LSHIFT", "Key_RSHIFT" } }
            local v = function(w) return function() for g, n in ipairs(w) do if n() then return true end end end end; for x, y in pairs(u) do
                local z, A = {}, {}
                for g, B in ipairs(y) do
                    local C, D = unpack(r[B])
                    z[#z + 1] = C; A[#A + 1] = D; r[B] = nil
                end; r[x] = { v(z), v(A) }
            end
        end; local E = {}
        local F = { JOY_BUTTON_A = true, JOY_BUTTON_B = true, JOY_BUTTON_LEFT_STICK_LEFT = true, JOY_BUTTON_LEFT_STICK_RIGHT = true, JOY_BUTTON_LEFT_STICK_UP = true, JOY_BUTTON_LEFT_STICK_DOWN = true }
        for H, I in pairs(h.Joystick) do
            if F[H] then
                local C = function()
                    for J = 0, 7 do if E[J] and InputIsJoystickButtonDown(J, I) then return true end end; return false
                end; r[H] = { C, nil }
            end
        end; do
            local K = {}
            for B, g in pairs(r) do K[#K + 1] = B end; for B, g in ipairs(h.Joystick) do K[#K + 1] = B end; q.listened_keys =
                K
        end; local L = {}
        for B, g in pairs(r) do L[B] = 0 end; q.just_down = {}
        q.down = {}
        function q:update()
            local M = self.just_down; local N = self.down; for p = 0, 7 do E[p] = InputIsJoystickConnected(p) end; for H, O in pairs(r) do
                local C, D = unpack(O)
                local P = L[H]
                local Q = C()
                if D then M[H] = D() else M[H] = not N[H] and Q end; if P > 30 then M[H] = true end; N[H] = Q; if N[H] then
                    L[H] =
                        P + 1
                else
                    L[H] = 0
                end
            end
        end; return q
    end)()
    local R = { ["简体中文"] = { done = "[完成]", clear = "[清空]", cancel = "[取消]" }, DEFAULT = { done = "[Done]", clear = "[Clear]", cancel = "[Cancel]" } }
    for f, S in ipairs { "喵体中文", "汪体中文", "完全汉化" } do R[S] = R["简体中文"] end; Shortcut_Type = { OneShot = 0, Sustained = 1 }
    local T = nil; local U = nil; local function V(W)
        local X = true; for f, Y in ipairs(U) do
            if W == Y then
                X = false; break
            end
        end; if X then U[#U + 1] = W end
    end; function mod_setting_shortcut(Z, _, a0, a1, a2)
        GuiLayoutBeginHorizontal(_, 0, 0, true, 2, 2)
        GuiButton(_, 4 * a1, mod_setting_group_x_offset, 0, a2.ui_name)
        local a3 = GuiGetTextDimensions(_, a2.ui_name)
        local f, f, f, C, D = GuiGetPreviousWidgetInfo(_)
        local a4 = GameTextGet "$current_language"
        GuiIdPushString(_, "spell_lab_shugged.shortcut_setting.extra_button")
        local a5 = false; if T == a2.id then
            G:update()
            for W, a6 in pairs(G.just_down) do if a6 then V(W) end end; local a7; if #U > 0 then
                a7 = shortcut_tostring(
                    U, a4)
            else
                a7 = "$menuoptions_configurecontrols_pressakey"
            end; GuiOptionsAddForNextWidget(_,
                GUI_OPTION.Layout_NoLayouting)
            GuiColorSetForNextWidget(_, 1, 1, 0.5, 1)
            local a8, a9 = GuiButton(_, a1, C + 120, D, a7)
            if a2.shortcut_type ~= Shortcut_Type.Sustained then
                if a8 then
                    V "Mouse_left"
                elseif a9 then
                    V
                    "Mouse_right"
                end
            end; if a8 or a9 then
                a5 = true; ModSettingSetNextValue(mod_setting_get_id(Z, a2), a(U), false)
                T = nil; U = nil
            end; mod_setting_tooltip(Z, _, a0, a2)
            GuiLayoutEnd(_)
            GuiLayoutBeginHorizontal(_, mod_setting_group_x_offset + 120, 0, true, 2, 2)
            if GuiButton(_, 4 * a1 + 1, 0, 0, (R[a4] or R.DEFAULT).done) then
                a5 = true; ModSettingSetNextValue(mod_setting_get_id(Z, a2), a(U), false)
                T = nil; U = nil
            end; if GuiButton(_, 4 * a1 + 2, 0, 0, (R[a4] or R.DEFAULT).clear) then U = {} end; if GuiButton(_, 4 * a1 + 3, 0, 0, (R[a4] or R.DEFAULT).cancel) then
                T = nil; U = nil
            end; GuiLayoutEnd(_)
        else
            local a7; do
                local aa = ModSettingGetNextValue(mod_setting_get_id(Z, a2))
                if type(aa) ~= "string" then aa = a2.value_default or "{}" end; local b; do
                    local a6, f = pcall(function() b = e(aa) end)
                    if not a6 then b = {} end
                end; if #b == 0 then
                    a7 = "$menuoptions_configurecontrols_action_unbound"
                else
                    a7 = shortcut_tostring(b,
                        GameTextGet "$current_language")
                end
            end; GuiOptionsAddForNextWidget(_, GUI_OPTION.Layout_NoLayouting)
            local a8, a9 = GuiButton(_, a1, C + 120, D, a7)
            if a8 and not a9 then
                T = a2.id; U = {}
            elseif not a8 and a9 then
                ModSettingSetNextValue(mod_setting_get_id(Z, a2), a2.value_default, false)
                a5 = true
            end; mod_setting_tooltip(Z, _, a0, a2)
            GuiLayoutEnd(_)
        end; GuiIdPop(_)
        if a5 then ModSettingSetNextValue(Z .. ".shortcut_changed", true, false) end
    end
end)()

local function format_percent(value)
    return (" %.0f%%"):format(value * 100)
end

local lang = { -- you may wanna fold these
    en = {
        wand_edit_panel = "Wand Edit Panel",
        wand_edit_panel_max_num_rows = "Max Rows",
        wand_edit_panel_max_num_rows_description =
        "How many rows should the wand edit panel show at most at the same time?\n5 by default",
        wand_edit_panel_max_actions_per_row = "Max Slots In One Row Limit",
        wand_edit_panel_max_actions_per_row_description =
        "How many slots should one row of the wand edit panel contain at most?\nNote: That is calculated with your virtual resolution magic numbers\n0 = No extra limit to it",
        wand_edit_panel_history_limit = "Max Histories",
        wand_edit_panel_history_limit_description =
        "How many recent operations should the wand edit panel remember?\n30 by default",
        wand_listener_type = "Wand Listening",
        wand_listener_type_description =
        "From which wand(s) should be listened to track any external options?\nValue doesn't change the way you edit wand, but changes how many histories will be created",
        wand_listener_type_values_INV = "All Wands in Inventory",
        wand_listener_type_values_HAND = "Held Wand",
        wand_listener_type_values_PANEL = "Held Wand(Only when the wand edit panel is shown)",
        spell_picker = "Spell Picker",
        filter_buttons_trigger = "Switch between types",
        filter_buttons_trigger_description = "How to trigger the spell type buttons?",
        filter_buttons_trigger_values_HOVER = "Hover",
        filter_buttons_trigger_values_CLICK = "Click",
        action_history_limit = "Recently Used Spells Limit",
        action_history_limit_description =
        "How many recently used spells should the spell picker menu remember?\n96 by default",
        show_icon_unlocked = "Mark Out Unlocked Spells",
        show_icon_unlocked_description = "Should we mark out unlocked spells with a small icon in the top right corner?",
        include_spells_in_non_inv_wand = "Include Spells In Nearby Wands",
        include_spells_in_non_inv_wand_description =
        "Should spells in nearby wands be shown in Inv/Nearby page of the spell picker?",
        show_screen_keyboard = "Show Screen Keyboard In Spell Search Page",
        creative_mode_flight_speed = "Superflight Speed",
        creative_mode_flight_speed_normal = "Normal",
        creative_mode_flight_speed_normal_description = "200 by default",
        creative_mode_flight_speed_faster = "Faster",
        creative_mode_flight_speed_faster_description = "450 by default",
        creative_mode_flight_speed_no_clip = "No Clip",
        creative_mode_flight_speed_no_clip_description = "300 by default",
        all_seeing_eye = "Effect of All-seeing Eye",
        all_seeing_eye_lighting = "Lighting",
        all_seeing_eye_fog_of_war_removing = "Fog of War Removing",
        shortcut = "Shortcuts Setting",
        shortcut_strict = "Strict Detection",
        shortcut_strict_description = "Should keys that not used in any shortcut be considered in shortcut detection?",
        shortcut_click_to_save = " (click to save)",
        shortcut_click_here = " + (click here)",
        shortcut_general = "Wand Edit Panel, Wand Box & Spell Group Box",
        shortcut_multi_selectable = "Wand Edit Panel & Wand Box",
        shortcut_select = "Select",
        shortcut_deselect = "Deselect",
        shortcut_multi_select = "Multiple selection",
        shortcut_expand_selection_left = "Expand selection on the left side",
        shortcut_expand_selection_right = "Expand selection on the right side",
        shortcut_swap = "Swap/Cycle",
        shortcut_override = "Move",
        shortcut_wand_edit_panel = "Wand Edit Panel",
        shortcut_duplicate = "Duplicate spell(s)",
        shortcut_delete_action = "Delete spell",
        shortcut_delete_slot = "Delete slot",
        shortcut_always_cast = "Promote/Demote always-cast",
        shortcut_undo = "Undo",
        shortcut_redo = "Redo",
        shortcut_left_delete = "Delete to the left",
        shortcut_right_delete = "Delete to the right",
        shortcut_spell_picker = "Spell Picker",
        shortcut_relock = "Relock unlocked spell",
        shortcut_replace_switch_temp = "Invert replace mode",
        shortcut_clear_action_history = "Clear spell history",
        shortcut_wand_box = "Wand Box",
        shortcut_show_wand_stats = "Show wand stats",
        shortcut_confirm = "Confirm (deletions, etc.)",
        shortcut_transform_mortal_into_dummy = "Target dummy transformation",
        no_weather = "Disable Weather",
        no_weather_description = "Should we disable all kinds of rain or snow?",
        dummy_target_show_full_damage_number = "Show Full Damage Number For Dummy Targets",
        dummy_target_show_full_damage_number_description =
        "Should dummy targets always has full-length damage numbers shown?",
        button_click_sound = "Button Click Sound",
        action_button_click_sound = "Spell Button Click sound",
    },
    zh_cn = {
        wand_edit_panel = "法杖编辑面板",
        wand_edit_panel_max_num_rows = "最大行数",
        wand_edit_panel_max_num_rows_description = "法杖编辑面板最多可以同时显示的行数，默认为 5",
        wand_edit_panel_max_actions_per_row = "单行格数限制",
        wand_edit_panel_max_actions_per_row_description =
        "限制法杖编辑面板单行最多可以显示的格数\n单行最多能容纳的格数自动由虚拟分辨率计算得出，然后应用此限制\n0 = 不进行限制",
        wand_edit_panel_history_limit = "历史记录最大条数",
        wand_edit_panel_history_limit_description = "法杖编辑面板保留最近操作的数量，默认为 30",
        wand_listener_type = "法杖监听",
        wand_listener_type_description = "法杖编辑面板应该从哪些法杖监听外部操作？\n该设置不影响编辑，但会影响历史记录的产生数量",
        wand_listener_type_values_INV = "背包中所有法杖",
        wand_listener_type_values_HAND = "手持法杖",
        wand_listener_type_values_PANEL = "手持法杖（仅法杖编辑面板显示时）",
        spell_picker = "法术选取菜单",
        filter_buttons_trigger = "法术类别切换方式",
        filter_buttons_trigger_description = "法术类别按钮应该如何触发？",
        filter_buttons_trigger_values_HOVER = "悬浮",
        filter_buttons_trigger_values_CLICK = "点击",
        action_history_limit = "法术使用记录最大条数",
        action_history_limit_description = "法术选取菜单保留的法术使用记录条数，默认为 96",
        show_icon_unlocked = "标记已解锁法术",
        show_icon_unlocked_description = "开启时，将在已解锁法术右上角显示图标，以便重新锁定它们",
        include_spells_in_non_inv_wand = "背包/附近页面显示附近法杖中法术",
        include_spells_in_non_inv_wand_description = "开启时，法术选取菜单的背包/附近页面将显示附近法杖中法术",
        show_screen_keyboard = "法术搜索页面显示软键盘",
        creative_mode_flight_speed = "超级飞行速度",
        creative_mode_flight_speed_normal = "正常",
        creative_mode_flight_speed_normal_description = "默认：200",
        creative_mode_flight_speed_faster = "加速",
        creative_mode_flight_speed_faster_description = "默认：450",
        creative_mode_flight_speed_no_clip = "穿墙",
        creative_mode_flight_speed_no_clip_description = "默认：300",
        all_seeing_eye = "全视之眼效果",
        all_seeing_eye_lighting = "照明",
        all_seeing_eye_fog_of_war_removing = "移除战争迷雾",
        shortcut = "快捷键设置",
        shortcut_strict = "严格检测",
        shortcut_strict_description = "没有包含在任何快捷键中的键是否应该影响快捷键检测？",
        shortcut_click_to_save = "（点击以保存）",
        shortcut_click_here = " +（请点击）",
        shortcut_general = "法杖编辑面板、法杖仓库 & 法术组合仓库",
        shortcut_multi_selectable = "法杖编辑面板 & 法杖仓库",
        shortcut_select = "选择",
        shortcut_deselect = "取消选择",
        shortcut_multi_select = "选择多个",
        shortcut_expand_selection_left = "扩展左边选区",
        shortcut_expand_selection_right = "扩展右边选区",
        shortcut_swap = "交换/轮换",
        shortcut_override = "移动",
        shortcut_wand_edit_panel = "法杖编辑面板",
        shortcut_duplicate = "复制选中法术至此处",
        shortcut_delete_action = "删除法术",
        shortcut_delete_slot = "删除法术及其槽位",
        shortcut_always_cast = "设置/取消始终施放",
        shortcut_undo = "撤销",
        shortcut_redo = "恢复",
        shortcut_left_delete = "向左删除",
        shortcut_right_delete = "向右删除",
        shortcut_spell_picker = "法术选取菜单",
        shortcut_relock = "重新锁定已解锁法术",
        shortcut_replace_switch_temp = "临时开启/关闭法术替换模式",
        shortcut_clear_action_history = "清除法术历史",
        shortcut_wand_box = "法杖仓库",
        shortcut_show_wand_stats = "显示法杖信息",
        shortcut_confirm = "确认（删除等）",
        shortcut_transform_mortal_into_dummy = "转化生物为伤害测试假人",
        no_weather = "禁用天气",
        no_weather_description = "开启时，天气将锁定为晴朗状态",
        dummy_target_show_full_damage_number = "伤害测试假人显示完整伤害数字",
        dummy_target_show_full_damage_number_description = "开启时，将以完整形式而不是科学计数法显示伤害数字",
        button_click_sound = "按钮点击音效",
        action_button_click_sound = "法术按钮点击音效",
    },
    ja = {
        wand_edit_panel = "杖編集パネル",
        wand_edit_panel_max_num_rows = "最大行数",
        wand_edit_panel_max_num_rows_description = "杖編集パネルに同時に表示する最大行数をいくつにするか\nデフォルト：5",
        wand_edit_panel_max_actions_per_row = "1行あたりの最大スロット数制限",
        wand_edit_panel_max_actions_per_row_description =
        "杖編集パネルの1行に含める最大スロット数をいくつにするか\n注意：仮想解像度に基づいて自動で計算されます\n0 = 追加制限なし",
        wand_edit_panel_history_limit = "最大履歴数",
        wand_edit_panel_history_limit_description = "杖編集パネルが記憶する最近の操作数をいくつにするか\nデフォルト：30",
        wand_listener_type = "杖の監視",
        wand_listener_type_description = "外部操作を追跡するためにどの杖を監視するか\nこの値は杖の編集方法には影響しませんが、作成される履歴数が変わります",
        wand_listener_type_values_INV = "インベントリ内のすべての杖",
        wand_listener_type_values_HAND = "手持ちの杖",
        wand_listener_type_values_PANEL = "手持ちの杖（杖編集パネルが表示されているときのみ）",
        spell_picker = "呪文セレクター",
        filter_buttons_trigger = "タイプ間の切り替え",
        filter_buttons_trigger_description = "呪文タイプのボタンをどうトリガーするか",
        filter_buttons_trigger_values_HOVER = "ホバー",
        filter_buttons_trigger_values_CLICK = "クリック",
        action_history_limit = "最近使用した呪文の上限",
        action_history_limit_description = "呪文セレクターメニューが記憶する最近使用した呪文数をいくつにするか\nデフォルト：96",
        show_icon_unlocked = "解禁済み呪文をマーク",
        show_icon_unlocked_description = "解禁済み呪文を右上の小さなアイコンでマークするか",
        include_spells_in_non_inv_wand = "近くの杖の呪文を含める",
        include_spells_in_non_inv_wand_description = "呪文セレクターの所持&付近のページで近くの杖の呪文を表示するか",
        show_screen_keyboard = "呪文検索ページでスクリーンキーボードを表示",
        creative_mode_flight_speed = "スーパー飛行速度",
        creative_mode_flight_speed_normal = "通常",
        creative_mode_flight_speed_normal_description = "デフォルト：200",
        creative_mode_flight_speed_faster = "高速",
        creative_mode_flight_speed_faster_description = "デフォルト：450",
        creative_mode_flight_speed_no_clip = "壁抜け",
        creative_mode_flight_speed_no_clip_description = "デフォルト：300",
        all_seeing_eye = "お見通しの効果",
        all_seeing_eye_lighting = "照明",
        all_seeing_eye_fog_of_war_removing = "戦場の霧の除去",
        shortcut = "ショートカット設定",
        shortcut_strict = "厳密検出",
        shortcut_strict_description = "どのショートカットにも使われていないキーを、ショートカット検出に含めるか",
        shortcut_click_to_save = "（クリックで保存）",
        shortcut_click_here = "#NAME?",
        shortcut_general = "杖編集パネル、杖ボックス、呪文グループボックス",
        shortcut_multi_selectable = "杖編集パネル、杖ボックス",
        shortcut_select = "選択",
        shortcut_deselect = "選択解除",
        shortcut_multi_select = "複数選択",
        shortcut_expand_selection_left = "左へ選択範囲を拡張",
        shortcut_expand_selection_right = "右へ選択範囲を拡張",
        shortcut_swap = "入れ替え/循環",
        shortcut_override = "移動",
        shortcut_wand_edit_panel = "杖編集パネル",
        shortcut_duplicate = "呪文複製",
        shortcut_delete_action = "呪文削除",
        shortcut_delete_slot = "スロット削除",
        shortcut_always_cast = "常時詠唱を昇格/降格",
        shortcut_undo = "取り消し",
        shortcut_redo = "やり直し",
        shortcut_left_delete = "左を削除",
        shortcut_right_delete = "右を削除",
        shortcut_spell_picker = "呪文セレクター",
        shortcut_relock = "解禁済み呪文を再封印",
        shortcut_replace_switch_temp = "入れ替えモードを反転",
        shortcut_clear_action_history = "呪文履歴を消去",
        shortcut_wand_box = "杖ボックス",
        shortcut_show_wand_stats = "杖の能力値を表示",
        shortcut_confirm = "確認（削除など）",
        shortcut_transform_mortal_into_dummy = "ダミーへの変換",
        no_weather = "天候を無効化",
        no_weather_description = "すべての雨や雪を無効化するか",
        dummy_target_show_full_damage_number = "ダミーへのダメージ数値をすべて表示",
        dummy_target_show_full_damage_number_description = "常にダミーへのダメージ数値をすべて表示するか",
        button_click_sound = "ボタンのクリック音",
        action_button_click_sound = "呪文ボタンのクリック音",
    },
    ko = {
        wand_edit_panel = "완드 편집 패널",
        wand_edit_panel_max_num_rows = "최대 줄 수",
        wand_edit_panel_max_num_rows_description = "완드 편집 패널에 동시에 최대 몇 개의 줄을 표시할 지\n기본값: 5",
        wand_edit_panel_max_actions_per_row = "한 줄의 최대 슬롯 수 제한",
        wand_edit_panel_max_actions_per_row_description =
        "완드 편집 패널의 한 줄에 최대 몇 개의 슬롯을 포함할 지\n참고: 가상 해상도에 기반해 자동 계산됩니다\n0 = 추가 제한 없음",
        wand_edit_panel_history_limit = "최대 기록 수",
        wand_edit_panel_history_limit_description = "완드 편집 패널이 최근 작업을 몇 개까지 기억할 지\n기본값: 30",
        wand_listener_type = "완드 감지",
        wand_listener_type_description = "외부 옵션을 추적하기 위해 어떤 완드를 감지할 지\n값은 완드를 편집하는 방식에는 영향을 주지 않지만, 생성되는 기록 수를 바꿈",
        wand_listener_type_values_INV = "인벤토리의 모든 완드",
        wand_listener_type_values_HAND = "들고 있는 완드",
        wand_listener_type_values_PANEL = "들고 있는 완드(완드 편집 패널이 표시될 때만)",
        spell_picker = "주문 선택기",
        filter_buttons_trigger = "유형 간 전환",
        filter_buttons_trigger_description = "주문 유형 버튼을 어떻게 트리거할 지",
        filter_buttons_trigger_values_HOVER = "호버",
        filter_buttons_trigger_values_CLICK = "클릭",
        action_history_limit = "최근 사용 주문 제한",
        action_history_limit_description = "주문 선택기 메뉴가 최근 사용한 주문을 몇 개까지 기억할 지\n기본값: 96",
        show_icon_unlocked = "잠금 해제된 주문 표시",
        show_icon_unlocked_description = "잠금 해제된 주문을 오른쪽 위 모서리에 작은 아이콘으로 표시할 지 여부",
        include_spells_in_non_inv_wand = "근처 완드의 주문 포함",
        include_spells_in_non_inv_wand_description = "주문 선택기의 인벤&주변 페이지에 근처 완드의 주문을 표시할 지 여부",
        show_screen_keyboard = "주문 검색 페이지에 화면 키보드 표시",
        creative_mode_flight_speed = "슈퍼 비행 속도",
        creative_mode_flight_speed_normal = "보통",
        creative_mode_flight_speed_normal_description = "기본값: 200",
        creative_mode_flight_speed_faster = "더 빠름",
        creative_mode_flight_speed_faster_description = "기본값: 450",
        creative_mode_flight_speed_no_clip = "벽 뚫기",
        creative_mode_flight_speed_no_clip_description = "기본값: 300",
        all_seeing_eye = "천리안 효과",
        all_seeing_eye_lighting = "",
        all_seeing_eye_fog_of_war_removing = "전장의 안개 제거",
        shortcut = "단축키 설정",
        shortcut_strict = "엄격한 감지",
        shortcut_strict_description = "어떤 단축키에도 사용되지 않는 키를 단축키 감지에 포함할 지 여부",
        shortcut_click_to_save = "(저장하려면 클릭)",
        shortcut_click_here = "#NAME?",
        shortcut_general = "완드 편집 패널, 완드 박스 & 주문 그룹 박스",
        shortcut_multi_selectable = "완드 편집 패널 & 완드 박스",
        shortcut_select = "선택",
        shortcut_deselect = "선택 해제",
        shortcut_multi_select = "다중 선택",
        shortcut_expand_selection_left = "왼쪽으로 선택 영역 확장",
        shortcut_expand_selection_right = "오른쪽으로 선택 영역 확장",
        shortcut_swap = "교환/순환",
        shortcut_override = "이동",
        shortcut_wand_edit_panel = "완드 편집 패널",
        shortcut_duplicate = "주문 복제",
        shortcut_delete_action = "주문 삭제",
        shortcut_delete_slot = "슬롯 삭제",
        shortcut_always_cast = "항상 시전 승격/강등",
        shortcut_undo = "실행 취소",
        shortcut_redo = "다시 실행",
        shortcut_left_delete = "왼쪽 삭제",
        shortcut_right_delete = "오른쪽 삭제",
        shortcut_spell_picker = "주문 선택기",
        shortcut_relock = "잠금 해제된 주문 다시 잠그기",
        shortcut_replace_switch_temp = "교체 모드 반전",
        shortcut_clear_action_history = "주문 기록 지우기",
        shortcut_wand_box = "완드 박스",
        shortcut_show_wand_stats = "완드 능력치 표시",
        shortcut_confirm = "확인(삭제 등)",
        shortcut_transform_mortal_into_dummy = "더미 변환",
        no_weather = "날씨 비활성화",
        no_weather_description = "모든 종류의 비나 눈을 비활성화할 지 여부",
        dummy_target_show_full_damage_number = "더미의 대미지 모든 숫자 표시하기",
        dummy_target_show_full_damage_number_description = "더미에 항상 모든 숫자를 표시할 지 여부",
        button_click_sound = "버튼 클릭 소리",
        action_button_click_sound = "주문 버튼 클릭 소리",
    },
}

---@param id string
---@return fun(value_default: string): table
function cc.shortcut(id)
    return function(value_default)
        return {
            id = id,
            ui_fn = mod_setting_shortcut,
            extra = cc.extra,
        }
    end
end

mod_settings = {
    cc.cat "wand_edit_panel" {
        cc.input_int "wand_edit_panel.max_rows" (5, 3),
        cc.input_int "wand_edit_panel.max_actions_per_row" (0, 3),
        cc.input_int "wand_edit_panel.history_limit" (30, 3),
        cc.enum "wand_listener_type" { "INV", "HAND", "PANEL" },
    },
    cc.cat "spell_picker" {
        cc.enum "spell_picker.filter_buttons_trigger" { "HOVER", "CLICK" },
        cc.checkbox "show_icon_unlocked" (false),
        cc.input_int "spell_picker.action_history_limit" (96, 3),
        cc.checkbox "include_spells_in_non_inv_wand" (false),
        cc.checkbox "show_screen_keyboard" (false),
    },
    cc.cat "creative_mode_flight_speed" {
        cc.input_int "creative_mode_flight.speed_normal" (200, 6),
        cc.input_int "creative_mode_flight.speed_faster" (450, 6),
        cc.input_int "creative_mode_flight.speed_no_clip" (300, 6),
    },
    cc.cat "all_seeing_eye" {
        cc.slider "all_seeing_eye.brightening" (0, 0, 1, format_percent),
        cc.slider "all_seeing_eye.fog_of_war_removing" (1, 0, 1, format_percent),
    },
    cc.checkbox "no_weather.enabled" (false):extra { scope = MOD_SETTING_SCOPE_RUNTIME_RESTART },
    cc.checkbox "dummy_target_show_full_damage_number" (false),
    cc.checkbox "general.button_click_sound" (true),
    cc.checkbox "general.action_button_click_sound" (true),
    cc.enum "spellbox_pack" { "GOKIS", "VANILLA" },
}

local function load_mod_settings(cur_lang)
    local lang_id = "en"
    if cur_lang:find "中文" or cur_lang:find "汉化" then
        lang_id = "zh_cn"
    end
    cc.load_lang(mod_settings, lang_id)
end

load_mod_settings(GameTextGet "$current_language")

local mod_id = "spell_lab_shugged"

function ModSettingsUpdate(init_scope)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

local last_cur_lang
function ModSettingsGui(gui, in_main_menu)
    local cur_lang = GameTextGet "$current_language"
    if cur_lang ~= last_cur_lang then
        load_mod_settings(cur_lang)
        last_cur_lang = cur_lang
    end
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
