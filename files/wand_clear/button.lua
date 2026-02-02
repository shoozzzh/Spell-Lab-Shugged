local module_path = this_folder()

return function()
	if pop.button( module_path .. "button.png" ) then
		if held_wand then
			sound_button_clicked()
			WANDS.wand_clear_actions( held_wand )
		end
	end
	pop.tooltip( wrap_key "clear_held_wand" )
end
