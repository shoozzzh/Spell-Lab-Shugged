dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "data/scripts/lib/mod_settings.lua" )

local mod_id = "spell_lab_shugged"

mod_settings_version = 1
local function load_mod_settings()
	local cur_lang = GameTextGetTranslatedOrNot( "$current_language" )
	local text
	if cur_lang == "简体中文" then
		text = {
			wand_edit_panel_max_num_rows = "法杖编辑面板最大行数",
			wand_edit_panel_max_num_rows_description = "法杖编辑面板最多可以同时显示的行数，默认为 5",
			wand_edit_panel_max_actions_per_row = "法杖编辑面板单行格数限制",
			wand_edit_panel_max_actions_per_row_description =
				"限制法杖编辑面板单行最多可以显示的格数\n单行最多能容纳的格数自动由虚拟分辨率计算得出，然后应用此限制\n0 = 不进行限制",
			wand_edit_panel_history_limit = "法杖编辑面板历史记录最大条数",
			wand_edit_panel_history_limit_description = "法杖编辑面板保留最近操作的数量，默认为 30",
			action_history_limit = "法术使用记录最大条数",
			action_history_limit_description = "法术选取菜单保留的法术使用记录条数，默认为 96",
			no_weather = "禁用天气",
			no_weather_description = "开启时，天气将锁定为晴朗状态",
			show_icon_unlocked = "标记已解锁法术",
			show_icon_unlocked_description = "开启时，将在已解锁法术右上角显示图标，以便重新锁定它们",
			dummy_target_show_full_damage_number = "伤害测试假人显示完整伤害数字",
			dummy_target_show_full_damage_number_description = "开启时，将以完整形式而不是科学计数法显示伤害数字",
			wand_listener_type = "法杖监听",
			wand_listener_type_description = "法杖编辑面板应该从哪些法杖监听外部操作？\n该设置不影响编辑，但会影响历史记录的产生数量",
			wand_listener_type_values = {
				{ "INV", "背包中所有法杖" },
				{ "HAND", "手持法杖" },
				{ "PANEL", "手持法杖（仅法杖编辑面板显示时）" },
			},
			button_click_sound = "按钮点击音效",
			action_button_click_sound = "法术按钮点击音效",
		}
	else
		text = {
			wand_edit_panel_max_num_rows = "Wand Edit Panel Max Rows",
			wand_edit_panel_max_num_rows_description = "How many rows should the wand edit panel show at most at the same time?\n5 by default",
			wand_edit_panel_max_actions_per_row = "Wand Edit Panel Max Slots In One Row Limit",
			wand_edit_panel_max_actions_per_row_description =
				"How many slots should one row of the wand edit panel contain at most?\nNote: That is calculated with your virtual resolution magic numbers\n0 = No extra limit to it",
			wand_edit_panel_history_limit = "Wand Edit Panel Max Histories",
			wand_edit_panel_history_limit_description = "How many recent operations should the wand edit panel remember?\n30 by default",
			action_history_limit = "Recently Used Spells Limit",
			action_history_limit_description = "How many recently used spells should the spell picker menu remember?\n96 by default",
			no_weather = "Disable Weather",
			no_weather_description = "Should we disable all kinds of rain or snow?",
			show_icon_unlocked = "Mark Out Unlocked Spells",
			show_icon_unlocked_description = "Should we mark out unlocked spells with a small icon in the top right corner?",
			dummy_target_show_full_damage_number = "Show Full Damage Number in dummy target",
			dummy_target_show_full_damage_number_description = "Should dummy targets always has full-length damage numbers shown?",
			wand_listener_type = "Wand Listening",
			wand_listener_type_description = "From which wand(s) should be listened to track any external options?\nValue doesn't change the way you edit wand, but changes how many histories will be created",
			wand_listener_type_values = {
				{ "INV", "All Wands in Inventory" },
				{ "HAND", "Held Wand" },
				{ "PANEL", "Held Wand(Only when the wand edit panel is shown)" },
			},
			button_click_sound = "Button Click Sound",
			action_button_click_sound = "Spell Button Click sound",
		}
	end
	mod_settings = {
		{
			id                 = "wand_edit_panel_max_rows",
			ui_name            = text.wand_edit_panel_max_num_rows,
			ui_description     = text.wand_edit_panel_max_num_rows_description,
			allowed_characters = "0123456789",
			text_max_length    = 3,
			value_default      = "5",
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "wand_edit_panel_max_actions_per_row",
			ui_name            = text.wand_edit_panel_max_actions_per_row,
			ui_description     = text.wand_edit_panel_max_actions_per_row_description,
			allowed_characters = "0123456789",
			text_max_length    = 3,
			value_default      = "0",
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "wand_edit_panel_history_limit",
			ui_name            = text.wand_edit_panel_history_limit,
			ui_description     = text.wand_edit_panel_history_limit_description,
			allowed_characters = "0123456789",
			text_max_length    = 3,
			value_default      = "30",
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "action_history_limit",
			ui_name            = text.action_history_limit,
			ui_description     = text.action_history_limit_description,
			allowed_characters = "0123456789",
			text_max_length    = 3,
			value_default      = "96",
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "no_weather",
			ui_name            = text.no_weather,
			ui_description     = text.no_weather_description,
			value_default      = false,
			scope              = MOD_SETTING_SCOPE_RUNTIME_RESTART,
		},
		{
			id                 = "show_icon_unlocked",
			ui_name            = text.show_icon_unlocked,
			ui_description     = text.show_icon_unlocked_description,
			value_default      = false,
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "dummy_target_show_full_damage_number",
			ui_name            = text.dummy_target_show_full_damage_number,
			ui_description     = text.dummy_target_show_full_damage_number_description,
			value_default      = false,
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "wand_listener_type",
			ui_name            = text.wand_listener_type,
			ui_description     = text.wand_listener_type_description,
			value_default      = text.wand_listener_type_values[1][1],
			values             = text.wand_listener_type_values,
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "button_click_sound",
			ui_name            = text.button_click_sound,
			value_default      = false,
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
		{
			id                 = "action_button_click_sound",
			ui_name            = text.action_button_click_sound,
			value_default      = false,
			scope              = MOD_SETTING_SCOPE_RUNTIME,
		},
	}
end
load_mod_settings()

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	load_mod_settings()
    mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end