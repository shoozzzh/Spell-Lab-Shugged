local module_path = this_folder()

return function()
	local hp_fixer = EntityGetWithName "spell_lab_shugged_hp_fixer"
	if hp_fixer ~= 0 then
		local hp_comp = get_variable_storage_component( hp_fixer, "hp" )
		local max_hp_comp = get_variable_storage_component( hp_fixer, "max_hp" )
		local hp_fixed_to = ComponentGetValue2( hp_comp, "value_float" )
		local max_hp_fixed_to = ComponentGetValue2( max_hp_comp, "value_float" )
		local _, right_click = pop.button( module_path .. "button.png" )
		if right_click then
			sound_button_clicked()
			EntityKill( hp_fixer )
		end
		pop.tooltip( GameTextGet( wrap_key "hp_fixed_to",
			format.damage( hp_fixed_to ), format.damage( max_hp_fixed_to ) ), "" )
		pop.z_mod_next( -1 )
		pop.pos.next( -2, -2 )
		pop.image( mod_path .. "files/gui_main/locked.png" )
	else
		if pop.button( module_path .. "button.png" ) then
			sound_button_clicked()
			if shift then
				EntityAddChild( player, EntityLoad( module_path .. "hp_fixer.xml" ) )
			else
				local damage_model = EntityGetFirstComponentIncludingDisabled( player, "DamageModelComponent" )
				if damage_model then
					local max_hp = ComponentGetValue2( damage_model, "max_hp" )
					ComponentSetValue2( damage_model, "hp", max_hp )
				end
			end
		end
		pop.tooltip( wrap_key "full_hp" )
	end
end
