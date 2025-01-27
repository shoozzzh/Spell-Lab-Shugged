local shortcut_check = {}

function shortcut_check.check_input( keyboard_input, shortcut, left_click, right_click )
	if #shortcut == 0 then return false end
	if left_click == nil and right_click == nil then
		for _, keyname in ipairs( shortcut ) do
			if not keyboard_input[ keyname ] then return false end
		end
	else
		for _, keyname in ipairs( shortcut ) do
			local passed
			if keyname == "Mouse_left" then
				passed = left_click
			elseif keyname == "Mouse_right" then
				passed = right_click
			else
				passed = keyboard_input[ keyname ]
			end
			if not passed then return false end
		end
	end
	return true
end

function shortcut_check.check( ... )
	return shortcut_check.check_input( keyboard_input_holding, ... )
end

return shortcut_check