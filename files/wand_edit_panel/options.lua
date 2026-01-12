
function show_edit_panel_toggle_options()
	local data = edit_panel_api.access_data( held_wand )
	GuiLayoutBeginHorizontal( gui, 0, 0, true )
		local force_compact_enabled = data.vars.force_compact_enabled
		if not force_compact_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/force_compact.png" ) then
			sound_button_clicked()
			data.vars.force_compact_enabled = not force_compact_enabled
		end
		GuiTooltip( gui, get_text( force_compact_enabled and "disable" or "enable" ) .. get_text( "wand_force_compact" ), get_text( "wand_force_compact_description" ) .. "\n" .. get_text( "inventory_get_ignored" )  )

		local autocap_enabled = data.vars.autocap_enabled
		if not autocap_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/automatic_capacity.png" ) then
			sound_button_clicked()
			data.vars.autocap_enabled = not autocap_enabled
--[[			if autocap_enabled and force_compact_enabled then
				local new_capacity = 0
				for _ in state_str_iter_permanent_actions( edit_panel_state.get_permanent() ) do
					new_capacity = new_capacity + 1
				end
				local temp = 0
				for _, a, _ in state_str_iter_actions( edit_panel_state.get() ) do
					temp = temp + 1
					if a and a ~= "" then
						new_capacity = new_capacity + temp
						temp = 0
					end
				end
				WANDS.wand_set_stat( held_wand, "deck_capacity", new_capacity )
			end]]
		end
		GuiTooltip( gui, get_text( autocap_enabled and "disable" or "enable" ) .. get_text( "automatic_capacity" ), wrap_key( "automatic_capacity_description" ) )
	GuiLayoutEnd( gui )

	GuiLayoutBeginHorizontal( gui, 0, 0, true )
		local function cant_undo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" )
			GuiTooltip( gui, get_text( "cant_undo" ), "" )
		end
		local function cant_redo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" )
			GuiTooltip( gui, get_text( "cant_redo" ), "" )
		end

		local operation_to_undo = data:peek_undo()
		local operation_to_redo = data:peek_redo()

		if operation_to_undo then
			if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" ) then
				sound_button_clicked()
				data:undo()
			end
			GuiTooltip( gui, get_text( "undo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_undo ),
				GameTextGet( wrap_key( "current_history" ), data.vars.current_history_index, #edit_panel_api.get_histories( held_wand ) ) )
		else cant_undo() end
		if operation_to_redo then
			if GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" ) then
				sound_button_clicked()
				data:redo()
			end
			GuiTooltip( gui, get_text( "redo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_redo ),
				GameTextGet( wrap_key( "current_history" ), data.vars.current_history_index, #edit_panel_api.get_histories( held_wand ) ) )
		else cant_redo() end
	GuiLayoutEnd( gui )
end
