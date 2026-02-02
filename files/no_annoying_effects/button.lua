local module_path = module_path()

return function()
    gui_elements.button_setting_toggle( module_path .. "button.png", "disable_toxic_statuses", nil,
        wrap_key "disable_toxic_statuses_description" )
end
