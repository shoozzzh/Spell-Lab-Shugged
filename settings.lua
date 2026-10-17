dofile_once "data/scripts/lib/utilities.lua"
dofile_once "data/scripts/lib/mod_settings.lua"

-- mod_settings_version = 1
---@diagnostic disable-next-line: lowercase-global
mod_settings_version = 2

do -- migrate from old version if needed
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
            ["dummy_target_show_full_damage_number"] = "target_dummy.always_show_full_damage_number",
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
            ["show_icon_unlocked"] = "spell_picker.show_icon_unlocked",
            ["show_locked_spells"] = "spell_picker.show_locked_spells",
            ["show_screen_keyboard"] = "",
            ["toggle_options"] = "toggle_options.showing",
            ["show_wand_edit_panel"] = "wand_edit_panel.showing",
            ["special_filter_button_align_to"] = "",
            ["unlimited_spells"] = "unlimited_spells.enabled",
            ["wand_box_page_max_index"] = "wand_box.last_page_index",
            ["wand_edit_panel_history_limit"] = "wand_edit_panel.history_limit",
            ["wand_edit_panel_max_actions_per_row"] = "wand_edit_panel.max_actions_per_row",
            ["wand_edit_panel_max_rows"] = "wand_edit_panel.max_rows",
            ["wand_force_compact"] = "",
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

local lang = { -- you may wanna fold these
    ["creative_mode_flight.speed"] = {
        zh_cn = "超级飞行速度",
        en = "Superflight Speed",
        jp = "スーパー飛行速度",
        ko = "슈퍼 비행 속도",
    },
    ["creative_mode_flight.speed_normal"] = {
        zh_cn = "正常",
        en = "Normal",
        jp = "通常",
        ko = "보통",
    },
    ["creative_mode_flight.speed_normal.desc"] = {
        zh_cn = "默认：200",
        en = "200 by default",
        jp = "デフォルト：200",
        ko = "기본값: 200",
    },
    ["creative_mode_flight.speed_faster"] = {
        zh_cn = "加速",
        en = "Faster",
        jp = "高速",
        ko = "더 빠름",
    },
    ["creative_mode_flight.speed_faster.desc"] = {
        zh_cn = "默认：450",
        en = "450 by default",
        jp = "デフォルト：450",
        ko = "기본값: 450",
    },
    ["creative_mode_flight.speed_no_clip"] = {
        zh_cn = "穿墙",
        en = "No Clip",
        jp = "壁抜け",
        ko = "벽 뚫기",
    },
    ["creative_mode_flight.speed_no_clip.desc"] = {
        zh_cn = "默认：300",
        en = "300 by default",
        jp = "デフォルト：300",
        ko = "기본값: 300",
    },
    ["all_seeing_eye"] = {
        zh_cn = "全视之眼效果",
        en = "Effect of All-seeing Eye",
        jp = "お見通しの効果",
        ko = "천리안 효과",
    },
    ["all_seeing_eye.brightening"] = {
        zh_cn = "照明",
        en = "Lighting",
        jp = "照明",
        ko = "조명",
    },
    ["all_seeing_eye.fog_of_war_removing"] = {
        zh_cn = "移除战争迷雾",
        en = "Fog of War Removing",
        jp = "戦場の霧の除去",
        ko = "전장의 안개 제거",
    },
    ["shortcut"] = {
        zh_cn = "快捷键设置",
        en = "Shortcuts Setting",
        jp = "ショートカット設定",
        ko = "단축키 설정",
    },
    ["shortcut.strict"] = {
        zh_cn = "严格检测",
        en = "Strict Detection",
        jp = "厳密検出",
        ko = "엄격한 감지",
    },
    ["shortcut.strict.desc"] = {
        zh_cn = "没有包含在任何快捷键中的键是否应该影响快捷键检测？",
        en = "Should keys that not used in any shortcut be considered in shortcut detection?",
        jp = "どのショートカットにも使われていないキーを、ショートカット検出に含めるか",
        ko = "어떤 단축키에도 사용되지 않는 키를 단축키 감지에 포함할 지 여부",
    },
    ["shortcut.click_to_save"] = {
        zh_cn = "（点击以保存）",
        en = "(click to save)",
        jp = "（クリックで保存）",
        ko = "(저장하려면 클릭)",
    },
    ["shortcut.click_here"] = {
        zh_cn = "+（请点击）",
        en = "+ (click here)",
        jp = "+（ここをクリック）",
        ko = "+ (여기를 클릭)",
    },
    ["shortcut.transform_mortal_into_dummy"] = {
        zh_cn = "转化生物为靶标假人",
        en = "Target dummy transformation",
        jp = "ダミーへの変換",
        ko = "더미 변환",
    },
    ["no_weather"] = {
        zh_cn = "禁用天气",
        en = "Disable Weather",
        jp = "天候を無効化",
        ko = "날씨 비활성화",
    },
    ["no_weather.desc"] = {
        zh_cn = "开启时，天气将锁定为晴朗状态",
        en = "Should we disable all kinds of rain or snow?",
        jp = "すべての雨や雪を無効化するか",
        ko = "모든 종류의 비나 눈을 비활성화할 지 여부",
    },
    ["dummy_target.always_show_full_damage_number"] = {
        zh_cn = "靶标假人总是显示完整伤害数字",
        en = "Show Full Damage Number For Dummy Targets",
        jp = "ダミーへのダメージ数値をすべて表示",
        ko = "더미의 대미지 모든 숫자 표시하기",
    },
    ["dummy_target.always_show_full_damage_number.desc"] = {
        zh_cn = "开启时，将总是以完整形式显示伤害数字，不会在过大时使用科学计数法",
        en = "Should dummy targets always has full-length damage numbers shown, no matter how big the number is?",
        jp = "常にダミーへのダメージ数値をすべて表示するか",
        ko = "더미에 항상 모든 숫자를 표시할 지 여부",
    },
    ["general.button_click_sound"] = {
        zh_cn = "按钮点击音效",
        en = "Button Click Sound",
        jp = "ボタンのクリック音",
        ko = "버튼 클릭 소리",
    },
    ["general.action_button_click_sound"] = {
        zh_cn = "法术按钮点击音效",
        en = "Spell Button Click Sound",
        jp = "呪文ボタンのクリック音",
        ko = "주문 버튼 클릭 소리",
    },
    ["general.spellbox_pack"] = {
        zh_cn = "法术框贴图",
        en = "Spell Box Sprites",
        jp = "",
        ko = "",
    },
    ["general.spellbox_pack.values.GOKIS"] = {
        zh_cn = "Goki 经典方案",
        en = "Goki's Classics",
        jp = "",
        ko = "",
    },
    ["general.spellbox_pack.values.VANILLA"] = {
        zh_cn = "Noita 原版方案",
        en = "Noita Vanilla",
        jp = "",
        ko = "",
    },
}
local function get_text(key)
    return lang[key] or (key .. " (missing text)")
end

local cc = (function() -- clikclak.lua, you may wanna fold these
    local clikclak = {}

    function clikclak.load_lang(settings, lang)
        local function get_text(key)
            return lang[key] or (key .. " (missing text)")
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

    ---@generic T
    ---@param self T
    ---@param extra_fields {[string]: any}
    ---@return T self
    local function extra(self, extra_fields)
        for k, v in pairs(extra_fields) do
            self[k] = v
        end
        return self
    end
    clikclak.extra = extra -- for user extensions

    ---@param id string
    function clikclak.enum(id)
        ---@param values string[]
        ---@param value_default string?
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
    function clikclak.checkbox(id)
        ---@param value_default boolean
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
    function clikclak.slider(id)
        ---@param value_default number
        ---@param value_min number
        ---@param value_max number
        ---@param value_formatter fun(value: number): string
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
    function clikclak.input_int(id)
        ---@param value_default integer|string
        ---@param max_length integer
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

    ---@param settings table
    ---@param prefix string
    local function add_prefix_rec(settings, prefix)
        if settings == nil then return end
        for _, entry in ipairs(settings) do
            entry.id = prefix .. "." .. entry.id
            add_prefix_rec(entry.settings, prefix)
        end
    end

    ---@param id string
    function clikclak.cat(id)
        ---@param settings table[]
        return function(settings)
            add_prefix_rec(settings, id)
            return {
                category_id = id,
                settings = settings,
                foldable = true,
                _folded = true,
                extra = extra,
            }
        end
    end

    ---@param id string
    function clikclak.fold(id)
        ---@param settings table[]
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

local mod_setting_shortcut = (function() -- you may wanna fold these
    ---@param shortcut shortcut
    ---@return string
    local function ser(shortcut)
        local result = { '{"' }
        for i = 1, #shortcut do
            result[i + 1] = shortcut[i]
        end
        result[#result + 1] = '"}'
        return table.concat(result, '","')
    end

    ---@param shortcut string
    ---@return shortcut
    local function deser(shortcut)
        ModTextFileSetContent("mods/shortcut_set.lua", "return " .. shortcut)
        return loadfile "mods/shortcut_set.lua" ()
    end

    local shortcut_tostring = (function() -- files/shortcuts/to_string.lua
        local special_chars = {
            MINUS = "-",
            EQUALS = "=",
            LEFTBRACKET = "[",
            RIGHTBRACKET = "]",
            BACKSLASH = "\\",
            NONUSHASH = "#",
            SEMICOLON = ";",
            APOSTROPHE = "'",
            GRAVE = "`",
            COMMA = ",",
            PERIOD = ".",
            SLASH = "/",
            NUMLOCKCLEAR = "NUMLOCK",
            KP_DIVIDE = "/",
            KP_MULTIPLY = "*",
            KP_MINUS = "-",
            KP_PLUS = "+",
            KP_PERIOD = ".",
            NONUSBACKSLASH = "\\",
            APPLICATION = "MENU",
            POWER = "SHUTDOWN",
            KP_EQUALS = "=",
            KP_COMMA = ",",
            KP_EQUALSAS400 = "=",
            KP_LEFTPAREN = "(",
            KP_RIGHTPAREN = ")",
            KP_LEFTBRACE = "{",
            KP_RIGHTBRACE = "}",
            KP_XOR = "^",
            KP_POWER = "SHUTDOWN",
            KP_PERCENT = "%",
            KP_LESS = "<",
            KP_GREATER = ">",
            KP_AMPERSAND = "&",
            KP_DBLAMPERSAND = "&&",
            KP_VERTICALBAR = "|",
            KP_DBLVERTICALBAR = "||",
            KP_COLON = ":",
            KP_HASH = "#",
            KP_AT = "@",
            KP_EXCLAM = "!",
            KP_PLUSMINUS = "+-",
            LGUI = "LEFT WINDOWS",
            RGUI = "RIGHT WINDOWS",
        }

        local named_keys = {
            Key_CTRL = "Ctrl",
            Key_SHIFT = "Shift",
            Key_ALT = "Alt",
            JOY_BUTTON_0 = "$input_xboxbutton_a",
            JOY_BUTTON_1 = "$input_xboxbutton_b",
            JOY_BUTTON_2 = "$input_xboxbutton_x",
            JOY_BUTTON_3 = "$input_xboxbutton_y",
            Mouse_x1 = "$input_mousebutton4",
            Mouse_x2 = "$input_mousebutton5",
        }

        local custom_keys_i18n = {
            ["简体中文"] = {
                Mouse_left = "左键",
                Mouse_right = "右键",
            },
            ["한국어"] = {
                Mouse_left = "왼쪽 클릭",
                Mouse_right = "오른쪽 클릭",
            },
            ["日本語"] = {
                Mouse_left = "左クリック",
                Mouse_right = "右クリック",
            },
            DEFAULT = {
                Mouse_left = "Left-click",
                Mouse_right = "Right-click",
            },
        }

        do
            local other_zh_cn_languages = { "喵体中文", "汪体中文", "完全汉化" }
            for _, v in ipairs(other_zh_cn_languages) do
                custom_keys_i18n[v] = custom_keys_i18n["简体中文"]
            end
        end

        local function keyname_to_text(keyname, lang)
            local result = named_keys[keyname]
            if result then return GameTextGetTranslatedOrNot(result) end

            local i18n = custom_keys_i18n[lang] or custom_keys_i18n.DEFAULT
            result = i18n[keyname]
            if result then return result end

            if keyname:find "^Mouse_" then
                return GameTextGet("$input_" .. keyname:gsub("_", ""):lower()):upper()
            elseif keyname:find "^Key_" then
                local name = keyname:sub(5):upper()

                result = special_chars[name]
                if result then return result end

                local did = 0
                result, did = name:gsub("^KP_", "KEYPAD ")
                if did > 0 then return result end
                result, did = name:gsub("^AC_", "AC ")
                if did > 0 then return result end

                return name
            elseif keyname:find "^JOY_BUTTON_" then
                local result = GameTextGet("$input_xboxbutton_" .. keyname:sub(12):lower())
                if keyname:find "%d%d_DOWN$" then
                    result = result .. " DOWN"
                elseif keyname:find "%d%d_MOVED$" then
                    result = result .. " MOVED"
                else
                    result = ("(%s)"):format(result) -- to ensure they look different from keyboard keys e.g. (A) not A
                end

                return result
            end
            return GameTextGet "$menuoptions_configurecontrols_keyname_unknown"
        end

        local order = {
            Key_CTRL = -100,
            Key_ALT = -99,
            Key_SHIFT = -98,
            DEFAULT = 0,
            Mouse_left = 99,
            Mouse_right = 100,
        }
        local function shortcut_sort(shortcut)
            table.sort(shortcut, function(a, b)
                local order_a = order[a] or order.DEFAULT
                local order_b = order[b] or order.DEFAULT
                if order_a ~= order_b then return order_a < order_b end

                local len_a = #a
                local len_b = #b
                if len_a ~= len_b then return len_a > len_b end

                return a < b
            end)
        end

        ---@param shortcut string[]
        ---@param lang string
        ---@return string
        return function(shortcut, lang)
            local copy = {}
            for k, v in pairs(shortcut) do
                copy[k] = v
            end
            local trigger_key = copy[#copy]
            copy[#copy] = nil

            shortcut_sort(copy)

            copy[#copy + 1] = trigger_key

            local strs_to_concat = {}
            for _, key in ipairs(copy) do
                strs_to_concat[#strs_to_concat + 1] = keyname_to_text(key, lang)
            end
            return table.concat(strs_to_concat, " + ")
        end
    end)()
    local keystroke_listener = (function() -- keystroke_listener.lua
        local function get_keycodes()
            local f = loadfile "data/scripts/debug/keycodes.lua"
            local raw = {}
            setfenv(f, raw)()

            local by_type = { Mouse = {}, Keyboard = {}, Joystick = {} }
            for k, v in pairs(raw) do
                if k:find "^Mouse_" then
                    by_type.Mouse[k] = v
                elseif k:find "^Key_" then
                    by_type.Keyboard[k] = v
                elseif k:find "^JOY_BUTTON_" then
                    by_type.Joystick[k] = v
                end
            end

            local excluded_keys = { "JOY_BUTTON_0", "JOY_BUTTON_1", "JOY_BUTTON_2", "JOY_BUTTON_3" }

            for _, t in ipairs { raw, by_type.Mouse, by_type.Keyboard, by_type.Joystick } do
                for _, key in ipairs(excluded_keys) do
                    t[key] = nil
                end
            end

            return { raw, by_type }
        end

        local keycodes_by_type = get_keycodes()[2]

        ---@class inlined_keystroke_listener
        local keystroke_listener = {}

        local listeners = {}

        for k, v in pairs(keycodes_by_type.Keyboard) do
            listeners[k] = {
                function() return InputIsKeyDown(v) end,
                function() return InputIsKeyJustDown(v) end,
            }
        end

        for k, v in pairs(keycodes_by_type.Mouse) do
            listeners[k] = {
                function() return InputIsMouseButtonDown(v) end,
                function() return InputIsMouseButtonJustDown(v) end,
            }
        end

        do
            local combined_keys = {
                Key_ALT = { "Key_LALT", "Key_RALT" },
                Key_CTRL = { "Key_LCTRL", "Key_RCTRL" },
                Key_SHIFT = { "Key_LSHIFT", "Key_RSHIFT" },
            }

            local any_of = function(functions)
                return function()
                    for _, f in ipairs(functions) do
                        if f() then return true end
                    end
                end
            end

            for combined, from_these_keys in pairs(combined_keys) do
                local down_listeners, just_down_listeners = {}, {}

                for _, key in ipairs(from_these_keys) do
                    local down_listener, just_down_listener = unpack(listeners[key])
                    down_listeners[#down_listeners + 1] = down_listener
                    just_down_listeners[#just_down_listeners + 1] = just_down_listener

                    listeners[key] = nil
                end

                listeners[combined] = { any_of(down_listeners), any_of(just_down_listeners) }
            end
        end

        local joysticks_connected = {}

        local ignored_joystick_keys = {
            JOY_BUTTON_A = true,
            JOY_BUTTON_B = true,
            JOY_BUTTON_LEFT_STICK_LEFT = true,
            JOY_BUTTON_LEFT_STICK_RIGHT = true,
            JOY_BUTTON_LEFT_STICK_UP = true,
            JOY_BUTTON_LEFT_STICK_DOWN = true,
        }

        for name, code in pairs(keycodes_by_type.Joystick) do
            if ignored_joystick_keys[name] then
                goto continue
            end

            local down_listener = function()
                for index = 0, 7 do
                    if joysticks_connected[index] and InputIsJoystickButtonDown(index, code) then
                        return true
                    end
                end
                return false
            end

            listeners[name] = { down_listener, nil }

            ::continue::
        end

        do
            local listened_keys = {}

            for key, _ in pairs(listeners) do
                listened_keys[#listened_keys + 1] = key
            end

            for key, _ in ipairs(keycodes_by_type.Joystick) do
                listened_keys[#listened_keys + 1] = key
            end

            keystroke_listener.listened_keys = listened_keys
        end

        local frames_keys_held = {}
        for key, _ in pairs(listeners) do
            frames_keys_held[key] = 0
        end

        keystroke_listener.just_down = {}
        keystroke_listener.down = {}

        function keystroke_listener:update()
            local just_down = self.just_down
            local down = self.down

            for i = 0, 7 do
                joysticks_connected[i] = InputIsJoystickConnected(i)
            end

            for name, pair in pairs(listeners) do
                local down_listener, just_down_listener = unpack(pair)

                local current_frames_held = frames_keys_held[name]

                local down_now = down_listener()

                if just_down_listener then
                    just_down[name] = just_down_listener()
                else
                    just_down[name] = not down[name] and down_now
                end

                if current_frames_held > 30 then
                    just_down[name] = true
                end

                down[name] = down_now

                if down[name] then
                    frames_keys_held[name] = current_frames_held + 1
                else
                    frames_keys_held[name] = 0
                end
            end
        end

        return keystroke_listener
    end)()

    local warning_text = {
        ["简体中文"] = "编辑快捷键前请先进入游戏",
        DEFAULT = "Please enter a run before editing shortcuts",
    }
    do
        local other_zh_cn_languages = { "喵体中文", "汪体中文", "完全汉化" }
        for _, v in ipairs(other_zh_cn_languages) do
            warning_text[v] = warning_text["简体中文"]
        end
    end

    local current_key_detector
    return function(mod_id, gui, in_main_menu, im_id, setting)
        GuiLayoutBeginHorizontal(gui, 0, 0, true, 2, 2)
        GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)

        if not EntityGetIsAlive(1) then
            local text = warning_text[GameTextGet "$current_language"] or warning_text.DEFAULT
            GuiText(gui, mod_setting_group_x_offset - GuiGetTextDimensions(gui, setting.ui_name) + 120, 0, text)
            GuiLayoutEnd(gui)
            return
        end

        local changed = false
        if current_key_detector == setting.id then
            keystroke_listener:update()
            local shortcut = {}
            for k, v in pairs(keystroke_listener.down) do
                if v then
                    shortcut[#shortcut + 1] = k
                end
            end

            local str
            if #shortcut > 0 then
                str = shortcut_tostring(shortcut, GameTextGet "$current_language")
                str = str ..
                    (setting.click_required and get_text "shortcut.click_here" or get_text "shortcut.click_to_save")
            else
                str = "$menuoptions_configurecontrols_pressakey"
            end

            GuiColorSetForNextWidget(gui, 1, 1, 0.5, 1)
            local left_click, right_click =
                GuiButton(gui, im_id, mod_setting_group_x_offset - GuiGetTextDimensions(gui, setting.ui_name) + 120, 0,
                    str)

            if left_click or right_click then
                current_key_detector = nil
                if setting.click_required then
                    local click_given = false
                    if left_click then
                        shortcut[#shortcut + 1] = "Mouse_left"
                        click_given = true
                    end
                    if right_click then
                        shortcut[#shortcut + 1] = "Mouse_right"
                        click_given = true
                    end
                    if click_given then
                        ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), ser(shortcut), false)
                        changed = true
                    end
                else
                    ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), ser(shortcut), false)
                    changed = true
                end
            end
        else
            local str
            do
                local value = ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))
                if type(value) ~= "string" then
                    value = setting.value_default or "{}"
                end

                local shortcut
                do
                    local status, _ = pcall(function()
                        shortcut = deser(value)
                    end)
                    if not status then
                        shortcut = {}
                    end
                end

                if #shortcut == 0 then
                    str = "$menuoptions_configurecontrols_action_unbound"
                else
                    str = shortcut_tostring(shortcut, GameTextGet "$current_language")
                end
            end

            local left_click, right_click =
                GuiButton(gui, im_id, mod_setting_group_x_offset - GuiGetTextDimensions(gui, setting.ui_name) + 120, 0,
                    str)

            if left_click and not right_click then
                current_key_detector = setting.id
                ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), "{}", false)
                changed = true
            elseif not left_click and right_click then
                ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), "{}", false)
                changed = true
            end
        end

        if changed then ModSettingSet(mod_id .. ".shortcut_changed", true) end

        mod_setting_tooltip(mod_id, gui, in_main_menu, setting)

        GuiLayoutEnd(gui)
    end
end)()

local function format_percent(value)
    return (" %.0f%%"):format(value * 100)
end

---@param id string
---@return fun(value_default: string[]): table
function cc.shortcut(id)
    return function(value_default)
        local click_required = false
        for _, key_name in value_default do
            if key_name == "Mouse_left" or key_name == "Mouse_right" then
                click_required = true
            end
        end
        return {
            id = id,
            ui_fn = mod_setting_shortcut,
            click_required = click_required,
            extra = cc.extra,
        }
    end
end

local mod_settings = {
    -- cc.cat "wand_edit_panel" {
    --     cc.input_int "max_rows" (5, 3),
    --     cc.input_int "max_actions_per_row" (0, 3),
    --     cc.input_int "history_limit" (30, 3),
    --     cc.enum "wand_listener_type" { "INV", "HAND", "PANEL" },
    -- },
    -- cc.cat "spell_picker" {
    --     cc.enum "filter_buttons_trigger" { "HOVER", "CLICK" },
    --     cc.checkbox "show_icon_unlocked" (false),
    --     cc.input_int "action_history_limit" (96, 3),
    --     cc.checkbox "include_spells_in_non_inv_wand" (false),
    --     cc.checkbox "show_screen_keyboard" (false),
    -- },
    cc.cat "creative_mode_flight" {
        cc.input_int "speed_normal" (200, 6),
        cc.input_int "speed_faster" (450, 6),
        cc.input_int "speed_no_clip" (300, 6),
    },
    cc.cat "all_seeing_eye" {
        cc.slider "brightening" (0, 0, 1, format_percent),
        cc.slider "fog_of_war_removing" (1, 0, 1, format_percent),
    },
    cc.cat "shortcut" {
        cc.checkbox "strict" (false),
        cc.shortcut "modifier_key_1" { "Key_CTRL" },
        cc.shortcut "modifier_key_2" { "Key_SHIFT" },
        cc.shortcut "modifier_key_3" { "Key_ALT" },
        cc.shortcut "dummy_transform" { "Key_SHIFT" },
    },
    cc.checkbox "target_dummy.always_show_full_damage_number" (false),
    cc.checkbox "no_weather.enabled" (false):extra { scope = MOD_SETTING_SCOPE_RUNTIME_RESTART },
    cc.checkbox "general.button_click_sound" (true),
    cc.checkbox "general.action_button_click_sound" (true),
    cc.enum "spellbox_pack" { "GOKIS", "VANILLA" },
}

local lang_id_map = {
    ["한국어"] = "ko",
    ["日本語"] = "jp",
    ["русский"] = "ru",
    ["Português (Brasil)"] = "pt_br",
    ["Español"] = "es-es",
    ["Deutsch"] = "de",
    ["Français"] = "fr-fr",
    ["Italiano"] = "it",
    ["Polska"] = "pl",
}
local function load_mod_settings(cur_lang)
    local lang_id = "en"
    if cur_lang:find "中文" or cur_lang:find "汉化" then
        lang_id = "zh_cn"
    else
        lang_id = lang_id_map[lang_id] or lang_id
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
