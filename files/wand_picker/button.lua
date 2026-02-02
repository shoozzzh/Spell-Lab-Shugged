local module_path = this_folder()

return function()
    menus:toggle_button( "wand_picker", module_path .. "button.png", "wand_spawner" )
end
