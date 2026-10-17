dofile_once "%MOD_PATH%/require.lua"

local tl = require "tinklin"
local var = require "var"

local entity = tl.entity_cur()
local player = entity:get_parent()
if not player then return end

local dm_comp = player:comp_first "DamageModelComponent"
if not dm_comp then return end

dm_comp.wait_for_kill_flag_on_death = var.get(entity.id, "wait_for_kill_flag_on_death", "value_bool", false)
