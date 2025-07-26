local smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/shortcut_tostring.lua" )
local keystroke_listener = dofile_once( "mods/spell_lab_shugged/files/gui/keystroke_listener.lua" )

local shortcut_text = {
	["简体中文"] = {
		done = "[完成]",
		clear = "[清空]",
		cancel = "[取消]",
	},
	DEFAULT = {
		done = "[Done]",
		clear = "[Clear]",
		cancel = "[Cancel]",
	},
}
for _, lang in ipairs( { "喵体中文", "汪体中文", "完全汉化" } ) do
	shortcut_text[ lang ] = shortcut_text["简体中文"]
end

Shortcut_Type = {
	OneShot = 0,
	Sustained = 1,
}

local current_key_detector = nil
local shortcut_inputed = nil

local function input_key_to_shortcut( key )
	local new = true
	for _, key_inputed in ipairs( shortcut_inputed ) do
		if key == key_inputed then
			new = false
			break
		end
	end

	if new then
		shortcut_inputed[ #shortcut_inputed + 1 ] = key
	end
end

function mod_setting_shortcut( mod_id, gui, in_main_menu, im_id, setting )
	GuiLayoutBeginHorizontal( gui, 0, 0, true, 2, 2 )
	GuiButton( gui, 4 * im_id, mod_setting_group_x_offset, 0, setting.ui_name )
	local ui_name_width = GuiGetTextDimensions( gui, setting.ui_name )
	local _,_,_,x,y = GuiGetPreviousWidgetInfo( gui )
	local cur_lang = GameTextGet( "$current_language" )

	GuiIdPushString( gui, "spell_lab_shugged.shortcut_setting.extra_button" )

	local changed = false
	if current_key_detector == setting.id then
		keystroke_listener:update()

		for key, status in pairs( keystroke_listener.just_down ) do
			if status then
				input_key_to_shortcut( key )
			end
		end

		local str
		if #shortcut_inputed > 0 then
			str = shortcut_tostring( shortcut_inputed, cur_lang )
		else
			str = "$menuoptions_configurecontrols_pressakey"
		end

		GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
		GuiColorSetForNextWidget( gui, 1, 1, 0.5, 1 )
		local left_click, right_click = GuiButton( gui, im_id, x + 120, y, str )

		if setting.shortcut_type ~= Shortcut_Type.Sustained then
			if left_click then
				input_key_to_shortcut( "Mouse_left" )
			elseif right_click then
				input_key_to_shortcut( "Mouse_right" )
			end
		end

		if left_click or right_click then
			changed = true
			ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), smallfolk.dumps( shortcut_inputed ), false )
			current_key_detector = nil
			shortcut_inputed = nil
		end

		mod_setting_tooltip( mod_id, gui, in_main_menu, setting )

		GuiLayoutEnd( gui )

		GuiLayoutBeginHorizontal( gui, mod_setting_group_x_offset + 120, 0, true, 2, 2 )
		if GuiButton( gui, 4 * im_id + 1, 0, 0, ( shortcut_text[ cur_lang ] or shortcut_text.DEFAULT ).done ) then
			changed = true
			ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), smallfolk.dumps( shortcut_inputed ), false )
			current_key_detector = nil
			shortcut_inputed = nil
		end
		if GuiButton( gui, 4 * im_id + 2, 0, 0, ( shortcut_text[ cur_lang ] or shortcut_text.DEFAULT ).clear ) then
			shortcut_inputed = {}
		end
		if GuiButton( gui, 4 * im_id + 3, 0, 0, ( shortcut_text[ cur_lang ] or shortcut_text.DEFAULT ).cancel ) then
			current_key_detector = nil
			shortcut_inputed = nil
		end
		GuiLayoutEnd( gui )
	else
		local str
		do
			local value = ModSettingGetNextValue( mod_setting_get_id( mod_id, setting ) )
			if type( value ) ~= "string" then value = setting.value_default or "{}" end
			local shortcut
			do
				local status, _ = pcall( function()
					shortcut = smallfolk.loads( value )
				end )
				if not status then
					shortcut = {}
				end
			end

			if #shortcut == 0 then
				str = "$menuoptions_configurecontrols_action_unbound"
			else
				str = shortcut_tostring( shortcut, GameTextGet( "$current_language" ) )
			end
		end

		GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
		local left_click, right_click = GuiButton( gui, im_id, x + 120, y, str )

		if left_click and not right_click then
			current_key_detector = setting.id
			shortcut_inputed = {}
		elseif not left_click and right_click then
			ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), setting.value_default, false )
			changed = true
		end

		mod_setting_tooltip( mod_id, gui, in_main_menu, setting )

		GuiLayoutEnd( gui )
	end

	GuiIdPop( gui )

	if changed then ModSettingSetNextValue( mod_id .. ".shortcut_changed", true, false ) end
end