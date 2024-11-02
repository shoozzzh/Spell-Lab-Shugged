dofile_once( "mods/spell_lab_shugged/files/gui/shot_effect_entries.lua" )

dofile_once( "data/scripts/perks/perk_list.lua" )
local perk_id_to_idx = {}
for idx, perk in ipairs( perk_list ) do
	perk_id_to_idx[ perk.id ] = idx
end

dofile_once( "data/scripts/status_effects/status_list.lua" )
local status_id_to_idx = {}
for idx, status in ipairs( status_effects ) do
	status_id_to_idx[ status.id ] = idx
end

local shot_effect_data = {}
for _, shot_effect in ipairs( shot_effect_entries ) do
	local data = {}

	data.name = shot_effect.name
	data.desc = shot_effect.desc
	data.icon = shot_effect.icon
	data.max_count = shot_effect.max_count

	local related_status = shot_effect.related_status
	if related_status then
		related_status = status_effects[ status_id_to_idx[ related_status ] ]
		if related_status then
			data.name = data.name or related_status.ui_name
			data.desc = data.desc or related_status.ui_description
			data.icon = data.icon or related_status.ui_icon
			data.max_count = data.max_count or 1
		end
	end

	local related_perk = shot_effect.related_perk
	if related_perk then
		related_perk = perk_list[ perk_id_to_idx[ related_perk ] ]
		if related_perk then
			data.name = data.name or related_perk.ui_name
			data.desc = data.desc or related_perk.ui_description
			data.icon = data.icon or related_perk.perk_icon
			if related_perk.stackable == STACKABLE_YES then
				if related_perk.stackable_maximum then
					data.max_count = data.max_count or related_perk.stackable_maximum
				else
					data.max_count = data.max_count or -1
				end
			else
				data.max_count = data.max_count or 1
			end
		end
	end

	if not data.icon or not data.name or not data.desc then
		goto continue
	end

	local extra_modifiers = shot_effect.extra_modifiers
	if type( extra_modifiers ) == "string" then
		data.extra_modifiers = { extra_modifiers }
	else
		data.extra_modifiers = extra_modifiers
	end
	local scripts_shot = shot_effect.scripts_shot
	if type( scripts_shot ) == "string" then
		data.scripts_shot = { scripts_shot }
	else
		data.scripts_shot = scripts_shot
	end

	data.equivalent_action_type = shot_effect.equivalent_action_type or ACTION_TYPE_MODIFIER
	data.no_unsafe = shot_effect.no_unsafe

	data.count = 0

	shot_effect_data[ #shot_effect_data + 1 ] = data

	::continue::
end

local function get_shot_effects_holder()
	local holder = EntityGetWithName( "spell_lab_shugged_shot_effects_holder" )
	if holder == 0 then
		holder = EntityLoad( "mods/spell_lab_shugged/files/entities/shot_effects_holder.xml" )
		EntityAddChild( player, holder )
	end
	return holder
end

local function add_shot_effect( shot_effect )
	local holder = get_shot_effects_holder()
	for _, extra_modifier in ipairs( shot_effect.extra_modifiers or {} ) do
		EntityAddComponent2( holder, "ShotEffectComponent", { extra_modifier = extra_modifier } )
	end
	for _, script_shot in ipairs( shot_effect.scripts_shot or {} ) do
		EntityAddComponent2( holder, "LuaComponent", { script_shot = script_shot } )
	end
end

local function remove_shot_effect( shot_effect )
	local holder = get_shot_effects_holder()
	for _, extra_modifier in ipairs( shot_effect.extra_modifiers or {} ) do
		for _, comp_id in ipairs( EntityGetComponent( holder, "ShotEffectComponent" ) or {} ) do
			if ComponentGetValue2( comp_id, "extra_modifier" ) == extra_modifier then
				EntityRemoveComponent( holder, comp_id )
				break
			end
		end
	end
	for _, script_shot in ipairs( shot_effect.scripts_shot or {} ) do
		for _, comp_id in ipairs( EntityGetComponent( holder, "LuaComponent" ) or {} ) do
			if ComponentGetValue2( comp_id, "script_shot" ) == script_shot then
				EntityRemoveComponent( holder, comp_id )
				break
			end
		end
	end
end

local picker = {}
picker.menu = function()
	GuiLayoutBeginVertical( gui, 640 * 0.05, 360 * 0.16, true )
		do_scroll_table( next_id(), SCROLL_TABLE_WIDTH, nil, shot_effect_data, function( shot_effect, i )
			local count = shot_effect.count
			local max_count = shot_effect.max_count
			local unsafe_count_allowed = mod_setting_get( "shot_effect_unsafe_count_allowed" ) and not shot_effect.no_unsafe
			local max_count_valid = max_count and max_count ~= -1
			local count_shown
			if count == 0 then
				count_shown = nil
			elseif not unsafe_count_allowed and max_count == 1 then
				count_shown = nil
			else
				count_shown = count
			end

			if count == 0 then
				GuiOptionsAdd( gui, GUI_OPTION.DrawSemiTransparent )
			end
			local left_click, right_click = do_fake_action_button(
				shot_effect.equivalent_action_type, shot_effect.icon, count_shown, {}, {} )
			if left_click then
				if not max_count_valid or count < max_count or unsafe_count_allowed then
					shot_effect.count = count + 1
					add_shot_effect( shot_effect )
				end
			elseif right_click then
				if count > 0 then
					shot_effect.count = count - 1
					remove_shot_effect( shot_effect )
				end
			end
			if count == 0 then
				GuiOptionsRemove( gui, GUI_OPTION.DrawSemiTransparent )
			end
		end )
	GuiLayoutEnd( gui )
end
picker.buttons = function() end

return picker