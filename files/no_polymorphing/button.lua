local module_path = module_path()
local module_name = module_name()

return function()
	gui_elements.button_setting_toggle(module_path .. "button.png", module_name, "$status_protection_polymorph")
end
