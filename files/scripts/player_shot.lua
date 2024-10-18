last_second = last_second or math.floor( GameGetFrameNum() / 60 ) * 60;
projectiles_this_second = projectiles_this_second or 0;
function shot( projectile_entity )
    local entity = GetUpdatedEntityID();
    local current_frame = GameGetFrameNum();
    local current_second = math.floor( current_frame / 60 ) * 60;
    if current_second > last_second then
        last_second = current_second;
        projectiles_this_second = 0;
    end
    projectiles_this_second = projectiles_this_second + 1;
    GlobalsSetValue( "spell_lab_shugged_projectiles_per_second", tostring( projectiles_this_second ) );
    -- EntityAddTag( projectile_entity, "projectile_player" );
end