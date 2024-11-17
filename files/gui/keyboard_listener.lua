local LISTENED_KEYS = {
	Key_a,
	Key_b,
	Key_c,
	Key_d,
	Key_e,
	Key_f,
	Key_g,
	Key_h,
	Key_i,
	Key_j,
	Key_k,
	Key_l,
	Key_m,
	Key_n,
	Key_o,
	Key_p,
	Key_q,
	Key_r,
	Key_s,
	Key_t,
	Key_u,
	Key_v,
	Key_w,
	Key_x,
	Key_y,
	Key_z,
	Key_1,
	Key_2,
	Key_3,
	Key_4,
	Key_5,
	Key_6,
	Key_7,
	Key_8,
	Key_9,
	Key_0,
	Key_SPACE,
	Key_MINUS,
	Key_EQUALS,
	Key_LEFTBRACKET,
	Key_RIGHTBRACKET,
	Key_BACKSLASH,
	Key_SLASH,
	Key_SEMICOLON,
	Key_APOSTROPHE,
	Key_GRAVE,
	Key_COMMA,
	Key_PERIOD,
	Key_HOME,
	Key_END,
	Key_BACKSPACE,
	Key_DELETE,
	Key_RIGHT,
	Key_LEFT,
	Key_DOWN,
	Key_UP,
}
local frames_keys_held = {}
for _, key in ipairs( LISTENED_KEYS ) do
	frames_keys_held[ key ] = 0
end

function listen_keyboard()
	local result = {}
	for _, key in ipairs( LISTENED_KEYS ) do
		local current_frames_held = frames_keys_held[ key ]
		if InputIsKeyJustDown( key ) or current_frames_held > 30 then
			result[ key ] = true
		end
		if InputIsKeyDown( key ) then
			frames_keys_held[ key ] = current_frames_held + 1
		else
			frames_keys_held[ key ] = 0
		end
	end
	return result
end