dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "data/scripts/lib/mod_settings.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/shortcut_setting.lua" )

local mod_id = "spell_lab_shugged"

mod_settings_version = 1
mod_settings = {
	{
		category_id = "wand_edit_panel",
		foldable = true,
		_folded = true,
		settings = {
			{
				id                 = "wand_edit_panel_max_rows",
				allowed_characters = "0123456789",
				text_max_length    = 3,
				value_default      = "5",
			},
			{
				id                 = "wand_edit_panel_max_actions_per_row",
				allowed_characters = "0123456789",
				text_max_length    = 3,
				value_default      = "0",
			},
			{
				id                 = "wand_edit_panel_history_limit",
				allowed_characters = "0123456789",
				text_max_length    = 3,
				value_default      = "30",
			},
			{
				id = "wand_listener_type",
			},
		},
	},
	{
		category_id = "spell_picker",
		foldable = true,
		_folded = true,
		settings = {
			{
				id = "filter_buttons_trigger",
			},
			{
				id            = "show_icon_unlocked",
				value_default = false,
			},
			{
				id                 = "action_history_limit",
				allowed_characters = "0123456789",
				text_max_length    = 3,
				value_default      = "96",
			},
			{
				id            = "include_spells_in_non_inv_wand",
				value_default = false,
			},
			{
				id            = "show_screen_keyboard",
				value_default = false,
			},
		},
	},
	{
		category_id = "creative_mode_flight_speed",
		foldable = true,
		_folded = true,
		settings = {
			{
				id                 = "creative_mode_flight_speed_normal",
				allowed_characters = "0123456789",
				text_max_length    = 6,
				value_default      = "200",
			},
			{
				id                 = "creative_mode_flight_speed_faster",
				allowed_characters = "0123456789",
				text_max_length    = 6,
				value_default      = "450",
			},
			{
				id                 = "creative_mode_flight_speed_no_clip",
				allowed_characters = "0123456789",
				text_max_length    = 6,
				value_default      = "300",
			},
		},
	},
	{
		category_id = "all_seeing_eye",
		foldable = true,
		_folded = true,
		settings = {
			{
				id                       = "all_seeing_eye_lighting",
				value_default            = 0,
				value_min                = 0,
				value_max                = 1,
				value_display_multiplier = 100,
				value_display_formatting = " $0%",
			},
			{
				id                       = "all_seeing_eye_fog_of_war_removing",
				value_default            = 1,
				value_min                = 0,
				value_max                = 1,
				value_display_multiplier = 100,
				value_display_formatting = " $0%",
			},
		},
	},
	{
		category_id = "shortcut",
		foldable = true,
		_folded = true,
		settings = {
			{
				id            = "shortcut_strict",
				value_default = false,
				change_fn     = function( mod_id, gui, in_main_menu, setting, old_value, new_value )
					ModSettingSetNextValue( mod_id .. ".shortcut_changed", true, false )
				end,
			},
			{
				category_id = "shortcut_general",
				foldable = true,
				_folded = true,
				settings = {
					{
						id            = "shortcut_select",
						value_default = '{"Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_deselect",
						value_default = '{"Mouse_right"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_swap",
						value_default = '{"Key_ALT","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
				}
			},
			{
				category_id = "shortcut_multi_selectable",
				foldable = true,
				_folded = true,
				settings = {
					{
						id            = "shortcut_multi_select",
						value_default = '{"Key_CTRL","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_expand_selection_left",
						value_default = '{"Key_CTRL","Key_ALT","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_expand_selection_right",
						value_default = '{"Key_CTRL","Key_ALT","Mouse_right"}',
						ui_fn         = mod_setting_shortcut,
					},
				},
			},
			{
				category_id = "shortcut_wand_edit_panel",
				foldable = true,
				_folded = true,
				settings = {
					{
						id            = "shortcut_override",
						value_default = '{"Key_ALT","Mouse_right"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_duplicate",
						value_default = '{"Key_ALT","Key_SHIFT","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_delete_action",
						value_default = '{"Key_SHIFT","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_delete_slot",
						value_default = '{"Key_SHIFT","Mouse_right"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_always_cast",
						value_default = '{"Key_CTRL","Key_SHIFT","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_left_delete",
						value_default = '{"Key_BACKSPACE"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_right_delete",
						value_default = '{"Key_DELETE"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_undo",
						value_default = '{"Key_CTRL","Key_z"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_redo",
						value_default = '{"Key_CTRL","Key_y"}',
						ui_fn         = mod_setting_shortcut,
					},
				},
			},
			{
				category_id = "shortcut_spell_picker",
				foldable = true,
				_folded = true,
				settings = {
					{
						id            = "shortcut_relock",
						value_default = '{"Key_CTRL","Key_SHIFT","Mouse_left"}',
						ui_fn         = mod_setting_shortcut,
					},
					{
						id            = "shortcut_replace_switch_temp",
						value_default = '{"Key_SHIFT"}',
						ui_fn         = mod_setting_shortcut,
						shortcut_type = Shortcut_Type.Sustained,
					},
					{
						id            = "shortcut_clear_action_history",
						value_default = '{"Key_SHIFT","Mouse_right"}',
						ui_fn         = mod_setting_shortcut,
					},
				},
			},
			{
				category_id = "shortcut_wand_box",
				foldable    = true,
				_folded     = true,
				settings    = {
					{
						id            = "shortcut_show_wand_stats",
						value_default = '{"Key_CTRL"}',
						ui_fn         = mod_setting_shortcut,
						shortcut_type = Shortcut_Type.Sustained,
					},
				},
			},
			{
				id            = "shortcut_confirm",
				value_default = '{"Key_SHIFT"}',
				ui_fn         = mod_setting_shortcut,
				shortcut_type = Shortcut_Type.Sustained,
			},
			{
				id            = "shortcut_transform_mortal_into_dummy",
				value_default = '{"Key_SHIFT"}',
				ui_fn         = mod_setting_shortcut,
			},
		},
	},
	{
		id            = "no_weather",
		value_default = false,
		scope         = MOD_SETTING_SCOPE_RUNTIME_RESTART,
	},
	{
		id            = "dummy_target_show_full_damage_number",
		value_default = false,
	},
	{
		id            = "button_click_sound",
		value_default = false,
	},
	{
		id            = "action_button_click_sound",
		value_default = false,
	},
}

local function load_mod_settings( cur_lang )
	local text
	if cur_lang == "简体中文" or cur_lang == "喵体中文" or cur_lang == "汪体中文" or cur_lang == "完全汉化" then
		text = {
			wand_edit_panel = "法杖编辑面板",
			wand_edit_panel_max_rows = "最大行数",
			wand_edit_panel_max_rows_description = "法杖编辑面板最多可以同时显示的行数，默认为 5",
			wand_edit_panel_max_actions_per_row = "单行格数限制",
			wand_edit_panel_max_actions_per_row_description =
				"限制法杖编辑面板单行最多可以显示的格数\n单行最多能容纳的格数自动由虚拟分辨率计算得出，然后应用此限制\n0 = 不进行限制",
			wand_edit_panel_history_limit = "历史记录最大条数",
			wand_edit_panel_history_limit_description = "法杖编辑面板保留最近操作的数量，默认为 30",
			wand_listener_type = "法杖监听",
			wand_listener_type_description = "法杖编辑面板应该从哪些法杖监听外部操作？\n该设置不影响编辑，但会影响历史记录的产生数量",
			wand_listener_type_values = {
				{ "INV", "背包中所有法杖" },
				{ "HAND", "手持法杖" },
				{ "PANEL", "手持法杖（仅法杖编辑面板显示时）" },
			},
			spell_picker = "法术选取菜单",
			filter_buttons_trigger = "法术类别切换方式",
			filter_buttons_trigger_description = "法术类别按钮应该如何触发？",
			filter_buttons_trigger_values = {
				{ "HOVER", "悬浮" },
				{ "CLICK", "点击" },
			},
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
			shortcut_delete_slot = "删除法术并将右侧法术左移",
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
			joystick_alternatives = "手柄类比鼠标",
			joystick_alternative_to_Mouse_left = "鼠标左键",
			joystick_alternative_to_Mouse_right = "鼠标右键",
			joystick_alternative_to_Mouse_middle = "鼠标中键",
			joystick_alternative_to_Mouse_x1 = "鼠标 4",
			joystick_alternative_to_Mouse_x2 = "鼠标 5",
			no_weather = "禁用天气",
			no_weather_description = "开启时，天气将锁定为晴朗状态",
			dummy_target_show_full_damage_number = "伤害测试假人显示完整伤害数字",
			dummy_target_show_full_damage_number_description = "开启时，将以完整形式而不是科学计数法显示伤害数字",
			button_click_sound = "按钮点击音效",
			action_button_click_sound = "法术按钮点击音效",
		}
	else
		text = {
			wand_edit_panel = "Wand Edit Panel",
			wand_edit_panel_max_rows = "Max Rows",
			wand_edit_panel_max_rows_description = "How many rows should the wand edit panel show at most at the same time?\n5 by default",
			wand_edit_panel_max_actions_per_row = "Max Slots In One Row Limit",
			wand_edit_panel_max_actions_per_row_description =
				"How many slots should one row of the wand edit panel contain at most?\nNote: That is calculated with your virtual resolution magic numbers\n0 = No extra limit to it",
			wand_edit_panel_history_limit = "Max Histories",
			wand_edit_panel_history_limit_description = "How many recent operations should the wand edit panel remember?\n30 by default",
			wand_listener_type = "Wand Listening",
			wand_listener_type_description = "From which wand(s) should be listened to track any external options?\nValue doesn't change the way you edit wand, but changes how many histories will be created",
			wand_listener_type_values = {
				{ "INV", "All Wands in Inventory" },
				{ "HAND", "Held Wand" },
				{ "PANEL", "Held Wand(Only when the wand edit panel is shown)" },
			},
			spell_picker = "Spell Picker",
			filter_buttons_trigger = "Switch between types",
			filter_buttons_trigger_description = "How to trigger the spell type buttons?",
			filter_buttons_trigger_values = {
				{ "HOVER", "Hover" },
				{ "CLICK", "Click" },
			},
			action_history_limit = "Recently Used Spells Limit",
			action_history_limit_description = "How many recently used spells should the spell picker menu remember?\n96 by default",
			show_icon_unlocked = "Mark Out Unlocked Spells",
			show_icon_unlocked_description = "Should we mark out unlocked spells with a small icon in the top right corner?",
			include_spells_in_non_inv_wand = "Include Spells In Nearby Wands",
			include_spells_in_non_inv_wand_description = "Should spells in nearby wands be shown in Inv/Nearby page of the spell picker?",
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
			shortcut_delete_slot = "Delete spell and shift following spells left",
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
			joystick_alternatives = "Joystick As Mouse",
			joystick_alternative_to_Mouse_left = "Mouse left",
			joystick_alternative_to_Mouse_right = "Mouse right",
			joystick_alternative_to_Mouse_middle = "Mouse middle",
			joystick_alternative_to_Mouse_x1 = "Mouse 4",
			joystick_alternative_to_Mouse_x2 = "Mouse 5",
			no_weather = "Disable Weather",
			no_weather_description = "Should we disable all kinds of rain or snow?",
			dummy_target_show_full_damage_number = "Show Full Damage Number For Dummy Targets",
			dummy_target_show_full_damage_number_description = "Should dummy targets always has full-length damage numbers shown?",
			button_click_sound = "Button Click Sound",
			action_button_click_sound = "Spell Button Click sound",
		}
	end
	local function recursive( setting )
		if setting.id ~= nil then
			setting.ui_name = text[ setting.id ]
			setting.ui_description = text[ setting.id .. "_description" ]
			if text[ setting.id .. "_values" ] ~= nil then
				setting.values = text[ setting.id .. "_values" ]
				setting.value_default = setting.values[1][1]
			end
			setting.scope = setting.scope or MOD_SETTING_SCOPE_RUNTIME
		elseif setting.category_id ~= nil then
			setting.ui_name = text[ setting.category_id ]
			setting.ui_description = text[ setting.category_id .. "_description" ]
			for _, s in ipairs( setting.settings ) do
				recursive( s )
			end
		end
	end
	for _, s in ipairs( mod_settings ) do
		recursive( s )
	end
end

load_mod_settings()

function ModSettingsUpdate( init_scope )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

local last_cur_lang
function ModSettingsGui( gui, in_main_menu )
	local cur_lang = GameTextGet( "$current_language" )
	if cur_lang ~= last_cur_lang then
		load_mod_settings( cur_lang )
		last_cur_lang = cur_lang
	end
    mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end