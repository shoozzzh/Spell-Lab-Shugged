dofile_once "data/scripts/lib/utilities.lua"
dofile_once "data/scripts/debug/keycodes.lua"

local mod_path = "mods/%%%/"

local mod_setting = dofile_once(mod_path .. "files/mod_setting.lua")
local tl = dofile_once(mod_path .. "libs/tinklin/main.lua")

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

local speed = mod_setting.get_or_default("creative_mode_flight_speed_normal", 200)

local ctrl = InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL)
local shift = InputIsKeyDown(Key_LSHIFT) or InputIsKeyDown(Key_RSHIFT)
if ctrl then
	speed = mod_setting.get_or_default("creative_mode_flight_speed_faster", 450)
end

if shift then
	local dist = mod_setting.get_or_default("creative_mode_flight_speed_no_clip", 300) / 60
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
	local vel_desired = tl.npair.new_vector(vel[x], 0)
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
