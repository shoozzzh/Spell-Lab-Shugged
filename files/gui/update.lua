if do_gui then
	do_content_wrapped( do_gui, "main" )
	return
end

print( "[spell lab] setting up GUI" )

dofile_once( "data/scripts/gun/gun.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua")
dofile_once( "mods/spell_lab_shugged/files/gui/gui_utils.lua")
dofile_once( "mods/spell_lab_shugged/files/gui/gui_elements.lua")
dofile_once( "mods/spell_lab_shugged/files/gui/get_player.lua" )
WANDS = dofile_once( "mods/spell_lab_shugged/files/lib/wands.lua")
dofile_once( "data/scripts/debug/keycodes.lua" )
smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )

local keystroke_listener = dofile( "mods/spell_lab_shugged/files/gui/keystroke_listener.lua" )
shortcut_detector = dofile_once( "mods/spell_lab_shugged/files/lib/shortcut_detector.lua" )( keystroke_listener )
keyboard_focus = dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_focus.lua" )

gui = gui or GuiCreate()
GuiStartFrame( gui )
screen_width, screen_height = GuiGetScreenDimensions( gui )

local version = "Shugged v1.8.9"

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

sorted_actions = {}
action_data = {}
for k, _ in pairs( type_text ) do
	sorted_actions[ k ] = {}
end
for _, action in pairs( actions ) do
	sorted_actions[action.type][ #sorted_actions[action.type] + 1 ] = action
	action_data[action.id] = action
end
action_metadata, extra_modifier_metadata, metadata_to_show =
	unpack( dofile( "mods/spell_lab_shugged/files/gui/action_metadata.lua" ) )

local is_panel_open = false

dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )

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

dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

function show_edit_panel_toggle_options()
	GuiLayoutBeginHorizontal( gui, 0, 0, true )
		local edit_panel_state = access_edit_panel_state( held_wand )
		local force_compact_enabled = edit_panel_state.get_force_compact_enabled()
		if not force_compact_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/force_compact.png" ) then
			sound_button_clicked()
			edit_panel_state.set_force_compact_enabled( not force_compact_enabled )
			edit_panel_state.force_sync()
		end
		GuiTooltip( gui, text_get_translated( force_compact_enabled and "disable" or "enable" ) .. text_get_translated( "wand_force_compact" ), text_get_translated( "wand_force_compact_description" ) .. "\n" .. text_get_translated( "inventory_get_ignored" )  )
		local autocap_enabled = edit_panel_state.get_autocap_enabled()
		if not autocap_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/automatic_capacity.png" ) then
			sound_button_clicked()
			edit_panel_state.set_autocap_enabled( not autocap_enabled )
			if autocap_enabled and edit_panel_state.get_force_compact_enabled() then
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
			end
		end
		GuiTooltip( gui, text_get_translated( autocap_enabled and "disable" or "enable" ) .. text_get_translated( "automatic_capacity" ), wrap_key( "automatic_capacity_description" ) )
	GuiLayoutEnd( gui )

	GuiLayoutBeginHorizontal( gui, 0, 0, true )
		local function cant_undo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" )
			GuiTooltip( gui, text_get_translated( "cant_undo" ), "" )
		end
		local function cant_redo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" )
			GuiTooltip( gui, text_get_translated( "cant_redo" ), "" )
		end
		local operation_to_undo = edit_panel_state.peek_undo()
		local operation_to_redo = edit_panel_state.peek_redo()
		if operation_to_undo then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" ) then
				sound_button_clicked()
				edit_panel_state.undo()
			end
			GuiTooltip( gui, text_get_translated( "undo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_undo ),
				GameTextGet( wrap_key( "current_history" ), edit_panel_state.get_current_history_index() ) )
		else cant_undo() end
		if operation_to_redo then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" ) then
				sound_button_clicked()
				edit_panel_state.redo()
			end
			GuiTooltip( gui, text_get_translated( "redo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_redo ),
				GameTextGet( wrap_key( "current_history" ), edit_panel_state.get_current_history_index() ) )
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

function do_gui()
	shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
	alt = InputIsKeyDown( Key_LALT ) or InputIsKeyDown( Key_RALT )

	cached_mouse_x, cached_mouse_y = nil, nil

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
	
	dofile( "mods/spell_lab_shugged/files/gui/wand_listener.lua" )

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
	if GuiImageButton( gui, next_id(), screen_width - 14 - current_button_reservation, 2, "", "mods/spell_lab_shugged/files/gui/wrench.png" ) then
		sound_button_clicked()
		is_panel_open = not is_panel_open
	end
	
	local animation_id = next_id()
	next_id()
	if previous_hovered() then
		local _,_,_,x,y = previous_data( gui )
		local text = wrap_key( ( is_panel_open and "hide" or "show" ) .. "_spell_lab" )
		local text_width = GuiGetTextDimensions( gui, text )
		GuiAnimateBegin( gui )
		GuiAnimateAlphaFadeIn( gui, animation_id, 0.08, 0.1, false )
		GuiAnimateScaleIn( gui, animation_id + 1, 0.08, false )
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
				if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) == "0" then
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
				end
				GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spell_lab.png" )
				do
					local left_click, right_click = previous_data( gui )
					if left_click then
						sound_button_clicked()
						if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) == "0" then
							local px, py = EntityGetTransform( player )
							GlobalsSetValue( "spell_lab_shugged_checkpoint_x", math.floor( px ) )
							GlobalsSetValue( "spell_lab_shugged_checkpoint_y", math.floor( py ) )
							EntityApplyTransform( player, 14600, -6050 )
							GameSetCameraPos( 14600, -6050 )
						else
							if not shift then
								local cx = tonumber( GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) )
								local cy = tonumber( GlobalsGetValue( "spell_lab_shugged_checkpoint_y", "0" ) ) - 10
								EntityApplyTransform( player, cx, cy )
								GameSetCameraPos( cx, cy )
							else
								EntityApplyTransform( player, 250, -100 )
								GameSetCameraPos( 250, -100 )
							end
							GlobalsSetValue( "spell_lab_shugged_checkpoint_x", "0" )
							GlobalsSetValue( "spell_lab_shugged_checkpoint_y", "0" )
						end
					elseif right_click then
						if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) ~= "0" then
							sound_button_clicked()
							EntityLoad( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
						end
					end
				end
				if GlobalsGetValue( "spell_lab_shugged_checkpoint_x", "0" ) == "0" then
					GuiTooltip( gui, wrap_key( "enter_spell_lab" ), "" )
				else
					GuiTooltip( gui, wrap_key( "leave_spell_lab" ), wrap_key( "reload_spell_lab" ) )
				end

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
				GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/shortcut_tips.png" )

				GuiTooltip( gui, wrap_key( "shortcut_tips_title" ), edit_panel_shortcut_tips )

				if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_projectiles.png" ) then
					sound_button_clicked()

					local function silent_kill( proj_id )
						for _, proj_comp in ipairs( EntityGetComponentIncludingDisabled( proj_id, "ProjectileComponent" ) or {} ) do
							ComponentSetValue2( proj_comp, "on_death_explode", false )
							ComponentSetValue2( proj_comp, "on_lifetime_out_explode", false )
						end
						for _, expl_comp in ipairs( EntityGetComponentIncludingDisabled( proj_id, "ExplosionComponent" ) or {} ) do
							ComponentSetValue2( expl_comp, "trigger", "ON_CREATE" )
						end
						for _, litn_comp in ipairs( EntityGetComponentIncludingDisabled( proj_id, "LightningComponent" ) or {} ) do
							EntitySetComponentIsEnabled( proj_id, litn_comp, false )
						end
						EntityKill( proj_id )
					end

					for _, proj_id in ipairs( EntityGetWithTag( "projectile" ) or {} ) do
						silent_kill( proj_id )
					end
					for _, proj_id in ipairs( EntityGetWithTag( "player_projectile" ) or {} ) do
						silent_kill( proj_id )
					end
				end
				GuiTooltip( gui, wrap_key( "clear_projectiles" ), "" )

				do
					local raw_value_key = "spell_lab_shugged.wand_cast_delay_fixed_to_raw_value"
					local cast_delay_key = "spell_lab_shugged.wand_cast_delay_fixed_to"
					local reload_time_key = "spell_lab_shugged.wand_reload_time_fixed_to"

					local fixed_to_raw_value = GlobalsGetValue( raw_value_key, "0" ) == "1"
					local cast_delay_fixed_to = tonumber( GlobalsGetValue( cast_delay_key, "" ) )
					local reload_time_fixed_to = tonumber( GlobalsGetValue( reload_time_key, "" ) )

					if fixed_to_raw_value or ( cast_delay_fixed_to and reload_time_fixed_to ) then
						local left_click, right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wait.png" )
						if left_click then
							if clear_held_wand_wait() then sound_button_clicked() end
						elseif right_click then
							if fixed_to_raw_value then
								GlobalsSetValue( raw_value_key, "" )
								sound_button_clicked()
							elseif cast_delay_fixed_to and reload_time_fixed_to then
								GlobalsSetValue( cast_delay_key, "" )
								GlobalsSetValue( reload_time_key, "" )
								sound_button_clicked()
							end
						end
						local _,_,_,x,y = previous_data( gui )
						if fixed_to_raw_value then
							local raw_value_text = GameTextGetTranslatedOrNot( wrap_key( "wand_raw_value" ) )
							GuiTooltip( gui, wrap_key( "wand_ready" ), GameTextGet( wrap_key( "wand_cast_delay_fixed_to" ), raw_value_text, raw_value_text ) )
						elseif cast_delay_fixed_to and reload_time_fixed_to then
							GuiTooltip( gui, wrap_key( "wand_ready" ), GameTextGet( wrap_key( "wand_cast_delay_fixed_to" ),
							format_time( cast_delay_fixed_to ), format_time( reload_time_fixed_to ) ) )
						end
						GuiZSetForNextWidget( gui, -1 )
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
						GuiImage( gui, next_id(), x - 2, y - 2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
					else
						local left_click, right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wait.png" )
						if shift and left_click then
							if held_wand then
								local ab_comp = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
								if ab_comp then
									local cast_delay = WANDS.ability_component_get_stat( ab_comp, "fire_rate_wait" )
									local reload_time = WANDS.ability_component_get_stat( ab_comp, "reload_time" )
									GlobalsSetValue( cast_delay_key, tostring( cast_delay ) )
									GlobalsSetValue( reload_time_key, tostring( reload_time ) )
									sound_button_clicked()
								end
							end
						elseif shift and right_click then
							GlobalsSetValue( cast_delay_key, "0" )
							GlobalsSetValue( reload_time_key, "0" )
							sound_button_clicked()
						elseif alt and ( left_click or right_click ) then
							GlobalsSetValue( raw_value_key, "1" )
							sound_button_clicked()
						elseif left_click then
							if clear_held_wand_wait() then sound_button_clicked() end
						end
					end
					GuiTooltip( gui, wrap_key( "wand_ready" ), wrap_key( "wand_ready_description" ) )
				end

				if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wand.png" ) then
					if held_wand then
						sound_button_clicked()
						WANDS.wand_clear_actions( held_wand )
					end
				end
				GuiTooltip( gui, wrap_key( "clear_held_wand" ), "" )

				local num_effects_positive = GameGetGameEffectCount( player, "EDIT_WANDS_EVERYWHERE" )
				local num_effects_negative = GameGetGameEffectCount( player, "NO_WAND_EDITING" )
				local wand_editing_level = num_effects_positive - num_effects_negative
				if wand_editing_level > 0 then
					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/edit_wands_everywhere.png" )
				elseif wand_editing_level < 0 then
					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/edit_wands_everywhere.png" )
				else
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/edit_wands_everywhere.png" )
				end
				do
					local a = #EntityGetWithTag( "spell_lab_shugged_effect_edit_wands_everywhere" )
					local b = #EntityGetWithTag( "spell_lab_shugged_effect_no_wand_editing" )
					local c = GameGetGameEffectCount( player, "EDIT_WANDS_EVERYWHERE" ) - a
					local d = GameGetGameEffectCount( player, "NO_WAND_EDITING" ) - b
					local level = a + c - b - d
					local tooltip = {}

					if num_effects_positive > 0 then
						tooltip[ #tooltip + 1 ] = GameTextGet( wrap_key( "edit_wands_num" ), text_get( "edit_wands_perk_positive" ), a, c )
					end
					if num_effects_negative > 0 then
						tooltip[ #tooltip + 1 ] = GameTextGet( wrap_key( "edit_wands_num" ), text_get( "edit_wands_perk_negative" ), b, d )
					end

					local expr = {}
					local function add_num_to_expr( num )
						if #expr > 0 then
							expr[ #expr + 1 ] = " + "
						end
						if num > 0 then
							expr[ #expr + 1 ] = tostring( num )
						elseif num == 0 then
							expr[ #expr + 1 ] = "0"
						elseif num < 0 then
							expr[ #expr + 1 ] = "("
							expr[ #expr + 1 ] = tostring( num )
							expr[ #expr + 1 ] = ")"
						end
					end

					if a ~= 0 or c ~= 0 then
						add_num_to_expr( a )
						add_num_to_expr( c )
					end
					if b ~= 0 or d ~= 0 then
						add_num_to_expr( -b )
						add_num_to_expr( -d )
					end

					if #expr > 0 then
						expr[ #expr + 1 ] = " = "
					end
					expr[ #expr + 1 ] = tostring( level )

					if level > 0 then
						expr[ #expr + 1 ] = " > 0"
					elseif level < 0 then
						expr[ #expr + 1 ] = " < 0"
					end

					table.insert( tooltip, GameTextGet( wrap_key( "edit_wands_level" ), table.concat( expr ) ) )

					if level > 0 then
						table.insert( tooltip, wrap_key( "edit_wands_everywhere" ) )
					elseif level == 0 then
						table.insert( tooltip, wrap_key( "edit_wands_workshop" ) )
					else
						table.insert( tooltip, wrap_key( "edit_wands_unable" ) )
					end

					local title = {
						GameTextGet( wrap_key( "edit_wands_gain" ), text_get( "edit_wands_perk_positive" ) ),
						GameTextGet( wrap_key( "edit_wands_lose" ), text_get( "edit_wands_perk_positive" ) ),
					}

					local left_click,right_click = previous_data( gui )

					if left_click then
						sound_button_clicked()
						local effect_to_remove = EntityGetWithTag( "spell_lab_shugged_effect_no_wand_editing" )[1]
						if effect_to_remove then
							EntityRemoveTag( effect_to_remove, "spell_lab_shugged_effect_no_wand_editing" )
							EntityRemoveFromParent( effect_to_remove )
							EntityKill( effect_to_remove )
						else
							local effect_id = EntityCreateNew()
							EntityAddChild( player, effect_id )
							EntityAddComponent2( effect_id, "GameEffectComponent", {
								effect = "EDIT_WANDS_EVERYWHERE",
								frames = -1,
							} )
							EntityAddTag( effect_id, "spell_lab_shugged_effect_edit_wands_everywhere" )
						end
					elseif right_click then
						sound_button_clicked()
						local effect_to_remove = EntityGetWithTag( "spell_lab_shugged_effect_edit_wands_everywhere" )[1]
						if effect_to_remove then
							EntityRemoveTag( effect_to_remove, "spell_lab_shugged_effect_edit_wands_everywhere" )
							EntityRemoveFromParent( effect_to_remove )
							EntityKill( effect_to_remove )
						else
							local effect_id = EntityCreateNew()
							EntityAddChild( player, effect_id )
							EntityAddComponent2( effect_id, "GameEffectComponent", {
								effect = "NO_WAND_EDITING",
								frames = -1,
							} )
							EntityAddTag( effect_id, "spell_lab_shugged_effect_no_wand_editing" )
						end
					end
					
					GuiTooltip( gui, table.concat( title, "\n" ), table.concat( tooltip, "\n" ) )
				end
				local hp_fixer = EntityGetWithName( "spell_lab_shugged_hp_fixer" )
				if hp_fixer ~= 0 then
					local hp_comp = get_variable_storage_component( hp_fixer, "hp" )
					local max_hp_comp = get_variable_storage_component( hp_fixer, "max_hp" )
					local hp_fixed_to = ComponentGetValue2( hp_comp, "value_float" )
					local max_hp_fixed_to = ComponentGetValue2( max_hp_comp, "value_float" )
					local _,right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/heart.png" )
					if right_click then
						sound_button_clicked()
						EntityKill( hp_fixer )
					end
					local _,_,_,x,y = previous_data( gui )
					GuiTooltip( gui, GameTextGet( wrap_key( "hp_fixed_to" ),
						format_damage( hp_fixed_to ), format_damage( max_hp_fixed_to ) ), "" )
					GuiZSetForNextWidget( gui, -1 )
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
					GuiImage( gui, next_id(), x - 2, y - 2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
				else
					if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/heart.png" ) then
						sound_button_clicked()
						if shift then
							EntityAddChild( player, EntityLoad( "mods/spell_lab_shugged/files/entities/hp_fixer.xml" ) )
						else
							local damage_model = EntityGetFirstComponentIncludingDisabled( player, "DamageModelComponent" )
							if damage_model then
								local max_hp = ComponentGetValue2( damage_model, "max_hp" )
								ComponentSetValue2( damage_model, "hp", max_hp )
							end
						end
					end
					GuiTooltip( gui, wrap_key( "full_hp" ), "" )
				end


				GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spawn_target_dummy.png" )
				do
					local left_click,right_click = previous_data( gui )
					if left_click then
						sound_button_clicked()
						local x,y = get_player_or_camera_position()
						EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target.xml", x, y )
					elseif right_click then
						sound_button_clicked()
						local x,y = get_player_or_camera_position()
						EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target_final.xml", x, y )
					end
				end
				-- GuiTooltip( gui, wrap_key( "spawn_target_dummy" ), wrap_key( "spawn_target_dummy_description" ) )
				do_custom_tooltip( function()
					GuiText( gui, 0, 0, wrap_key( "spawn_target_dummy" ) )
					GuiText( gui, 0, 0, wrap_key( "spawn_target_dummy_description" ) )
					GuiLayoutAddVerticalSpacing( gui, 6 )
					GuiText( gui, 0, 0, wrap_key( "target_dummy_numbers_are" ) )
					GuiColorSetForNextWidget( gui, color(0,207,40,255) )
					GuiText( gui, 0, 0, wrap_key( "target_dummy_last_frame_damage" ) )
					GuiColorSetForNextWidget( gui, color(208,208,248,255) )
					GuiText( gui, 0, 0, wrap_key( "target_dummy_average_dps" ) )
					GuiColorSetForNextWidget( gui, color(255,85,0,255) )
					GuiText( gui, 0, 0, wrap_key( "target_dummy_total_damage" ) )
					GuiColorSetForNextWidget( gui, color(208,208,248,255) )
					GuiText( gui, 0, 0, wrap_key( "target_dummy_dps" ) )
					GuiColorSetForNextWidget( gui, color(126,126,126,255) )
					GuiText( gui, 0, 0, wrap_key( "target_dummy_highest_dps" ) )
				end, 3, 0, true )

				if not selecting_mortal_to_transform then
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
				end
				if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transform_into_target_dummy.png" ) then
					sound_button_clicked()
					selecting_mortal_to_transform = not selecting_mortal_to_transform
				end
				GuiTooltip( gui, wrap_key( "transform_mortal_into_target_dummy" ),
					text_get( "transform_mortal_into_target_dummy_description", shortcut_texts.transform_mortal_into_dummy )
				)

				GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spawn_convenient_wand.png" )
				do
					local left_click,right_click = previous_data( gui )
					local wand_data = {
						stats = {
							shuffle_deck_when_empty = false,
							actions_per_round = 1,
							fire_rate_wait = 10,
							reload_time = 20,
							mana_max = 100000,
							mana_charge_speed = 100000,
							capacity = 26,
							spread_degrees = 0,
							speed_multiplier = 1,
						},
						sprite = {
							file = "data/items_gfx/wands/wand_0821.png",
							hotspot = {
								x = 18.0,
								y = 0.0,
							},
							x = 4,
							y = 3,
						},
					}
					if left_click then
						sound_button_clicked()
						local x, y = get_player_or_camera_position()
						local wand = EntityLoad( "data/entities/items/wand_level_01.xml", x, y )
						WANDS.initialize_wand( wand, wand_data )
					elseif right_click and held_wand then
						sound_button_clicked()
						WANDS.initialize_wand( held_wand, wand_data, false )
					end
				end
				GuiTooltip( gui, wrap_key( "spawn_best_wand" ), wrap_key( "spawn_best_wand_description" ) )
			GuiLayoutEnd( gui )

			if mod_setting_get( "show_toggle_options" ) then
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x(8,4), percent_to_ui_scale_y(2), true )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_projectiles.png", "disable_casting" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_toxic_statuses.png", "disable_toxic_statuses", nil, nil, wrap_key( "disable_toxic_statuses_description" ) )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/invincible.png", "invincible", "$status_protection_all" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_polymorphing.png", "no_polymorphing", "$status_protection_polymorph" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/no_recoil.png", "no_recoil" )

					if not world_state_unlimited_spells then
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
					end
					if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/unlimited_spells.png" ) then
						sound_button_clicked()
						if EntityGetIsAlive( world_state ) then
							local comp_worldstate = EntityGetFirstComponent( world_state, "WorldStateComponent" )
							ComponentSetValue2( comp_worldstate, "perk_infinite_spells", not world_state_unlimited_spells )
						end
						if not world_state_unlimited_spells then
							if not mod_setting_get( "zero_uses" ) then
								GameRegenItemActionsInPlayer( player )
							end
							local inventory2 = EntityGetFirstComponent( player, "Inventory2Component" )
							if inventory2 ~= nil then
								ComponentSetValue2( inventory2, "mForceRefresh", true )
								ComponentSetValue2( inventory2, "mActualActiveItem", 0 )
							end
						end
					end
					GuiTooltip( gui, text_get_translated( world_state_unlimited_spells and "disable" or "enable" ) .. text_get_translated( "$perk_unlimited_spells" ), "" )

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
			do_content_wrapped(	function() dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" ) end, "edit_panel" )
		end
	else
		keyboard_focus.change_to( "player_controls" )
	end
end

print("[spell lab] done setting up GUI")