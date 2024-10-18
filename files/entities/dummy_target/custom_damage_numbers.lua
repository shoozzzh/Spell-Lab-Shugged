dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" );
dofile_once( "mods/spell_lab_shugged/files/lib/variables.lua" );
local last_damage_frame = {};
function damage_received( damage, message, entity_thats_responsible, is_fatal )
    local entity = GetUpdatedEntityID();
    if EntityHasNamedVariable( entity, "spell_lab_shugged_always_show_damage_numbers" ) or is_fatal == false then
        local now = GameGetFrameNum();
        if now - ( last_damage_frame[entity] or 0 ) > 180 then
            EntitySetVariableNumber( entity, "spell_lab_shugged_total_damage", 0 );
        end
        last_damage_frame[entity] = now;
        local total_damage = EntityGetVariableNumber( entity, "spell_lab_shugged_total_damage", 0 ) + damage;
        EntitySetVariableNumber( entity, "spell_lab_shugged_total_damage", total_damage );
        local damage_text = thousands_separator( string.format( "%.2f", total_damage * 25 ) );
        EntitySetVariableString( entity, "spell_lab_shugged_custom_damage_numbers_text", damage_text );
    else
        local sprites = EntityGetComponentIncludingDisabled(entity,"SpriteComponent") or {};
        for k,v in pairs( sprites ) do
            if ComponentGetValue2( v, "is_text_sprite" ) then
                EntityRemoveComponent( entity, v );
            end
        end
    end
end