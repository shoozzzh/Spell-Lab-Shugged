---@type player_opt
local player_option = {}

local module_path = module_path()

player_option.mod_setting_key = module_name()

local player_child_name = mod_id .. ".creative_mode_flight.player_child"

function player_option.value_initiator()
    return tl.entity_with_name(player_child_name) ~= nil
end

---@type CharacterPlatformingComponent.set
local flight_overwritten_fields = {
    run_velocity = 200,
    fly_velocity_x = 200,
    fly_speed_max_up = 200,
    fly_speed_max_down = 200,
    velocity_max_x = 200,
    velocity_max_y = 200,
    velocity_min_x = -200,
    velocity_min_y = -200,
    pixel_gravity = 0,
    swim_idle_buoyancy_coeff = 0,
    swim_down_buoyancy_coeff = 0,
    swim_up_buoyancy_coeff = 0,
    fly_speed_change_spd = 0,
    swim_drag = 1,
    swim_extra_horizontal_drag = 1,
}

function player_option.on_enable(player_id)
    local player = tl.entity_wrap(player_id)
    local player_child = tl.entity_load(module_path .. "player_child/entity.xml")
    player_child.name = player_child_name
    EntityAddChild(player_id, player_child.id)

    local cp_comp = player:comp_first "CharacterPlatformingComponent"
    if not cp_comp then return end

    local values_comp = player_child:comp_first "CharacterPlatformingComponent"
    for field_name, value in pairs(flight_overwritten_fields) do
        values_comp[field_name] = cp_comp[field_name]
        cp_comp[field_name] = value
    end
end

function player_option.on_disable(player_id)
    local player = tl.entity_wrap(player_id)
    local player_child = tl.entity_with_name(player_child_name)
    if not player_child then return end

    player_child:comp_new "LifetimeComponent" { lifetime = 1 }

    local cp_comp = player:comp_first "CharacterPlatformingComponent"
    if not cp_comp then return end

    local values_comp = player_child:comp_first "CharacterPlatformingComponent"
    if not values_comp then return end

    for _, field_name in ipairs(flight_overwritten_fields) do
        cp_comp[field_name] = values_comp[field_name]
    end
end

return player_option
