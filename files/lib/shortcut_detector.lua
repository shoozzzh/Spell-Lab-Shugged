return function( keystroke_listener )
	local shortcut_detector = {}
	
	local cache = {}
	
	local xor = function( a, b ) return ( a and not b ) or ( not a and b ) end

	local function get_inverted( shortcut, dont_cache )
		local inverted = cache[ shortcut ]
		if inverted == nil then
			inverted = {}
			if type( shortcut ) == "table" then
				for _, key in ipairs( shortcut ) do
					inverted[ key ] = true
				end
			elseif type( shortcut ) == "string" then
				inverted[ shortcut ] = true
			end
			if not dont_cache then
				cache[ shortcut ] = inverted
			end
		end
		return inverted
	end
	
	function shortcut_detector.is_fired( shortcut, left_click, right_click, detection_range, dont_cache )
		if #shortcut == 0 then return false end
		
		detection_range = detection_range or keystroke_listener.listened_keys

		local inverted_shortcut = get_inverted( shortcut, dont_cache )

		local trigger_key = shortcut[ #shortcut ]
		if not keystroke_listener.just_down[ trigger_key ] then return end

		for _, key in pairs( detection_range ) do
			if xor( keystroke_listener.down[ key ], inverted_shortcut[ key ] ) then return false end
		end

		if left_click ~= nil or right_click ~= nil then
			if xor( left_click, inverted_shortcut.Mouse_left ) then return false end
			if xor( right_click, inverted_shortcut.Mouse_right ) then return false end
		end

		return true
	end

	function shortcut_detector:is_held( shortcut, detection_range, dont_cache )
		if #shortcut == 0 then return false end
		
		detection_range = detection_range or keystroke_listener.listened_keys

		local inverted_shortcut = get_inverted( shortcut, dont_cache )

		for _, key in pairs( detection_range ) do
			if xor( keystroke_listener.down[ key ], inverted_shortcut[ key ] ) then return false end
		end

		return true
	end
	
	return shortcut_detector
end