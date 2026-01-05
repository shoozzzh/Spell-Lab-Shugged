if do_gui then
	do_gui()
	return
else
	if gui_loaded == true then
		GamePrint( "[Spell Lab Shugged] The mod gui has crashed/failed to load. Please contact with Shug" )
		return
	end
end

gui_loaded = true

print( "[spell lab] setting up GUI" )

dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "data/scripts/gun/gun_enums.lua")
dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua")
dofile_once( "mods/spell_lab_shugged/files/gui/gui_utils.lua")
dofile_once( "mods/spell_lab_shugged/files/gui/gui_elements.lua")
dofile_once( "mods/spell_lab_shugged/files/gui/spellbox_packs.lua" )
dofile_once( "mods/spell_lab_shugged/files/gui/get_player.lua" )
WANDS = dofile_once( "mods/spell_lab_shugged/files/lib/wands.lua")
dofile_once( "data/scripts/debug/keycodes.lua" )
smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )

local keystroke_listener = dofile( "mods/spell_lab_shugged/files/gui/keystroke_listener.lua" )
shortcut_detector = dofile_once( "mods/spell_lab_shugged/files/lib/shortcut_detector.lua" )( keystroke_listener )
keyboard_focus = dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_focus.lua" )

gui = gui or GuiCreate()
local id_allocator = dofile_once( "mods/spell_lab_shugged/libs/id_allocator.lua" )
get_id = id_allocator.get_id

GuiStartFrame( gui )
screen_width, screen_height = GuiGetScreenDimensions( gui )

local is_panel_open = false

wand_stats = dofile( "mods/spell_lab_shugged/files/gui/wand_stats.lua" )

local edit_panel_api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

dofile_once( "mods/spell_lab_shugged/files/gui/pickers.lua" )
dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )

function do_gui()
	shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
	alt = InputIsKeyDown( Key_LALT ) or InputIsKeyDown( Key_RALT )

	now = GameGetFrameNum()
	reset_z()

	GuiStartFrame( gui )
	id_allocator.new_frame()

	screen_width, screen_height = GuiGetScreenDimensions( gui )

	GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )
	GuiOptionsAdd( gui, GUI_OPTION.HandleDoubleClickAsClick )
	GuiOptionsAdd( gui, GUI_OPTION.ClickCancelsDoubleClick )

	world_state = GameGetWorldStateEntity()
	if EntityGetIsAlive( world_state ) then
		local comp_worldstate = EntityGetFirstComponentIncludingDisabled( world_state, "WorldStateComponent" )
		world_state_unlimited_spells = ComponentGetValue2( comp_worldstate, "perk_infinite_spells" )
	end

	player = get_player()
	held_wand = get_held_wand()

	edit_panel_api.listen_wand_changes()

	keyboard_focus.update()

	if GameGetFrameNum() % 60 == 0 then
		if mod_setting_get( "shortcut_changed" ) then
			mod_setting_set( "shortcut_changed", false )
			reload_shortcuts()
		end

		local cur_lang = GameTextGet( "$current_language" )
		if cur_lang ~= last_cur_lang then
			last_cur_lang = cur_lang
			reload_shortcut_texts()
		end

		change_spellbox_pack_if_needed()
	end

	if is_panel_open and not GameIsInventoryOpen() and player and not GameHasFlagRun( "gkbrkn_config_menu_open" ) then
		GuiLayoutBeginVertical( gui, 0, 360 * 0.02, true )
			GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )
				do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/edit_wands.png", PICKERS.SpellPicker, "spell_picker", function( showing )
					if showing and held_wand and mod_setting_get( "quick_spell_picker" ) then
						mod_setting_set( "show_wand_edit_panel", true )
					end
				end )
				do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/wand_spawner.png", PICKERS.WandPicker, "wand_spawner" )
				do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/wand_list.png", PICKERS.WandBox, "wand_box" )
				do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/spell_groups.png", PICKERS.SpellGroupBox, "spell_group_box", function( showing )
					if showing and held_wand then
						mod_setting_set( "show_wand_edit_panel", true )
					end
				end )
				do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/shot_effects.png", PICKERS.ShotEffects, "shot_effects" )
				do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/show_toggles.png", "show_toggle_options", "toggle_options" )
				do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/damage_info.png", "damage_info" )
				do
					local gif_mode = mod_setting_get( "gif_mode" )
					local description = wrap_key( gif_mode and "gif_mode_disable" or "gif_mode_enable" )
					local left_click, right_click = do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/show_wand_edit_panel.png", "show_wand_edit_panel", "wand_edit_panel", nil, description )
					if right_click then
						sound_button_clicked()
						mod_setting_set( "gif_mode", not gif_mode )
					end
				end
			GuiLayoutEnd( gui )

			if mod_setting_get( "show_wand_edit_panel" ) and held_wand then
				GuiLayoutBeginLayer( gui )
					local x, y = horizontal_centered_x(-9,4) + 5, 360 * 0.02 + percent_to_ui_scale_y(2)
					GuiLayoutBeginVertical( gui, x, y, true )
						show_edit_panel_toggle_options()
					GuiLayoutEnd( gui )
				GuiLayoutEndLayer( gui )
			end

			GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )
				GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/shortcut_tips.png" )

				GuiTooltip( gui, wrap_key( "shortcut_tips_title" ), edit_panel_shortcut_tips )

				if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wand.png" ) then
					if held_wand then
						sound_button_clicked()
						WANDS.wand_clear_actions( held_wand )
					end
				end
				GuiTooltip( gui, wrap_key( "clear_held_wand" ), "" )
			GuiLayoutEnd( gui )

			if mod_setting_get( "show_toggle_options" ) then
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x(8,4), percent_to_ui_scale_y(2), true )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_projectiles.png", "disable_casting" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_toxic_statuses.png", "disable_toxic_statuses", nil, nil, wrap_key( "disable_toxic_statuses_description" ) )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/invincible.png", "invincible", "$status_protection_all" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_polymorphing.png", "no_polymorphing", "$status_protection_polymorph" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/no_recoil.png", "no_recoil" )

					local desc = wrap_key( "creative_mode_flight_description" )
					if DebugGetIsDevBuild() then
						desc = GameTextGetTranslatedOrNot( desc ) .. "\n" .. text_get_translated( "creative_mode_flight_note_dev_exe" )
					end
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/creative_mode_flight.png", "creative_mode_flight", nil, nil, desc )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/better_all_seeing_eye.png", "better_all_seeing_eye", "$perk_remove_fog_of_war" )
				GuiLayoutEnd( gui )
			end

			do_active_picker_buttons()

			if mod_setting_get( "damage_info" ) then
				dofile( "mods/spell_lab_shugged/files/gui/damage_info.lua" )
			end
		GuiLayoutEnd( gui )

		do_active_picker_menu()

		if mod_setting_get( "show_wand_edit_panel" ) then
			dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" )
		end
	else
		keyboard_focus.change_to( "player_controls" )
	end
end

print("[spell lab] done setting up GUI")
