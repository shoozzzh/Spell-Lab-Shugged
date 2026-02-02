local module_path = this_folder()

return function()
    gui_elements.button_setting_toggle( module_path .. "button.png", "disable_casting" )
end
