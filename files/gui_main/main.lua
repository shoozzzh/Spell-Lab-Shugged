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
local id_allocator = dofile_once( "mods/spell_lab_shugged/files/lib/id_allocator.lua" )
get_id = id_allocator.get_id

GuiStartFrame( gui )
screen_width, screen_height = GuiGetScreenDimensions( gui )

local version = "Shugged v1.8.11"

type_text = {
	[ACTION_TYPE_MODIFIER]          = "$inventory_actiontype_modifier",
	[ACTION_TYPE_PROJECTILE]        = "$inventory_actiontype_projectile",
	[ACTION_TYPE_STATIC_PROJECTILE] = "$inventory_actiontype_staticprojectile",
	[ACTION_TYPE_OTHER]             = "$inventory_actiontype_other",
	[ACTION_TYPE_MATERIAL]          = "$inventory_actiontype_material",
	[ACTION_TYPE_DRAW_MANY]         = "$inventory_actiontype_drawmany",
	[ACTION_TYPE_UTILITY]           = "$inventory_actiontype_utility",
	[ACTION_TYPE_PASSIVE]           = "$inventory_actiontype_passive",
}

local gun_global = get_globals( "data/scripts/gun/gun.lua" )
local actions = gun_global.actions

sorted_actions = {}
action_data = {}
for k, _ in pairs( type_text ) do
	sorted_actions[ k ] = {}
end
for _, action in ipairs( actions ) do
	local typed = sorted_actions[ action.type ]
	typed[ #typed + 1 ] = action
	action_data[ action.id ] = action
end
action_metadata, extra_modifier_metadata, metadata_to_show =
	unpack( dofile( "mods/spell_lab_shugged/files/gui/action_metadata.lua" ) )

local is_panel_open = false

action_id_to_idx = {}

for i, a in ipairs( actions ) do
	if a.id and a.id ~= "" then
		action_id_to_idx[ a.id ] = i
	end
	if a.max_uses ~= nil then
		local hell_no = type( a.max_uses )
		if hell_no == "string" then
			a.max_uses = tonumber( a.max_uses ) or 0
		elseif hell_no ~= "number" then
			a.max_uses = 0
		end
		if a.max_uses < 0 then
			a.max_uses = nil
		end
	end
end

wand_stats = dofile( "mods/spell_lab_shugged/files/gui/wand_stats.lua" )

local edit_panel_api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

function show_edit_panel_toggle_options()
	local data = edit_panel_api.access_data( held_wand )
	GuiLayoutBeginHorizontal( gui, 0, 0, true )
		local force_compact_enabled = data.vars.force_compact_enabled
		if not force_compact_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/force_compact.png" ) then
			sound_button_clicked()
			data.vars.force_compact_enabled = not force_compact_enabled
		end
		GuiTooltip( gui, text_get_translated( force_compact_enabled and "disable" or "enable" ) .. text_get_translated( "wand_force_compact" ), text_get_translated( "wand_force_compact_description" ) .. "\n" .. text_get_translated( "inventory_get_ignored" )  )

		local autocap_enabled = data.vars.autocap_enabled
		if not autocap_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/automatic_capacity.png" ) then
			sound_button_clicked()
			data.vars.autocap_enabled = not autocap_enabled
--[[			if autocap_enabled and force_compact_enabled then
				local new_capacity = 0
				for _ in state_str_iter_permanent_actions( edit_panel_state.get_permanent() ) do
					new_capacity = new_capacity + 1
				end
				local temp = 0
				for _, a, _ in state_str_iter_actions( edit_panel_state.get() ) do
					temp = temp + 1
					if a and a ~= "" then
						new_capacity = new_capacity + temp
						temp = 0
					end
				end
				WANDS.wand_set_stat( held_wand, "deck_capacity", new_capacity )
			end]]
		end
		GuiTooltip( gui, text_get_translated( autocap_enabled and "disable" or "enable" ) .. text_get_translated( "automatic_capacity" ), wrap_key( "automatic_capacity_description" ) )
	GuiLayoutEnd( gui )

	GuiLayoutBeginHorizontal( gui, 0, 0, true )
		local function cant_undo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" )
			GuiTooltip( gui, text_get_translated( "cant_undo" ), "" )
		end
		local function cant_redo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" )
			GuiTooltip( gui, text_get_translated( "cant_redo" ), "" )
		end

		local operation_to_undo = data:peek_undo()
		local operation_to_redo = data:peek_redo()

		if operation_to_undo then
			if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" ) then
				sound_button_clicked()
				data:undo()
			end
			GuiTooltip( gui, text_get_translated( "undo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_undo ),
				GameTextGet( wrap_key( "current_history" ), data.vars.current_history_index, #edit_panel_api.get_histories( held_wand ) ) )
		else cant_undo() end
		if operation_to_redo then
			if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" ) then
				sound_button_clicked()
				data:redo()
			end
			GuiTooltip( gui, text_get_translated( "redo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_redo ),
				GameTextGet( wrap_key( "current_history" ), data.vars.current_history_index, #edit_panel_api.get_histories( held_wand ) ) )
		else cant_redo() end
	GuiLayoutEnd( gui )
end

shortcuts = {
	select = { "Mouse_left" },
	deselect = { "Mouse_right" },
	multi_select = { "Key_CTRL", "Mouse_left" },
	expand_selection_left = { "Key_CTRL", "Key_ALT", "Mouse_left" },
	expand_selection_right = { "Key_CTRL", "Key_ALT", "Mouse_right" },
	swap = { "Key_ALT", "Mouse_left" },
	override = { "Key_ALT", "Mouse_right" },
	duplicate = { "Key_ALT", "Key_SHIFT", "Mouse_left" },
	delete_action = { "Key_SHIFT", "Mouse_left" },
	delete_slot = { "Key_SHIFT", "Mouse_right" },
	always_cast = { "Key_CTRL", "Key_SHIFT", "Mouse_left" },
	left_delete = { "Key_BACKSPACE" },
	right_delete = { "Key_DELETE" },
	undo = { "Key_CTRL", "Key_z" },
	redo = { "Key_CTRL", "Key_y" },
	relock = { "Key_CTRL", "Key_SHIFT", "Mouse_left" },
	show_wand_stats = { "Key_CTRL" },
	replace_switch_temp = { "Key_SHIFT" },
	replace_switch = {},
	confirm = { "Key_SHIFT" },
	clear_action_history = { "Key_SHIFT", "Mouse_right" },
	transform_mortal_into_dummy = { "Key_SHIFT" },
}

dofile_once( "mods/spell_lab_shugged/files/lib/shortcut_tostring.lua" )

shortcut_texts = {}

local edit_panel_shortcut_tips

function reload_shortcuts()
	for name, _ in pairs( shortcuts ) do
		local value = mod_setting_get( "shortcut_" .. name )
		local status
		if value == nil then goto continue end

		status, value = pcall( smallfolk.loads, value )
		if not status or ( value == nil ) then goto continue end

		shortcuts[ name ] = value
		::continue::
	end

	if not mod_setting_get( "shortcut_strict" ) then
		shortcut_used_keys = {}

		local inverted = {}
		for _, shortcut in pairs( shortcuts ) do
			for _, key in ipairs( shortcut ) do
				inverted[ key ] = true
			end
		end
		inverted.Mouse_left = nil
		inverted.Mouse_right = nil
		for key, _ in pairs( inverted ) do
			shortcut_used_keys[ #shortcut_used_keys + 1 ] = key
		end
	else
		shortcut_used_keys = nil
	end

	reload_shortcut_texts()
end

local last_cur_lang = GameTextGet( "$current_language" )

function reload_shortcut_texts()
	for name, v in pairs( shortcuts ) do
		shortcut_texts[ name ] = shortcut_tostring( v, last_cur_lang )
	end

	edit_panel_shortcut_tips = text_get_translated( "shortcut_tips" )
	for name, v in pairs( shortcuts ) do
		edit_panel_shortcut_tips = edit_panel_shortcut_tips:gsub( "{" .. name .. "}", shortcut_texts[ name ] )
	end
end

reload_shortcuts()

dofile_once( "mods/spell_lab_shugged/files/gui/pickers.lua" )
dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )

function do_gui()
	shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
	alt = InputIsKeyDown( Key_LALT ) or InputIsKeyDown( Key_RALT )

	now = GameGetFrameNum()
	reset_z()

	GuiStartFrame( gui )

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

	local mod_button_reservation = tonumber( GlobalsGetValue( "spell_lab_shugged_mod_button_reservation", "0" ) )
	local current_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_current", "0" ) )
	if current_button_reservation > mod_button_reservation then
		current_button_reservation = mod_button_reservation
	elseif current_button_reservation < mod_button_reservation then
		current_button_reservation = math.max( 0, mod_button_reservation + ( current_button_reservation - mod_button_reservation ) )
	else
		current_button_reservation = mod_button_reservation
	end
	GlobalsSetValue( "mod_button_tr_current", tostring( current_button_reservation + 15 ) )

	-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.AlwaysClickable )
	if GuiImageButton( gui, get_id(), screen_width - 14 - current_button_reservation, 2, "", "mods/spell_lab_shugged/files/gui/wrench.png" ) then
		sound_button_clicked()
		is_panel_open = not is_panel_open
	end

	if previous_hovered() then
		local _,_,_,x,y = previous_data( gui )
		local text = wrap_key( ( is_panel_open and "hide" or "show" ) .. "_spell_lab" )
		local text_width = GuiGetTextDimensions( gui, text )
		GuiAnimateBegin( gui )
		GuiAnimateAlphaFadeIn( gui, get_id(), 0.08, 0.1, false )
		GuiAnimateScaleIn( gui, get_id(), 0.08, false )
		GuiOptionsAdd( gui, GUI_OPTION.Align_Left )
		GuiZSet( gui, -100 )
		show_tooltip( function()
			GuiZSetForNextWidget( gui, -100 )
			GuiText( gui, 0, 0, text )
			GuiZSetForNextWidget( gui, -100 )
			GuiDimText( gui, 0, 0, version )
		end, x - 5 - 2 - 3, y + 10 )
		GuiZSet( gui, 100 )
		GuiOptionsRemove( gui, GUI_OPTION.Align_Left )
		GuiAnimateEnd( gui )
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
