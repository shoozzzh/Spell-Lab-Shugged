local module_path = module_path()

return function()
	gui_elements.button_setting_toggle(module_path .. "button.png", "better_all_seeing_eye", "$perk_remove_fog_of_war")
end
