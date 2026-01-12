local module_path = this_folder()

local mod_button_reservation = tonumber( GlobalsGetValue( "spell_lab_shugged_mod_button_reservation", "0" ) )
local current_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_current", "0" ) )
if current_button_reservation > mod_button_reservation then
	current_button_reservation = mod_button_reservation
elseif current_button_reservation < mod_button_reservation then
	current_button_reservation = math.max( 0, current_button_reservation )
else
	current_button_reservation = mod_button_reservation
end
GlobalsSetValue( "mod_button_tr_current", tostring( current_button_reservation + 15 ) )

-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.AlwaysClickable )
if GuiImageButton( gui, get_id(), screen_width - 14 - current_button_reservation, 2, "", module_path .. "button.png" ) then
	sound_button_clicked()
	is_panel_open = not is_panel_open
end

local _,_,hover = previous_data( gui )

if hover then
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
		GuiDimText( gui, 0, 0, mod_version )
	end, x - 5 - 2 - 3, y + 10 )
	GuiZSet( gui, 100 )
	GuiOptionsRemove( gui, GUI_OPTION.Align_Left )
	GuiAnimateEnd( gui )
end
