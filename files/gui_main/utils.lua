TextColors = {
	Grey = { r = 127, g = 127, b = 127, a = 127 },
	Soft = { r = 207, g = 207, b = 207, a = 255 },
}

-- function percent_to_ui_scale_y( y )
-- 	return y * screen_height / 100
-- end

-- function horizontal_centered_x( buttons_num, offset )
-- 	offset = offset or 0
-- 	return screen_width / 2 - ( ( buttons_num - offset ) * 22 + 2 ) / 2
-- end

function sound_button_clicked()
	if mod_setting.get "button_click_sound" then
		GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
	end
end

function sound_action_button_clicked()
	if mod_setting.get "action_button_click_sound" then
		GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
	end
end
