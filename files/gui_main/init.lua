print( "[spell lab] setting up GUI" )

dofile_once( mod_path .. "files/misc_utils.lua")

local module_path = this_folder()

-- dofile_once( "mods/spell_lab_shugged/files/gui/gui_utils.lua")
-- dofile_once( "mods/spell_lab_shugged/files/gui/gui_elements.lua")
-- dofile_once( "mods/spell_lab_shugged/files/spellbox_packs.lua" )
dofile_once( mod_path .. "files/gui/get_player.lua" )
WANDS = dofile_once( mod_path .. "libs/wands.lua")
-- dofile_once( "data/scripts/debug/keycodes.lua" )

pop = dofile( mod_path .. "libs/pop/main.lua" )

smallfolk = dofile_once( mod_path .. "libs/smallfolk.lua" )
dofile_once( module_path .. "utils.lua" )

-- keyboard_focus = dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_focus.lua" )

is_panel_open = false

-- wand_stats = dofile( "mods/spell_lab_shugged/files/gui/wand_stats.lua" )

-- local edit_panel_api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

-- dofile_once( "mods/spell_lab_shugged/files/gui/pickers.lua" )
-- dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )

local menu_line = {
	"terrain_spell_lab", "spell_picker", "wand_picker", "wand_box", "spell_group_box",
	"shot_effects", "toggle_options","damage_info", "wand_edit_panel",
}

local functions_line = {
	"shortcuts", "clear_projectiles", "wand_ready", "wand_clear", "twwe_effect",
	"hp_fixer", "target_dummy", "dummy_transforming", "convenient_wand",
}

local toggles_line = {
	"wand_no_shooting", "no_annoying_effects", "protection_all", "no_polymorphing",
	"no_recoil", "unlimited_spells", "creative_mode_flight",
}

local module_button_path = mod_path .. "files/%s/button.lua"
local function module_button( module_name )
	dofile_once( module_button_path:format( module_name ) )()
end

-- local function show_gui()
-- 	GuiLayoutBeginVertical( gui, 0, 360 * 0.02, true )
-- 	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )

-- 	gui_elements.flag_toggle_button( "mods/spell_lab_shugged/files/gui/buttons/show_toggles.png", "show_toggle_options", "toggle_options" )
	
-- 	GuiLayoutEnd( gui )

-- 	if mod_setting_get( "show_wand_edit_panel" ) and held_wand then
-- 		GuiLayoutBeginLayer( gui )
-- 		local x, y = horizontal_centered_x(-9,4) + 5, 360 * 0.02 + percent_to_ui_scale_y(2)
-- 		GuiLayoutBeginVertical( gui, x, y, true )
-- 		show_edit_panel_toggle_options()
-- 		GuiLayoutEnd( gui )
-- 		GuiLayoutEndLayer( gui )
-- 	end

	
-- 	GuiLayoutEnd( gui )

-- 	if mod_setting_get( "show_toggle_options" ) then
-- 		GuiLayoutBeginHorizontal( gui, horizontal_centered_x(8,4), percent_to_ui_scale_y(2), true )


-- 		GuiLayoutEnd( gui )
-- 	end

-- 	do_active_picker_buttons()

	
-- 	GuiLayoutEnd( gui )

-- 	do_active_picker_menu()

-- 	if mod_setting_get( "show_wand_edit_panel" ) then
-- 		dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" )
-- 	end
-- end

---@type callbacks
local callbacks = {}

function callbacks.OnWorldPreUpdate()
	-- shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
	-- alt = InputIsKeyDown( Key_LALT ) or InputIsKeyDown( Key_RALT )

	pop.start_frame()
	now = GameGetFrameNum()

	pop.option.NoPositionTween = true
	pop.option.HandleDoubleClickAsClick = true
	pop.option.ClickCancelsDoubleClick = true

	-- world_state = GameGetWorldStateEntity()
	-- if EntityGetIsAlive( world_state ) then
	-- 	local comp_worldstate = EntityGetFirstComponentIncludingDisabled( world_state, "WorldStateComponent" )
	-- 	world_state_unlimited_spells = ComponentGetValue2( comp_worldstate, "perk_infinite_spells" )
	-- end

	player = get_player()
	held_wand = get_held_wand()

	-- edit_panel_api.listen_wand_changes()

	-- keyboard_focus.update()

	module_button( "gui_entry_point" )

	if is_panel_open and not GameIsInventoryOpen() and player and not GameHasFlagRun( "gkbrkn_config_menu_open" ) then
		-- show_gui()
	else
		-- keyboard_focus.change_to( "player_controls" )
	end
end

print("[spell lab] done setting up GUI")

return callbacks
