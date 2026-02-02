local module_path = this_folder()

return function()
    gui_elements.button_setting_toggle( module_path .. "button.png", "show_toggle_options", "toggle_options" )
end
