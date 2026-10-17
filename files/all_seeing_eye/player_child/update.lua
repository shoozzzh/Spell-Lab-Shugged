dofile_once "%MOD_PATH%/require.lua"
local tl = require "tinklin"
local settings = require "mod_settings"

local entity = tl.entity_cur()

entity:comp_first "LightComponent".mAlpha = settings.get_or_default("all_seeing_eye.brightening", 1)
entity:comp_first "SpriteComponent".alpha = settings.get_or_default("all_seeing_eye.fog_of_war_removing", 1)
