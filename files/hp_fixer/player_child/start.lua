dofile_once "%MOD_PATH%/require.lua"

local tl = require "tinklin"
local var = require "var"

local entity = tl.entity_cur()
local player = entity:get_parent()
if not player then
    entity:kill()
    return
end

local dm_comp = player:comp_first "DamageModelComponent"
if not dm_comp then
    entity:kill()
    return
end

local var_map = {
    hp = "value_float",
    max_hp = "value_float",
    wait_for_kill_flag_on_death = "value_bool",
}

local vars = var.access(entity.id, var_map, "") --[[@as hp_fixer_vars]]

vars.hp = dm_comp.hp
vars.max_hp = dm_comp.max_hp
vars.wait_for_kill_flag_on_death = dm_comp.wait_for_kill_flag_on_death

dm_comp.wait_for_kill_flag_on_death = true

entity:comps "LuaComponent":each(function(comp)
    comp.meta.enabled = true
end)
