local mutils = require "misc_utils"
local settings = require "mod_settings"
local common_val = require "common_values"

local shortcut_detector = require "shortcuts.detector"

local keyboard_focus = {}

keyboard_focus.focusables = {}

local cur_focus = "player_controls"
function keyboard_focus:change_to(focusable)
    local new = focusable

    if cur_focus == new then return false end

    local old_data, new_data = self.focusables[cur_focus], self.focusables[new]
    mutils.call_if_present(old_data.on_unfocused)
    mutils.call_if_present(new_data.on_focused)

    cur_focus = new
    return true
end

---@class keyboard_focusable
---@field id string
---@field on_focused nil|fun()
---@field on_unfocused nil|fun()
---@field update nil|fun()

function keyboard_focus.is_on(focusable)
    return cur_focus == focusable
end

function keyboard_focus.update()
    local cur_data = keyboard_focus.focusables[cur_focus]
    mutils.call_if_present(cur_data.update)
end

local controls_freezer = dofile_once "mods/spell_lab_shugged/files/lib/controls_freezer.lua"
-- local edit_panel_api = dofile_once "mods/spell_lab_shugged/files/gui/edit_panel_api.lua"
keyboard_focus.focusables.player_controls = {
    id = "player_controls",
    on_focused = function()
        controls_freezer.unfreeze_controls()
    end,
    on_unfocused = function()
        controls_freezer.freeze_controls()
    end,
    update = function()
        if not common_val.held_wand or not settings.get "show_wand_edit_panel" then return end

        -- local data = edit_panel_api.access_data(held_wand)
        --[[		if shortcut_detector.is_fired( shortcuts.left_delete, shortcut_used_keys ) then
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
		if shortcut_detector.is_fired( shortcuts.right_delete, shortcut_used_keys ) then
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
		end]]
        -- if shortcut_detector.is_fired(shortcuts.undo, shortcut_used_keys) then
        --     data:undo()
        -- end
        -- if shortcut_detector.is_fired(shortcuts.redo, shortcut_used_keys) then
        --     data:redo()
        -- end
    end,
}

return keyboard_focus
