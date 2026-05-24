dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/debug/keycodes.lua")

local entity_id = GetUpdatedEntityID()

local lerp_speed = 0.60

local cp_comp = EntityGetFirstComponent( entity_id, "CharacterPlatformingComponent" )
local cd_comp = EntityGetFirstComponent( entity_id, "CharacterDataComponent" )

local speed = tonumber( ModSettingGet( "spell_lab_shugged.creative_mode_flight_speed_normal" ) ) or 200

local ctrl = InputIsKeyDown( Key_LCTRL ) or InputIsKeyDown( Key_RCTRL )
local shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
if ctrl then
	speed = tonumber( ModSettingGet( "spell_lab_shugged.creative_mode_flight_speed_faster" ) ) or 450
end
if shift then
	local dist = ( tonumber( ModSettingGet( "spell_lab_shugged.creative_mode_flight_speed_no_clip" ) ) or 300 ) / 60
	component_read( EntityGetFirstComponent( entity_id, "ControlsComponent" ),
		{ mButtonDownDown = false, mButtonDownUp = false, mButtonDownLeft = false, mButtonDownRight = false }, function( controls_comp )
		local x, y = EntityGetTransform( entity_id )
		if controls_comp.mButtonDownDown and controls_comp.mButtonDownUp then
			ComponentSetValue2( cd_comp, "is_on_ground", true )
		elseif controls_comp.mButtonDownDown then
			y = y + dist
		elseif controls_comp.mButtonDownUp then
			y = y - dist
		end
		if controls_comp.mButtonDownLeft and controls_comp.mButtonDownRight then
		elseif controls_comp.mButtonDownLeft then
			x = x - dist
		elseif controls_comp.mButtonDownRight then
			x = x + dist
		end
		EntityApplyTransform( entity_id, x, y )
	end )
	speed = 0
else
	component_read( EntityGetFirstComponent( entity_id, "ControlsComponent" ),
		{ mButtonDownDown = false, mButtonDownUp = false }, function( controls_comp )
		if not cd_comp then return end
		local vx, vy = ComponentGetValue2( cd_comp, "mVelocity" )
		local desired_vy = 0
		if controls_comp.mButtonDownUp and controls_comp.mButtonDownDown then
			ComponentSetValue2( cd_comp, "is_on_ground", true )
		elseif controls_comp.mButtonDownDown then
			desired_vy = desired_vy + speed
		elseif controls_comp.mButtonDownUp then
			desired_vy = desired_vy - speed
		end
		ComponentSetValue2( cd_comp, "mVelocity", vx, lerp( vy, desired_vy, lerp_speed ) )
	end )
end
if cd_comp then
	ComponentSetValue2( cd_comp, "mFlyingTimeLeft", ComponentGetValue2( cd_comp, "fly_time_max" ) )
end
if cp_comp then
	ComponentSetValue2( cp_comp, "pixel_gravity", 0 )
	ComponentSetValue2( cp_comp, "velocity_max_x", speed )
	ComponentSetValue2( cp_comp, "velocity_max_y", speed )
	ComponentSetValue2( cp_comp, "velocity_min_x", -speed )
	ComponentSetValue2( cp_comp, "velocity_min_y", -speed )
	ComponentSetValue2( cp_comp, "run_velocity", speed )
	ComponentSetValue2( cp_comp, "fly_velocity_x", speed )
	ComponentSetValue2( cp_comp, "fly_speed_max_up", speed )
	ComponentSetValue2( cp_comp, "fly_speed_max_down", speed )
end
local dm_comp = EntityGetFirstComponent( entity_id, "DamageModelComponent" )
if dm_comp then
	local air_in_lungs_max = ComponentGetValue2( dm_comp, "air_in_lungs_max" )
	ComponentSetValue2( dm_comp, "air_in_lungs", air_in_lungs_max )
end