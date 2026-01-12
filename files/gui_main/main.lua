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

local function show_gui()
	GuiLayoutBeginVertical( gui, 0, 360 * 0.02, true )
	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )

	gui_elements.flag_toggle_button( "mods/spell_lab_shugged/files/gui/buttons/show_toggles.png", "show_toggle_options", "toggle_options" )
	
	GuiLayoutEnd( gui )

	if mod_setting_get( "show_wand_edit_panel" ) and held_wand then
		GuiLayoutBeginLayer( gui )
		local x, y = horizontal_centered_x(-9,4) + 5, 360 * 0.02 + percent_to_ui_scale_y(2)
		GuiLayoutBeginVertical( gui, x, y, true )
		show_edit_panel_toggle_options()
		GuiLayoutEnd( gui )
		GuiLayoutEndLayer( gui )
	end

	
	GuiLayoutEnd( gui )

	if mod_setting_get( "show_toggle_options" ) then
		GuiLayoutBeginHorizontal( gui, horizontal_centered_x(8,4), percent_to_ui_scale_y(2), true )


		GuiLayoutEnd( gui )
	end

	do_active_picker_buttons()

	
	GuiLayoutEnd( gui )

	do_active_picker_menu()

	if mod_setting_get( "show_wand_edit_panel" ) then
		dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" )
	end
end

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

	if is_panel_open and not GameIsInventoryOpen() and player and not GameHasFlagRun( "gkbrkn_config_menu_open" ) then
		show_gui()
	else
		keyboard_focus.change_to( "player_controls" )
	end
end

print("[spell lab] done setting up GUI")
