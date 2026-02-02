local module_path = this_folder()

return function()
	local num_effects_positive = GameGetGameEffectCount( player, "EDIT_WANDS_EVERYWHERE" )
	local num_effects_negative = GameGetGameEffectCount( player, "NO_WAND_EDITING" )
	local wand_editing_level = num_effects_positive - num_effects_negative
	if wand_editing_level == 0 then
		pop.option_next "DrawSemiTransparent"
	end
	local left_click, right_click = pop.button( module_path .. "button.png" )

	local a = #EntityGetWithTag "spell_lab_shugged_effect_edit_wands_everywhere"
	local b = #EntityGetWithTag "spell_lab_shugged_effect_no_wand_editing"
	local c = GameGetGameEffectCount( player, "EDIT_WANDS_EVERYWHERE" ) - a
	local d = GameGetGameEffectCount( player, "NO_WAND_EDITING" ) - b
	local level = a + c - b - d
	local tooltip = {
		GameTextGet( wrap_key "edit_wands_gain", get_text "edit_wands_perk_positive" ),
		GameTextGet( wrap_key "edit_wands_lose", get_text "edit_wands_perk_positive" ),
	}

	if num_effects_positive > 0 then
		tooltip[ #tooltip+1 ] = GameTextGet( wrap_key "edit_wands_num", get_text "edit_wands_perk_positive",
			format.value( a, 0 ), format.value( c, 0 ) )
	end
	if num_effects_negative > 0 then
		tooltip[ #tooltip+1 ] = GameTextGet( wrap_key "edit_wands_num", get_text "edit_wands_perk_negative",
			format.value( b, 0 ), format.value( d, 0 ) )
	end

	local expr = {}
	local function add_num_to_expr( num )
		if #expr > 0 then
			expr[ #expr+1 ] = " + "
		end
		if num > 0 then
			expr[ #expr+1 ] = tostring( num )
		elseif num == 0 then
			expr[ #expr+1 ] = "0"
		elseif num < 0 then
			expr[ #expr+1 ] = "("
			expr[ #expr+1 ] = tostring( num )
			expr[ #expr+1 ] = ")"
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
		expr[ #expr+1 ] = " = "
	end
	expr[ #expr+1 ] = tostring( level )

	if level > 0 then
		expr[ #expr+1 ] = " > 0"
	elseif level < 0 then
		expr[ #expr+1 ] = " < 0"
	end

	tooltip[ #tooltip+1 ] = GameTextGet( wrap_key "edit_wands_level", table.concat( expr ) )

	if level > 0 then
		tooltip[ #tooltip+1 ] = wrap_key "edit_wands_everywhere"
	elseif level == 0 then
		tooltip[ #tooltip+1 ] = wrap_key "edit_wands_workshop"
	else
		tooltip[ #tooltip+1 ] = wrap_key "edit_wands_unable"
	end

	if left_click then
		sound_button_clicked()
		local effect_to_remove = EntityGetWithTag "spell_lab_shugged_effect_no_wand_editing"[ 1 ]
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
		local effect_to_remove = EntityGetWithTag "spell_lab_shugged_effect_edit_wands_everywhere"[ 1 ]
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

	pop.tooltip( unpack( tooltip ) )
end
