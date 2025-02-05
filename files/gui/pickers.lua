PICKERS = {
	None = "",
	SpellPicker = "spell_picker",
	WandPicker = "wand_picker",
	WandBox = "wand_box",
	SpellGroupBox = "spell_group_box",
	ShotEffects = "shot_effects",
}

local pickers_data = {}

pickers_data[""] = {
	buttons = function()
		if mod_setting_get( "show_wand_edit_panel" ) and held_wand then
			GuiLayoutBeginHorizontal( gui, horizontal_centered_x(4,4), percent_to_ui_scale_y(2), true )
				show_edit_panel_toggle_options()
			GuiLayoutEnd( gui )
		end
	end,
	menu = function() end,
	name = "NONE",
}

for name, filename in pairs( PICKERS ) do
	if #filename > 0 then
		local data = dofile_once( "mods/spell_lab_shugged/files/gui/pickers/" .. filename .. ".lua" )
		data.name = name
		pickers_data[ filename ] = data
	end
end

local active_picker = ""
local active_picker_data = pickers_data[""]

function is_picker_active( picker )
	return picker == active_picker
end

function change_picker( picker )
	local result = picker == active_picker
	if result then picker = "" end
	active_picker = picker
	active_picker_data = pickers_data[ picker ]
	return result
end

function do_active_picker_menu()
	do_content_wrapped( active_picker_data.menu, active_picker_data.name .. "_menu" )
end

function do_active_picker_buttons()
	do_content_wrapped( active_picker_data.buttons, active_picker_data.name .. "buttons" )
end

function do_picker_button( filepath, picker, option_text, click_callback )
	if picker ~= active_picker then
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
	end
	local result
	if GuiImageButton( gui, next_id(), 0, 0, "", filepath ) then
		sound_button_clicked()
		result = change_picker( picker )
		if click_callback then
			click_callback( result )
		end
	end
	option_text = text_get_translated( option_text )
	if picker == active_picker then
		GuiTooltip( gui, text_get_translated( "disable" ) .. option_text, "" )
	else
		GuiTooltip( gui, text_get_translated( "enable" ) .. option_text, "" )
	end
end