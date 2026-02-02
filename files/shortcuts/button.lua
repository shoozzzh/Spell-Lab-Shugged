local module_path = this_folder()

return function()
    pop.button( module_path .. "button.png" )
    pop.tooltip( wrap_key "shortcut_tips_title", edit_panel_shortcut_tips )
end
