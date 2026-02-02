print "[spell lab] setting up GUI"

dofile_once( mod_path .. "files/misc_utils.lua" )

local module_path = module_path()

pop = dofile( mod_path .. "libs/pop/main.lua" )

gui_elements = dofile_once( module_path .. "gui_elements.lua" )
dofile_once( mod_path .. "files/gui/get_player.lua" )
dofile_once( mod_path .. "files/wand_spell_utils.lua" )
WANDS = dofile_once( mod_path .. "libs/wands.lua" )
-- dofile_once( "data/scripts/debug/keycodes.lua" )


smallfolk = dofile_once( mod_path .. "libs/smallfolk.lua" )
dofile_once( module_path .. "utils.lua" )

-- keyboard_focus = dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_focus.lua" )

is_panel_open = false

-- wand_stats = dofile( "mods/spell_lab_shugged/files/gui/wand_stats.lua" )

-- local edit_panel_api = dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

menus = dofile_once( module_path .. "menus.lua" )
-- dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )

local menus_line = {
	"terrain_spell_lab", "spell_picker", "wand_picker", "wand_box", "spell_group_box",
	"shot_effects", "toggles_toggle", "damage_info", "wand_edit_panel",
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
local function module_button( module_name, ... )
	dofile_once( module_button_path:format( module_name ) )( ... )
end

local function show_button_line( line )
	pop.pos.push( -22 * #line / 2 + 2, 0 )
	pop.auto_layout_stack( 22, 0 )( function( options )
		stream( line )
			.foreach( function( module_name )
				options.paused = false
				options.pause_after_next = true
				module_button( module_name )
			end )
	end )
	pop.pos.pop()
end

local function show_gui()
	pop.pos.push( pop.screen_size[ 1 ] / 2 + 80, pop.screen_size[ 2 ] * 0.02 )

	local layout = pop.layout_stack( 0, 20 + 2 )
	show_button_line( menus_line )

	layout.next()
	show_button_line( functions_line )

	-- if mod_setting.get "show_toggle_options" then
	-- 	layout.next()
	-- 	show_button_line( toggles_line )
	-- end

	layout.finish()

	-- if mod_setting_get( "show_wand_edit_panel" ) and held_wand then
	-- 	GuiLayoutBeginLayer( gui )
	-- 	local x, y = horizontal_centered_x(-9,4) + 5, 360 * 0.02 + percent_to_ui_scale_y(2)
	-- 	GuiLayoutBeginVertical( gui, x, y, true )
	-- 	show_edit_panel_toggle_options()
	-- 	GuiLayoutEnd( gui )
	-- 	GuiLayoutEndLayer( gui )
	-- end

	-- do_active_picker_buttons()

	-- do_active_picker_menu()

	-- if mod_setting_get( "show_wand_edit_panel" ) then
	-- 	dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" )
	-- end

	pop.pos.pop()
end

---@type callbacks
local callbacks = {}

function callbacks.OnWorldPreUpdate()
	ctrl = InputIsKeyDown( Key_LCTRL ) or InputIsKeyDown( Key_RCTRL )
	shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
	alt = InputIsKeyDown( Key_LALT ) or InputIsKeyDown( Key_RALT )

	pop.start_frame()
	now = GameGetFrameNum()

	pop.option.NoPositionTween = true
	pop.option.HandleDoubleClickAsClick = true
	pop.option.ClickCancelsDoubleClick = true

	world_state = GameGetWorldStateEntity()
	if EntityGetIsAlive( world_state ) then
		local comp_worldstate = EntityGetFirstComponentIncludingDisabled( world_state, "WorldStateComponent" )
		world_state_unlimited_spells = ComponentGetValue2( comp_worldstate, "perk_infinite_spells" )
	end

	player = get_player()
	held_wand = get_held_wand()

	-- edit_panel_api.listen_wand_changes()

	-- keyboard_focus.update()

	module_button "gui_entry_point"

	if is_panel_open and not GameIsInventoryOpen() and player and not GameHasFlagRun "gkbrkn_config_menu_open" then
		show_gui()
	else
		-- keyboard_focus.change_to( "player_controls" )
	end
end

print "[spell lab] done setting up GUI"

return callbacks
