local module_path = this_folder()

return function()
    menus:toggle_button( "wand_box", module_path .. "button.png" )
end
