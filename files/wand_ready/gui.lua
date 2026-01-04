local raw_value_key = "spell_lab_shugged.wand_cast_delay_fixed_to_raw_value"
local cast_delay_key = "spell_lab_shugged.wand_cast_delay_fixed_to"
local reload_time_key = "spell_lab_shugged.wand_reload_time_fixed_to"

local fixed_to_raw_value = GlobalsGetValue( raw_value_key, "0" ) == "1"
local cast_delay_fixed_to = tonumber( GlobalsGetValue( cast_delay_key, "" ) )
local reload_time_fixed_to = tonumber( GlobalsGetValue( reload_time_key, "" ) )

if fixed_to_raw_value or ( cast_delay_fixed_to and reload_time_fixed_to ) then
	local left_click, right_click = GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wait.png" )
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
	GuiImage( gui, get_id(), x - 2, y - 2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
else
	local left_click, right_click = GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wait.png" )
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
