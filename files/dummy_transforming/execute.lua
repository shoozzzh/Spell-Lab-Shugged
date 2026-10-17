dofile_once "%MOD_PATH%/require.lua"

local tl = require "tinklin"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local tr_utils = require "tr_utils"

---@return bool
---@return string|entity
local function try_find_target()
    local mouse_pos = tl.vec(DEBUG_GetMouseWorld())

    local target = tl.entity_closest(mouse_pos, "mortal")

    if not target or (target.pos - mouse_pos):norm2() > 1600 then
        target = tl.entity_closest(mouse_pos, "enemy")
        if not target or (target.pos - mouse_pos):norm2() > 1600 then
            return false, module_tr.err.no_target:text()
        end
    end

    if target.tag.player_unit or target.tag.polymorphed_player then
        return false, module_tr.err.cant_transform_player:text()
    end

    if target.tag.spell_lab_shugged_target_dummy then
        return false, module_tr.err.already_transformed:text()
    end

    return true, target
end

local found, res = try_find_target()
if not found then
    --[[@cast res string]]
    GamePrint(res)
    return
end

--[[@cast res entity]]
local target = res

-- GameDropAllItems( mortal_id )
local comp_names_to_disable = {
    "AnimalAIComponent",
    "PhysicsAIComponent",
    "FishAIComponent",
    "AdvancedFishAIComponent",
    "BossDragonComponent",
    "WormComponent",
    "WormAIComponent",
    "BossHealthBarComponent",
    "CameraBoundComponent",
}
tl.fun.iter(comp_names_to_disable):each(function(comp_name)
    target:comps_enabled(comp_name):each(function(comp)
        comp.meta.enabled = false
    end)
end)

target:comps "ControlsComponent":each(function(comp) comp.enabled = false end)

local cp_comp = target:comp_first "CharacterPlatformingComponent"
if cp_comp then
    for _, field_name in ipairs {
        "velocity_min_x",
        "velocity_min_y",
        "velocity_max_x",
        "velocity_max_y",
        "pixel_gravity",
        "run_velocity",
        "fly_velocity_x",
        "fly_speed_up",
        "fly_speed_down",
    } do
        cp_comp[field_name] = 0
    end
end

local cd_comp = target:comp_first "CharacterDataComponent"
if cd_comp then
    cd_comp.mVelocity = tl.vec(0, 0)
end

for _, pbody_id in ipairs(PhysicsBodyIDGetFromEntity(target.id)) do
    PhysicsBodyIDSetGravityScale(pbody_id, 0)
    local x, y, a = PhysicsBodyIDGetTransform(pbody_id)
    PhysicsBodyIDSetTransform(pbody_id, x, y, a, 0, 0)
end

local dm_comp = target:comp_first "DamageModelComponent"
if dm_comp then
    dm_comp.wait_for_kill_flag_on_death = true
end
dm_comp = target:comp_first_enabled "DamageModelComponent"
if dm_comp then
    dm_comp.wait_for_kill_flag_on_death = true
end

target:comp_new "LuaComponent" {
    _tags = "enabled_in_world",
    script_source_file = "%MODULE_PATH%/transformed_mortal_update.lua",
    execute_every_n_frame = 1,
}

target:load_extra_entity "%MOD_PATH%/files/dummy_target/base_dummy_target.xml"
target.tag.spell_lab_shugged_target_dummy = true

GamePrint(module_tr.done:text(tr_utils.maybe(target.name)))
