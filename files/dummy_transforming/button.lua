local module_path = this_folder()

return function()
	if not selecting_mortal_to_transform then
		pop.option_next "DrawSemiTransparent"
	end
	if pop.button( module_path .. "button.png" ) then
		sound_button_clicked()
		selecting_mortal_to_transform = not selecting_mortal_to_transform
	end
	pop.tooltip( wrap_key "transform_mortal_into_target_dummy",
		GameTextGet( wrap_key "transform_mortal_into_target_dummy_description",
			shortcut_texts.transform_mortal_into_dummy )
	)
end
