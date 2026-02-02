local module_path = module_path()

local raw_value_key = mod_id .. ".wand_cast_delay_fixed_to_raw_value"
local cast_delay_key = mod_id .. ".wand_cast_delay_fixed_to"
local reload_time_key = mod_id .. ".wand_reload_time_fixed_to"

return function()
	local fixed_to_raw_value = GlobalsGetValue( raw_value_key, "0" ) == "1"
	local cast_delay_fixed_to = tonumber( GlobalsGetValue( cast_delay_key, "" ) )
	local reload_time_fixed_to = tonumber( GlobalsGetValue( reload_time_key, "" ) )

	local left_click, right_click = pop.button( module_path .. "button.png" )
	if fixed_to_raw_value or (cast_delay_fixed_to and reload_time_fixed_to) then
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

		if fixed_to_raw_value then
			local raw_value_text = get_text "wand_raw_value"
			pop.tooltip( wrap_key "wand_ready",
				GameTextGet( wrap_key "wand_cast_delay_fixed_to", raw_value_text, raw_value_text ) )
		elseif cast_delay_fixed_to and reload_time_fixed_to then
			pop.tooltip( wrap_key "wand_ready", GameTextGet( wrap_key "wand_cast_delay_fixed_to",
				format.time( cast_delay_fixed_to ), format.time( reload_time_fixed_to ) ) )
		end

		pop.z_mod_next( -1 )
		pop.option_next "Layout_NoLayouting"
		pop.pos.next( -2, -2 )
		pop.image( mod_path .. "files/gui_main/locked.png" )
	else
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
		elseif alt and (left_click or right_click) then
			GlobalsSetValue( raw_value_key, "1" )
			sound_button_clicked()
		elseif left_click then
			if clear_held_wand_wait() then sound_button_clicked() end
		end
	end
	pop.tooltip( wrap_key "wand_ready", wrap_key "wand_ready_description" )
end
