GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )
GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/shortcut_tips.png" )

GuiTooltip( gui, wrap_key( "shortcut_tips_title" ), edit_panel_shortcut_tips )
