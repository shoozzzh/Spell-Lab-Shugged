local module_path = module_path()

return function()
    gui_elements.button_setting_toggle( module_path .. "button.png", "disable_casting" )
end
