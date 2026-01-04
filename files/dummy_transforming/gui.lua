if not selecting_mortal_to_transform then
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
end
if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transform_into_target_dummy.png" ) then
	sound_button_clicked()
	selecting_mortal_to_transform = not selecting_mortal_to_transform
end
GuiTooltip( gui, wrap_key( "transform_mortal_into_target_dummy" ),
	text_get( "transform_mortal_into_target_dummy_description", shortcut_texts.transform_mortal_into_dummy )
)
