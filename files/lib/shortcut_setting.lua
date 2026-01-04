local smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/shortcut_tostring.lua" )
dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_listener.lua" )
local KEYCODES_RAW = dofile_once( "mods/spell_lab_shugged/files/lib/keycodes_wrapped.lua" )[1]

local current_key_detector
function mod_setting_shortcut( mod_id, gui, in_main_menu, im_id, setting )
    GuiLayoutBeginHorizontal( gui, 0, 0, true, 2, 2 )
    GuiText( gui, mod_setting_group_x_offset, 0, setting.ui_name )

    local changed = false
	if current_key_detector == setting.id then
		local shortcut = {}
		for k, v in pairs( listen_keyboard_down() ) do
			if v then
				shortcut[ #shortcut + 1 ] = k
			end
		end

		local str
		if #shortcut > 0 then
			str = shortcut_tostring( shortcut, GameTextGet( "$current_language" ) )
			str = str .. ( setting.click_required and text.shortcut_click_here or text.shortcut_click_to_save )
		else
			str = "$menuoptions_configurecontrols_pressakey"
		end

		GuiColorSetForNextWidget( gui, 1, 1, 0.5, 1 )
		local left_click, right_click =
			GuiButton( gui, im_id, mod_setting_group_x_offset - GuiGetTextDimensions( gui, setting.ui_name ) + 120, 0, str )

		if InputIsMouseButtonJustUp( KEYCODES_RAW.Mouse_left ) or InputIsMouseButtonJustDown( KEYCODES_RAW.Mouse_right ) then
			current_key_detector = nil
			if not setting.click_required then
				ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), smallfolk.dumps( shortcut ), false )
				changed = true
			else
				local click_given = false
				if left_click then
					shortcut[ #shortcut + 1 ] = "Mouse_left"
					click_given = true
				end
				if right_click then
					shortcut[ #shortcut + 1 ] = "Mouse_right"
					click_given = true
				end
				if click_given then
					ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), smallfolk.dumps( shortcut ), false )
					changed = true
				end
			end
		end
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

		local left_click, right_click =
			GuiButton( gui, im_id, mod_setting_group_x_offset - GuiGetTextDimensions( gui, setting.ui_name ) + 120, 0, str )

		if left_click and not right_click then
			current_key_detector = setting.id
			ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), "{}", false )
			changed = true
		elseif not left_click and right_click then
			ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), "{}", false )
			changed = true
		end
	end

	if changed then ModSettingSet( mod_id .. ".shortcut_changed", true ) end

	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )

    GuiLayoutEnd( gui )
end