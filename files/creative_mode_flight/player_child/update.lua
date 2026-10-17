dofile_once "%MOD_PATH%/require.lua"

local settings = require "mod_setting"
local tl = require "tinklin"

---@type table<string, integer>
local keycodes = (function()
    local f = loadfile "data/scripts/debug/keycodes.lua"
    local raw = {}
    setfenv(f, raw)()
    return raw
end)()

local player = tl.entity_cur()

local lerp_speed = 0.60

local cd_comp = player:comp_first_enabled "CharacterDataComponent"
local ctrl_comp = player:comp_first_enabled "ControlsComponent"
if not cd_comp or not ctrl_comp then return end

local up, down, left, right = unpack {
    ctrl_comp.mButtonDownUp,
    ctrl_comp.mButtonDownDown,
    ctrl_comp.mButtonDownLeft,
    ctrl_comp.mButtonDownRight,
}

local speed = settings.get_or_default("creative_mode_flight.speed_normal", 200)

local ctrl = InputIsKeyDown(keycodes.Key_LCTRL) or InputIsKeyDown(keycodes.Key_RCTRL)
local shift = InputIsKeyDown(keycodes.Key_LSHIFT) or InputIsKeyDown(keycodes.Key_RSHIFT)
if ctrl then
    speed = settings.get_or_default("creative_mode_flight.speed_faster", 450)
end

if shift then
    local dist = settings.get_or_default("creative_mode_flight.speed_no_clip", 300) / 60
    local pos = player.pos

    if up and down then
        cd_comp.is_on_ground = true
    elseif up then
        pos[2] = pos[2] - dist
    elseif down then
        pos[2] = pos[2] + dist
    end
    if left and right then
    elseif left then
        pos[1] = pos[1] - dist
    elseif right then
        pos[1] = pos[1] + dist
    end
    player.pos = pos
    player:apply_xform()
    speed = 0
else
    local vel = cd_comp.mVelocity
    local vel_desired = tl.vec(vel[1], 0)
    if up and down then
        cd_comp.is_on_ground = true
    elseif up then
        vel_desired[2] = vel_desired[2] - speed
    elseif down then
        vel_desired[2] = vel_desired[2] + speed
    end
    cd_comp.mVelocity = vel:lerp(vel_desired, lerp_speed)
end

local cp_comp = player:comp_first_enabled "CharacterPlatformingComponent"
if cp_comp then
    cp_comp.pixel_gravity = 0
    cp_comp.velocity_max_x = speed
    cp_comp.velocity_max_y = speed
    cp_comp.velocity_min_x = -speed
    cp_comp.velocity_min_y = -speed
    cp_comp.run_velocity = speed
    cp_comp.fly_velocity_x = speed
    cp_comp.fly_speed_max_up = speed
    cp_comp.fly_speed_max_down = speed
end

cd_comp.mFlyingTimeLeft = cd_comp.fly_time_max

local dm_comp = player:comp_first_enabled "DamageModelComponent"
if dm_comp then
    dm_comp.air_in_lungs = dm_comp.air_in_lungs_max
end
