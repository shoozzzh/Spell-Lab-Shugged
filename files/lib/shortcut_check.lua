local shortcut_check = {}

local cache = {}

local xor = function( a, b ) return ( a and not b ) or ( not a and b ) end

function shortcut_check.check_input( keyboard_input, shortcut, left_click, right_click, dont_cache )
	if #shortcut == 0 then return false end
	local inverted_shortcut = cache[ shortcut ]
	if inverted_shortcut == nil then
		inverted_shortcut = {}
		for _, keyname in ipairs( shortcut ) do
			inverted_shortcut[ keyname ] = true
		end
		if not dont_cache then
			cache[ shortcut ] = inverted_shortcut
		end
	end

	for keyname, status in pairs( keyboard_input ) do
		if shortcut_used_keys == nil or shortcut_used_keys[ keyname ] then
			if xor( status, inverted_shortcut[ keyname ] ) then return false end
		end
	end
	if left_click ~= nil or right_click ~= nil then
		if xor( left_click, inverted_shortcut.Mouse_left ) then return false end
		if xor( right_click, inverted_shortcut.Mouse_right ) then return false end
	end
	return true
end

function shortcut_check.check( ... )
	return shortcut_check.check_input( keyboard_input_holding, ... )
end

return shortcut_check