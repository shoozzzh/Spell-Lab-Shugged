local x, y = 14600, -6000

local player_close = EntityGetInRadiusWithTag(x, y, 400, "player_unit")
local cam_x, cam_y = GameGetCameraPos()
local camera_close = (cam_x - x) ^ 2 + (cam_y - y) ^ 2 < 400 ^ 2
if not player_close and not camera_close then return end

LoadPixelScene("%MODULE_PATH%/materials.png", "", 14600 - 640, -6000 - 360, "%MODULE_PATH%/bg.png", true, false,
    nil, -100, true)
EntityLoad("%MOD_PATH%/files/terrain_spell_lab/reloader.xml", x, y)
EntityLoad("%MOD_PATH%/files/target_dummy/entity/entity.xml", x - 100, y)
EntityLoad("%MOD_PATH%/files/target_dummy/entity/entity_final.xml", x + 100, y)
EntityLoad("data/entities/buildings/workshop_spell_visualizer.xml", x - 78, y - 50)
EntityLoad("data/entities/buildings/workshop_aabb.xml", x - 78, y - 50)

local flag_terrain_init = "%MODULE_FULL_ID%.init"
GameAddFlagRun(flag_terrain_init)

local wsv = EntityGetInRadiusWithTag(x - 78, y - 50, 6, "workshop_spell_visualizer")
for i = 1, #wsv - 1 do
    EntityKill(wsv[i])
end
local wsaabb = EntityGetInRadiusWithTag(x - 78, y - 50, 6, "workshop_aabb")
for i = 1, #wsaabb - 1 do
    EntityKill(wsaabb[i])
end
local reloader = EntityGetInRadiusWithTag(x, y, 6, "%MOD_ID%.lab_reloader")
for i = 1, #reloader - 1 do
    EntityKill(reloader[i])
end
local dummy_left = EntityGetInRadiusWithTag(x - 100, y, 6, "%MOD_ID%.target_dummy")
for i = 1, #dummy_left - 1 do
    EntityKill(dummy_left[i])
end
local dummy_right = EntityGetInRadiusWithTag(x + 100, y, 6, "%MOD_ID%.target_dummy")
for i = 1, #dummy_right - 1 do
    EntityKill(dummy_right[i])
end

EntityAddComponent2(GetUpdatedEntityID(), "LifetimeComponent", {
    lifetime = 1,
})

-- EntityKill( GetUpdatedEntityID() )
