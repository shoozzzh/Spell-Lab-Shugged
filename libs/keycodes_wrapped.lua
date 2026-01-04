local f = loadfile( "data/scripts/debug/keycodes.lua" )
local raw = {}
setfenv( f, raw )()

local by_type = { Mouse = {}, Keyboard = {}, Joystick = {} }
for k, v in pairs( raw ) do
	if k:find "^Mouse_" then
		by_type.Mouse[ k ] = v
	elseif k:find "^Key_" then
		by_type.Keyboard[ k ] = v
	elseif k:find "^JOY_BUTTON_" then
		by_type.Joystick[ k ] = v
	end
end

local excluded_keys = { "JOY_BUTTON_0", "JOY_BUTTON_1", "JOY_BUTTON_2", "JOY_BUTTON_3" }

for _, t in ipairs( { raw, by_type.Mouse, by_type.Keyboard, by_type.Joystick } ) do
	for _, key in ipairs( excluded_keys ) do
		t[ key ] = nil
	end
end

return { raw, by_type }