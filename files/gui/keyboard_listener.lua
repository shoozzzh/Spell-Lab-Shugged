local listened_keys = {}
do
	KEYCODES_RAW, KEYCODES_BY_TYPE = unpack( dofile_once( "mods/spell_lab_shugged/files/lib/keycodes_wrapped.lua" ) )

	local is_joystick_key_down = function( ... ) return InputIsJoystickButtonDown( 0, ... ) end
	local is_joystick_key_just_down = function( ... ) return InputIsJoystickButtonJustDown( 0, ... ) end

	for k, v in pairs( KEYCODES_BY_TYPE.Keyboard ) do
		listened_keys[ k ] = { v, InputIsKeyDown, InputIsKeyJustDown }
	end
	for k, v in pairs( KEYCODES_BY_TYPE.Joystick ) do
		listened_keys[ k ] = { v, is_joystick_key_down, is_joystick_key_just_down }
	end

	listened_keys.Key_LCTRL = nil
	listened_keys.Key_RCTRL = nil
	listened_keys.Key_LSHIFT = nil
	listened_keys.Key_RSHIFT = nil
	listened_keys.Key_LALT = nil
	listened_keys.Key_RALT = nil

	listened_keys.Key_CTRL = { nil,
		function() return InputIsKeyDown( KEYCODES_RAW.Key_LCTRL ) or InputIsKeyDown( KEYCODES_RAW.Key_RCTRL ) end,
		function() return InputIsKeyJustDown( KEYCODES_RAW.Key_LCTRL ) or InputIsKeyJustDown( KEYCODES_RAW.Key_RCTRL ) end,
	}
	listened_keys.Key_SHIFT = { nil,
		function() return InputIsKeyDown( KEYCODES_RAW.Key_LSHIFT ) or InputIsKeyDown( KEYCODES_RAW.Key_RSHIFT ) end,
		function() return InputIsKeyJustDown( KEYCODES_RAW.Key_LSHIFT ) or InputIsKeyJustDown( KEYCODES_RAW.Key_RSHIFT ) end,
	}
	listened_keys.Key_ALT = { nil,
		function() return InputIsKeyDown( KEYCODES_RAW.Key_LALT ) or InputIsKeyDown( KEYCODES_RAW.Key_RALT ) end,
		function() return InputIsKeyJustDown( KEYCODES_RAW.Key_LALT ) or InputIsKeyJustDown( KEYCODES_RAW.Key_RALT ) end,
	}

end

local frames_keys_held = {}
for keyname, _ in pairs( listened_keys ) do
	frames_keys_held[ keyname ] = 0
end

local listen_result_just_down = {}
function listen_keyboard_just_down()
	for name, tri in pairs( listened_keys ) do
		local code = tri[1]

		local current_frames_held = frames_keys_held[ name ]
		if tri[3]( code ) or current_frames_held > 30 then
			listen_result_just_down[ name ] = true
		end
		if tri[2]( code ) then
			frames_keys_held[ name ] = current_frames_held + 1
		else
			frames_keys_held[ name ] = 0
		end
	end
	return listen_result_just_down
end

local listen_result_down = {}
function listen_keyboard_down()
	for name, tri in pairs( listened_keys ) do
		listen_result_down[ name ] = tri[2]( tri[1] )
	end
	return listen_result_down
end