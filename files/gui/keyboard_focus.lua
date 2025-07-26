local keyboard_focus = {}

keyboard_focus.focusables = {}

local on = "player_controls"
function keyboard_focus.change_to( focusable )
	local new = focusable

	if on == new then return false end

	local from, to = focusables[ on ], focusables[ new ]
	optional_call( from.on_unfocused )
	optional_call( to.on_focused )

	on = new
	return true
end

function keyboard_focus.is_on( focusable )
	return on == focusable
end

function keyboard_focus.update()
	local on = keyboard_focus.focusables[ on ]
	optional_call( on.update )
end

local controls_freezer = dofile_once( "mods/spell_lab_shugged/files/lib/controls_freezer.lua" )
keyboard_focus.focusables.player_controls = {
	on_focused = function()
		controls_freezer.unfreeze_controls()
	end,
	on_unfocused = function()
		controls_freezer.freeze_controls()
	end,
	update = function()
		if shortcut_detector.is_fired( shortcuts.transform_mortal_into_dummy ) then
			if selecting_mortal_to_transform then
				dofile( "mods/spell_lab_shugged/files/scripts/transform_mortal_into_dummy.lua" )
				selecting_mortal_to_transform = false
			end
		end

		if not held_wand or not mod_setting_get( "show_wand_edit_panel" ) then return end

		local edit_panel_state = access_edit_panel_state( held_wand )
		if shortcut_detector.is_fired( shortcuts.left_delete ) then
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
		if shortcut_detector.is_fired( shortcuts.right_delete ) then
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
		if shortcut_detector.is_fired( shortcuts.undo ) then
			edit_panel_state.undo()
		end
		if shortcut_detector.is_fired( shortcuts.redo ) then
			edit_panel_state.redo()
		end
	end,
}

return keyboard_focus