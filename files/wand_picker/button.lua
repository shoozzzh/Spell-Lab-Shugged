local module_path = module_path()

return function()
    menus:toggle_button( "wand_picker", module_path .. "button.png", "wand_spawner" )
end
