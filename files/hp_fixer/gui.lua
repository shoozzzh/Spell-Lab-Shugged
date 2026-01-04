local hp_fixer = EntityGetWithName( "spell_lab_shugged_hp_fixer" )
if hp_fixer ~= 0 then
	local hp_comp = get_variable_storage_component( hp_fixer, "hp" )
	local max_hp_comp = get_variable_storage_component( hp_fixer, "max_hp" )
	local hp_fixed_to = ComponentGetValue2( hp_comp, "value_float" )
	local max_hp_fixed_to = ComponentGetValue2( max_hp_comp, "value_float" )
	local _,right_click = GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/heart.png" )
	if right_click then
		sound_button_clicked()
		EntityKill( hp_fixer )
	end
	local _,_,_,x,y = previous_data( gui )
	GuiTooltip( gui, GameTextGet( wrap_key( "hp_fixed_to" ),
	format_damage( hp_fixed_to ), format_damage( max_hp_fixed_to ) ), "" )
	GuiZSetForNextWidget( gui, -1 )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiImage( gui, get_id(), x - 2, y - 2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
else
	if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/heart.png" ) then
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
