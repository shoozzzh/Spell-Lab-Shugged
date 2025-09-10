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

return { raw, by_type }