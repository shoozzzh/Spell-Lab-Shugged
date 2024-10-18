dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" );
dofile_once( "mods/spell_lab_shugged/files/lib/variables.lua" );
last_text = last_text or "";
local entity = GetUpdatedEntityID();
local current_target = EntityGetParent( entity );
local current_text = EntityGetVariableString( current_target, "spell_lab_shugged_custom_damage_numbers_text", "" );
if current_target ~= 0 and last_text ~= current_text then
    last_text = current_text;
    local height = 20;
    local sprite = EntityGetFirstComponent( entity, "SpriteComponent", "spell_lab_shugged_custom_damage_number" );
    if sprite then
        ComponentSetValue2( sprite, "offset_x", #current_text * 2 - 2 );
        ComponentSetValue2( sprite, "offset_y", height * 2 + 12 );
        ComponentSetValue2( sprite, "text", current_text );
        EntityRefreshSprite( entity, sprite );
    end
end