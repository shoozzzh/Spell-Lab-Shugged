local x, y = 14600, -6000
local wsv = EntityGetInRadiusWithTag( x - 78, y - 50, 6, "workshop_spell_visualizer" )
for i = 1, #wsv - 1 do
	EntityKill( wsv[ i ] )
end
local wsaabb = EntityGetInRadiusWithTag( x - 78, y - 50, 6, "workshop_aabb" )
for i = 1, #wsaabb - 1 do
	EntityKill( wsaabb[ i ] )
end
local reloader = EntityGetInRadiusWithTag( x, y, 6, "spell_lab_shugged_lab_reloader" )
for i = 1, #reloader - 1 do
	EntityKill( reloader[ i ] )
end
local dummy_left = EntityGetInRadiusWithTag( x - 100, y, 6, "spell_lab_shugged_target_dummy" )
for i = 1, #dummy_left - 1 do
	EntityKill( dummy_left[ i ] )
end
local dummy_right = EntityGetInRadiusWithTag( x + 100, y, 6, "spell_lab_shugged_target_dummy" )
for i = 1, #dummy_right - 1 do
	EntityKill( dummy_right[ i ] )
end