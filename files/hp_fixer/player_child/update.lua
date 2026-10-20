dofile_once "%MOD_PATH%/require.lua"

local tl = require "tinklin"
local var = require "var"

local entity = tl.entity_cur()
local player = entity:get_parent()
if not player then return end

local dm_comp = player:comp_first "DamageModelComponent"
if not dm_comp then return end

local var_map = {
    hp = "value_float",
    max_hp = "value_float",
    wait_for_kill_flag_on_death = "value_bool",
}

local vars = var.access(entity.id, var_map, "") --[[@as hp_fixer_vars]]

dm_comp.hp = vars.hp
dm_comp.max_hp = vars.max_hp
