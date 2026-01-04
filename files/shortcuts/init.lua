
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
