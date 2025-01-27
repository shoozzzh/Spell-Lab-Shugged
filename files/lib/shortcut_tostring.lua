local special_chars = {
	MINUS = "-",
	EQUALS = "=",
	LEFTBRACKET = "[",
	RIGHTBRACKET = "]",
	BACKSLASH = "\\",
	NONUSHASH = "#",
	SEMICOLON = ";",
	APOSTROPHE = "'",
	GRAVE = "`",
	COMMA = ",",
	PERIOD = ".",
	SLASH = "/",
	NUMLOCKCLEAR = "NUMLOCK",
	KP_DIVIDE = "/",
	KP_MULTIPLY = "*",
	KP_MINUS = "-",
	KP_PLUS = "+",
	KP_PERIOD = ".",
	NONUSBACKSLASH = "\\",
	APPLICATION = "MENU",
	POWER = "SHUTDOWN",
	KP_EQUALS = "=",
	KP_COMMA = ",",
	KP_EQUALSAS400 = "=",
	KP_LEFTPAREN = "(",
	KP_RIGHTPAREN = ")",
	KP_LEFTBRACE = "{",
	KP_RIGHTBRACE = "}",
	KP_XOR = "^",
	KP_POWER = "SHUTDOWN",
	KP_PERCENT = "%",
	KP_LESS = "<",
	KP_GREATER = ">",
	KP_AMPERSAND = "&",
	KP_DBLAMPERSAND = "&&",
	KP_VERTICALBAR = "|",
	KP_DBLVERTICALBAR = "||",
	KP_COLON = ":",
	KP_HASH = "#",
	KP_AT = "@",
	KP_EXCLAM = "!",
	KP_PLUSMINUS = "+-",
	LGUI = "LEFT WINDOWS",
	RGUI = "RIGHT WINDOWS",
}

local named_keys = {
	Key_CTRL = "Ctrl",
	Key_SHIFT = "Shift",
	Key_ALT = "Alt",
	JOY_BUTTON_0 = "$input_xboxbutton_a",
	JOY_BUTTON_1 = "$input_xboxbutton_b",
	JOY_BUTTON_2 = "$input_xboxbutton_x",
	JOY_BUTTON_3 = "$input_xboxbutton_y",
}

local custom_keys_i18n = {
	["简体中文"] = {
		Mouse_left = "左键",
		Mouse_right = "右键",
	},
	DEFAULT = {
		Mouse_left = "Left-click",
		Mouse_right = "Right-click",
	},
}

do
	local other_zh_cn_languages = { "喵体中文", "汪体中文", "完全汉化" }
	for _, v in ipairs( other_zh_cn_languages ) do
		custom_keys_i18n[ v ] = custom_keys_i18n["简体中文"]
	end
end

local function keyname_to_text( keyname, lang )
	local result = named_keys[ keyname ]
	if result then return result end

	local i18n = custom_keys_i18n[ lang ] or custom_keys_i18n.DEFAULT
	result = i18n[ keyname ]
	if result then return result end

	if keyname:find "^Mouse_" then
		return GameTextGet( "$input_" .. keyname:gsub( "_", "" ):lower() ):upper()
	elseif keyname:find "^Key_"  then
		local name = keyname:sub(5):upper()

		result = special_chars[ name ]
		if result then return result end

		local did = 0
		result, did = name:gsub( "^KP_", "KEYPAD " )
		if did > 0 then return result end
		result, did = name:gsub( "^AC_", "AC " )
		if did > 0 then return result end

		return name
	elseif keyname:find "^JOY_BUTTON_" then
		local result = GameTextGet( "$input_xboxbutton_" .. keyname:sub(12):lower() )
		if keyname:find "%d%d_DOWN$" then
			result = result .. " DOWN"
		elseif keyname:find "%d%d_MOVED$" then
			result = result .. " MOVED"
		end
	end
	return GameTextGet( "$menuoptions_configurecontrols_keyname_unknown" )
end

local order = {
	Key_CTRL = -100,
	Key_ALT = -99,
	Key_SHIFT = -98,
	DEFAULT = 0,
	Mouse_left = 99,
	Mouse_right = 100,
}
local function shortcut_sort( shortcut )
	table.sort( shortcut, function( a, b )
		local order_a = order[ a ] or order.DEFAULT
		local order_b = order[ b ] or order.DEFAULT
		if order_a ~= order_b then return order_a < order_b end

		local len_a = #a
		local len_b = #b
		if len_a ~= len_b then return len_a > len_b end

		return a < b
	end )
end

function shortcut_tostring( shortcut, lang )
	local copy = {}
	for k, v in pairs( shortcut ) do
		copy[ k ] = v
	end
	shortcut_sort( copy )

	local strs_to_concat = {}
	for _, key in ipairs( copy ) do
		strs_to_concat[ #strs_to_concat + 1 ] = keyname_to_text( key, lang )
	end
	return table.concat( strs_to_concat, " + " )
end