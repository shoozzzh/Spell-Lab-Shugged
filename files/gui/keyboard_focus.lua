dofile_once( "mods/spell_lab_shugged/files/lib/controls_freezing_utils.lua" )
Focus_PlayerControls = {
	id = "player_controls",
	on_focused = function()
		unfreeze_controls()
	end,
	on_unfocused = function()
		freeze_controls( player )
	end,
	on_input = function( keyboard_input )
		if not held_wand or not mod_setting_get( "show_wand_edit_panel" ) then return end
		local edit_panel_state = access_edit_panel_state( held_wand )
		if keyboard_input.Key_BACKSPACE then
			local current_actions = {}
			local did = false
			for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
				if s then
					did = true
					if a == "" then
						current_actions[ #current_actions ] = { true }
					end
					table.insert( current_actions, { false } )
				else
					table.insert( current_actions, { s, a, u } )
				end
			end
			if did then
				edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_delete_action" ) )
			end
		end
		if keyboard_input.Key_DELETE then
			local current_actions = {}
			local delete_next_action
			local did = false
			for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
				if s then
					did = true
					if a == "" then
						delete_next_action = true
					end
					table.insert( current_actions, { false } )
				else
					if not delete_next_action then
						table.insert( current_actions, { s, a, u } )
					else
						table.insert( current_actions, { true } )
						delete_next_action = false
					end
				end
			end
			if did then
				edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_delete_action" ) )
			end
		end
		if ctrl and keyboard_input.Key_z then
			edit_panel_state.undo()
		end
		if ctrl and keyboard_input.Key_y then
			edit_panel_state.redo()
		end
	end,
}

local current_focus = Focus_PlayerControls
function change_keyboard_focus( focus )
	if current_focus.id == focus.id then return false end
	if current_focus.on_unfocused then
		current_focus.on_unfocused()
	end
	if focus.on_focused then
		focus.on_focused()
	end
	current_focus = focus
	return true
end

function is_keyboard_focus( focus )
	return current_focus.id == focus.id
end

function update_keyboard_input( keyboard_input )
	if current_focus.on_input then
		current_focus.on_input( keyboard_input )
	end
end