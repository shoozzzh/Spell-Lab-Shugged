local _, keycodes_by_type = unpack( dofile_once( "mods/spell_lab_shugged/files/lib/keycodes_wrapped.lua" ) )

local keystroke_listener = {}

local listeners = {}

for k, v in pairs( keycodes_by_type.Keyboard ) do
	listeners[ k ] = {
		function() return InputIsKeyDown( v ) end,
		function() return InputIsKeyJustDown( v ) end,
	}
end

for k, v in pairs( keycodes_by_type.Mouse ) do
	if k == "Mouse_left" or k == "Mouse_right" then goto continue end

	listeners[ k ] = {
		function() return InputIsMouseButtonDown( v ) end,
		function() return InputIsMouseButtonJustDown( v ) end,
	}

	::continue::
end

do
	local combined_keys = {
		Key_ALT = { "Key_LALT", "Key_RALT" },
		Key_CTRL = { "Key_LCTRL", "Key_RCTRL" },
		Key_SHIFT = { "Key_LSHIFT", "Key_RSHIFT" },
	}

	local any_of = function( functions )
		return function()
			for _, f in ipairs( functions ) do
				if f() then return true end
			end
		end
	end

	for combined, from_these_keys in pairs( combined_keys ) do
		local down_listeners, just_down_listeners = {}, {}

		for _, key in ipairs( from_these_keys ) do
			local down_listener, just_down_listener = unpack( listeners[ key ] )
			down_listeners[ #down_listeners + 1 ] = down_listener
			just_down_listeners[ #just_down_listeners + 1 ] = just_down_listener

			listeners[ key ] = nil
		end

		listeners[ combined ] = { any_of( down_listeners ), any_of( just_down_listeners ) }
	end
end

local joysticks_connected = {}

local ignored_joystick_keys = {
	JOY_BUTTON_A = true,
	JOY_BUTTON_B = true,
	JOY_BUTTON_LEFT_STICK_LEFT = true,
	JOY_BUTTON_LEFT_STICK_RIGHT = true,
	JOY_BUTTON_LEFT_STICK_UP = true,
	JOY_BUTTON_LEFT_STICK_DOWN = true,
}

for name, code in pairs( keycodes_by_type.Joystick ) do
	if ignored_joystick_keys[ name ] then
		goto continue
	end

	local down_listener = function()
		for index = 0,7 do
			if joysticks_connected[ index ] and InputIsJoystickButtonDown( index, code ) then
				return true
			end
		end
		return false
	end

	listeners[ name ] = { down_listener, nil }

	::continue::
end

do
	local listened_keys = {}
	
	for key, _ in pairs( listeners ) do
		listened_keys[ #listened_keys + 1 ] = key
	end

	for key, _ in ipairs( keycodes_by_type.Joystick ) do
		listened_keys[ #listened_keys + 1 ] = key
	end
	
	keystroke_listener.listened_keys = listened_keys
end

local frames_keys_held = {}
for key, _ in pairs( listeners ) do
	frames_keys_held[ key ] = 0
end

keystroke_listener.just_down = {}
keystroke_listener.down = {}

function keystroke_listener:update()
	local just_down = self.just_down
	local down = self.down

	for i = 0,7 do
		joysticks_connected[ i ] = InputIsJoystickConnected( i )
	end

	for name, pair in pairs( listeners ) do
		local down_listener, just_down_listener = unpack( pair )

		local current_frames_held = frames_keys_held[ name ]

		local down_now = down_listener()

		if just_down_listener then
			just_down[ name ] = just_down_listener()
		else
			just_down[ name ] = not down[ name ] and down_now
		end

		if current_frames_held > 30 then
			just_down[ name ] = true
		end
		
		down[ name ] = down_now

		if down[ name ] then
			frames_keys_held[ name ] = current_frames_held + 1
		else
			frames_keys_held[ name ] = 0
		end
	end
end

return keystroke_listener