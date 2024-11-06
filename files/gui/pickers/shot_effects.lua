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

dofile_once( "mods/spell_lab_shugged/files/lib/entity_xml_parser.lua" )

local SHOT_EFFECT_SOURCE_TYPE = {
	Perk         = wrap_key( "shot_effect_source_type_perk" ),
	Status       = wrap_key( "shot_effect_source_type_status" ),
	CustomEffect = wrap_key( "shot_effect_source_type_custom_effect" ),
}

local shot_effect_data = {}
for _, shot_effect in ipairs( shot_effect_entries ) do
	local data = {}

	data.id = shot_effect.id
	data.name = shot_effect.name
	data.desc = shot_effect.desc
	data.icon = shot_effect.icon
	data.source_type = shot_effect.source_type
	data.max_count = shot_effect.max_count

	local related_status = shot_effect.related_status
	if related_status then
		related_status = status_effects[ status_id_to_idx[ related_status ] ]
		if related_status then
			data.id = data.id or ( "STATUS_" .. related_status.id )
			data.name = data.name or related_status.ui_name
			data.desc = data.desc or related_status.ui_description
			data.icon = data.icon or related_status.ui_icon
			data.source_type = data.source_type or SHOT_EFFECT_SOURCE_TYPE.Status
			data.max_count = data.max_count or 1
		end
	end

	do
		local related_custom_effect = shot_effect.related_custom_effect
		if not related_custom_effect then goto related_custom_effect_skip end
		local effect_xml_content = parse_entity_xml( related_custom_effect )
		if not effect_xml_content then goto related_custom_effect_skip end
		local icon_comp = effect_xml_content:first_of( "UIIconComponent" )
		if not icon_comp then goto related_custom_effect_skip end
		data.id = data.id or string.upper( related_custom_effect:match( "([^/]+)%.xml$" ) )
		data.name = data.name or icon_comp.attr.name
		data.desc = data.desc or icon_comp.attr.description
		data.icon = data.icon or icon_comp.attr.icon_sprite_file
		data.source_type = data.source_type or SHOT_EFFECT_SOURCE_TYPE.CustomEffect
	end
	::related_custom_effect_skip::

	local related_perk = shot_effect.related_perk
	if related_perk then
		related_perk = perk_list[ perk_id_to_idx[ related_perk ] ]
		if related_perk then
			data.id = data.id or ( "PERK_" .. related_perk.id )
			data.name = data.name or related_perk.ui_name
			data.desc = data.desc or related_perk.ui_description
			data.icon = data.icon or related_perk.perk_icon
			data.source_type = data.source_type or SHOT_EFFECT_SOURCE_TYPE.Perk
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

	if not data.id or not data.icon or not data.name or not data.desc then
		goto continue
	end

	local keys = { "extra_modifier", "script_shot", "game_effect", "custom_child_entity" }
	for _, key in ipairs( keys ) do
		local value = shot_effect[ key ]
		if type( value ) ~= "table" then
			data[ key ] = { value }
		else
			data[ key ] = value
		end
	end

	data.properties = shot_effect.properties or {}
	if data.extra_modifier and #data.extra_modifier > 0 and not shot_effect.dont_use_fetched_metadata then
		local metadata = extra_modifier_metadata[ data.extra_modifier[1] ]
		if not metadata then
			print( "Invalid extra modifier id:", tostring( data.extra_modifier[1] ) )
		else
			for _, v in ipairs( c_metadata_to_lines( metadata ) ) do
				data.properties[ #data.properties + 1 ] = v
			end
		end
	end
	if data.max_count and data.max_count ~= -1 then
		data.properties[ #data.properties + 1 ] = { wrap_key( "shot_effect_max_count" ), data.max_count }
	else
		data.properties[ #data.properties + 1 ] = { wrap_key( "shot_effect_max_count" ), wrap_key( "shot_effect_max_count_infinite" ) }
	end

	data.equivalent_action_type = shot_effect.equivalent_action_type or ACTION_TYPE_MODIFIER
	data.no_unsafe = shot_effect.no_unsafe

	shot_effect_data[ #shot_effect_data + 1 ] = data

	::continue::
end

local function add_shot_effect( shot_effect )
	local entity_id = EntityLoad( "mods/spell_lab_shugged/files/entities/shot_effect_entity.xml" )
	EntityAddChild( player, entity_id )
	EntityAddComponent2( entity_id, "VariableStorageComponent", { value_string = shot_effect.id } )
	for _, extra_modifier in ipairs( shot_effect.extra_modifier or {} ) do
		EntityAddComponent2( entity_id, "ShotEffectComponent", { extra_modifier = extra_modifier } )
	end
	for _, script_shot in ipairs( shot_effect.script_shot or {} ) do
		EntityAddComponent2( entity_id, "LuaComponent", { script_shot = script_shot } )
	end
	for _, game_effect in ipairs( shot_effect.game_effect or {} ) do
		EntityAddComponent2( entity_id, "GameEffectComponent", { effect = game_effect } )
	end
	for _, custom_child_entity in ipairs( shot_effect.custom_child_entity or {} ) do
		local child_id = EntityLoad( custom_child_entity )
		EntityAddChild( entity_id, child_id )
	end
end

local function remove_shot_effect( shot_effect )
	local id = shot_effect.id
	for _, shot_effect_entity in ipairs( EntityGetAllChildren( player, "spell_lab_shugged_shot_effect" ) or {} ) do
		local id_comp = EntityGetFirstComponent( shot_effect_entity, "VariableStorageComponent" )
		if id == ComponentGetValue2( id_comp, "value_string" ) then
			EntityRemoveFromParent( shot_effect_entity )
			EntityKill( shot_effect_entity )
			break
		end
	end
end

local picker = {}
picker.menu = function()
	local count_table = {}
	for _, shot_effect_entity in ipairs( EntityGetAllChildren( player, "spell_lab_shugged_shot_effect" ) or {} ) do
		local id_comp = EntityGetFirstComponent( shot_effect_entity, "VariableStorageComponent" )
		local id = ComponentGetValue2( id_comp, "value_string" )
		count_table[ id ] = ( count_table[ id ] or 0 ) + 1
	end
	GuiLayoutBeginVertical( gui, 640 * 0.05, 360 * 0.16, true )
		do_scroll_table( next_id(), nil, nil, shot_effect_data, function( shot_effect )
			local count = count_table[ shot_effect.id ] or 0
			local max_count = shot_effect.max_count
			local unsafe_count_allowed = mod_setting_get( "shot_effect_unsafe_count_allowed" ) and not shot_effect.no_unsafe
			local max_count_valid = max_count and max_count ~= -1
			local count_shown
			if count == 0 then
				count_shown = nil
			elseif not unsafe_count_allowed and max_count == 1 and count <= 1 then
				count_shown = nil
			else
				count_shown = count
			end
			local source_type_shown = nil
			if shot_effect.source_type then
				source_type_shown = GameTextGet( wrap_key( "shot_effect_source_type" ), GameTextGetTranslatedOrNot( shot_effect.source_type ) )
			end

			local left_click, right_click = do_fake_action_button(
				shot_effect.equivalent_action_type, shot_effect.icon, shot_effect.name, shot_effect.desc,
				source_type_shown, count == 0, count_shown, shot_effect.properties )
			if left_click then
				if not max_count_valid or count < max_count or unsafe_count_allowed then
					add_shot_effect( shot_effect )
				elseif max_count == 1 and count == 1 then
					remove_shot_effect( shot_effect )
				end
			elseif right_click then
				if count > 0 then
					remove_shot_effect( shot_effect )
				end
			end
			if left_click or right_click then
				sound_button_clicked()
			end
		end )
	GuiLayoutEnd( gui )
end

picker.buttons = function()
	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(1,4), percent_to_ui_scale_y(2), true )
		do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/unsafe_values.png", "shot_effect_unsafe_count_allowed" )
	GuiLayoutEnd( gui )
end

return picker