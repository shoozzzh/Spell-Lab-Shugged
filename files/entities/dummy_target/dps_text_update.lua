dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" )

local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent( entity_id )

chinese_languages = {
	["简体中文"] = true,
	["喵体中文"] = true,
	["汪体中文"] = true,
	["完全汉化"] = true,
}
local separator_func = chinese_languages[ GameTextGetTranslatedOrNot( "$current_language" ) ] and ten_thousands_separator or thousands_separator
local dps_comp = get_variable_storage_component( parent_id, "spell_lab_shugged_current_dps" )
local dps = ComponentGetValue2( dps_comp, "value_float" )
ComponentSetValue2( dps_comp, "value_float", 0 )
local sprite_comp = EntityGetFirstComponent( entity_id, "SpriteComponent", "spell_lab_shugged_dps" )
if sprite_comp then
	local text, num_separators = separator_func( string.format( "%.2f", dps * 25 ) )
	ComponentSetValue2( sprite_comp, "offset_x", #text * 2 - 0.5 - num_separators )
	ComponentSetValue2( sprite_comp, "text", text )
	EntityRefreshSprite( entity_id, sprite_comp )
end

local highest_dps_comp = get_variable_storage_component( parent_id, "spell_lab_shugged_highest_dps" )
local highest_dps = ComponentGetValue2( highest_dps_comp, "value_float" )
local sprite_comp = EntityGetFirstComponent( entity_id, "SpriteComponent", "spell_lab_shugged_highest_dps" )
if sprite_comp then
	local text, num_separators = separator_func( string.format( "%.2f", highest_dps * 25 ) )
	ComponentSetValue2( sprite_comp, "offset_x", #text * 2 - 0.5 - num_separators )
	ComponentSetValue2( sprite_comp, "text", text )
	EntityRefreshSprite( entity_id, sprite_comp )
end

-- EntitySetComponentIsEnabled( entity_id, GetUpdatedComponentID(), false )