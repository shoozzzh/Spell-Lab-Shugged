local module_path = module_path()

return function()
    gui_elements.button_setting_toggle( module_path .. "button.png", "invincible", "$status_protection_all" )
end
