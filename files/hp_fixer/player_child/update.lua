dofile_once "%MOD_PATH%/require.lua"

local tl = require "tinklin"
local var = require "var"

local entity = tl.entity_cur()
local player = entity:get_parent()
if not player then return end

local dm_comp = player:comp_first "DamageModelComponent"
if not dm_comp then return end

local hp, hp_comp_found = var.get(entity.id, "hp", "value_float", dm_comp.hp)
local max_hp, _ = var.get(entity.id, "max_hp", "value_float", dm_comp.max_hp)

-- if not inited
if not hp_comp_found then
    var.write(entity.id, "wait_for_kill_flag_on_death", "value_bool", dm_comp.wait_for_kill_flag_on_death)
    dm_comp.wait_for_kill_flag_on_death = true
end

dm_comp.hp = hp
dm_comp.max_hp = max_hp
