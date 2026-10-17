local utils = dofile_once "%THIS_FOLDER%/utils.lua"

function damage_received(damage, message, entity_thats_responsible, is_fatal)
    local entity_id = GetUpdatedEntityID()
    local now = GameGetFrameNum()

    local vars = utils.access_vars(entity_id)

    local damage_model = EntityGetFirstComponent(entity_id, "DamageModelComponent")
    if damage_model then
        ComponentSetValue2(damage_model, "max_hp", 4)
        ComponentSetValue2(damage_model, "hp", math.max(4, damage * 1.1))
    end

    local last_hit_frame = vars.last_hit_frame
    vars.last_hit_frame = now
    local reset = (now - last_hit_frame > 180)

    local first_hit_frame
    if reset then
        vars.first_hit_frame = now
        first_hit_frame = now
    else
        first_hit_frame = vars.first_hit_frame
    end

    vars.current_dps = vars.current_dps + damage

    if vars.current_dps > (reset and 0 or vars.highest_dps) then
        vars.highest_dps = vars.current_dps
    end

    vars.total_damage = (reset and 0 or vars.total_damage) + damage

    local average_dps = vars.total_damage / (now - first_hit_frame + 1) * 60

    vars.last_frame_damage = (last_hit_frame == now and vars.last_frame_damage or 0) + damage

    local child_id = EntityGetAllChildren(entity_id, "%MOD_ID%.target_dummy_child")[1]
    if not EntityGetIsAlive(child_id) then return end

    utils.set_text(child_id, "total_damage", vars.total_damage)
    utils.set_text(child_id, "average_dps", average_dps)
    utils.set_text(child_id, "last_frame_damage", vars.last_frame_damage)

    EntitySetComponentsWithTagEnabled(child_id, "invincible", true)
end
