if not held_wand then return end

local actions_per_row = math.floor( screen_width / ( 20 + 2 ) - 3 )
do
	local actions_per_row_limit = tonumber( mod_setting_get( "wand_edit_panel_max_actions_per_row" ) )
	if actions_per_row_limit and actions_per_row_limit ~= 0 then
		actions_per_row = math.min( actions_per_row, actions_per_row_limit )
	end
end
local edit_panel_state = access_edit_panel_state( held_wand )

local common_actions = {}
local permanent_actions = {}
for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
	table.insert( common_actions, { s, a, u } )
end
for a in state_str_iter_permanent_actions( edit_panel_state.get_permanent() ) do
	table.insert( permanent_actions, a )
end
local capacity = EntityGetWandCapacity( held_wand )
local panel_row_offset = edit_panel_state.get_offset()
local rows_num
local not_showing_all
local offset_reached_end
local max_rows_to_show = tonumber( mod_setting_get( "wand_edit_panel_max_rows" ) ) or 5
if edit_panel_state.get_autocap_enabled() then
	rows_num = max_rows_to_show
	not_showing_all = true
	offset_reached_end = false
else
	rows_num = math.ceil( capacity / actions_per_row )
	if max_rows_to_show + panel_row_offset == rows_num then
		offset_reached_end = true
	elseif max_rows_to_show + panel_row_offset > rows_num then
		panel_row_offset = math.max( rows_num - max_rows_to_show, 0 )
		edit_panel_state.set_offset( panel_row_offset )
		offset_reached_end = true
	else
		offset_reached_end = false
	end
	if rows_num > max_rows_to_show then
		rows_num = max_rows_to_show
		not_showing_all = true
	else
		not_showing_all = false
		offset_reached_end = true
	end
end

local create_real_sprite = mod_setting_get( "gif_mode" )

local permanent_rows_num = math.ceil( #permanent_actions / actions_per_row )
if not_showing_all and panel_row_offset > 0 then
	GuiLayoutBeginVertical( gui, 0, screen_height * 0.96 - ( rows_num + permanent_rows_num + 1 ) * ( 20 + 2 ) + 2, true )
		GuiLayoutBeginHorizontal( gui, horizontal_centered_x(1), 0, true )
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pageup.png" ) then
				edit_panel_state.set_offset( panel_row_offset - 1 )
			end
		GuiLayoutEnd( gui )
	GuiLayoutEnd( gui )
end
GuiLayoutBeginVertical( gui, 0, screen_height * 0.96 - ( rows_num + permanent_rows_num ) * ( 20 + 2 ) + 2, true )
	local permanent_note = text_get( "spell_box_permanent_tips", shortcut_texts.always_cast )
	for j, permanent_action in ipairs( permanent_actions ) do
		if j % actions_per_row == 1 % actions_per_row then
			if #permanent_actions - j + 1 >= actions_per_row then
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x( actions_per_row ), 0, true )
			else
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x( #permanent_actions % actions_per_row ), 0, true )
			end
		end
		if not create_real_sprite then
			local left_click, right_click = do_action_button( permanent_action, 0, 0, false, nil, nil, permanent_note, show_permanent_icon )
			if left_click or right_click then
				if shortcut_check.check( shortcuts.always_cast, left_click, right_click ) then
					local max_uses = nil
					do
						local this_action_data = action_data[ permanent_action ]
						if this_action_data.max_uses ~= nil then
							if not world_state_unlimited_spells or this_action_data.never_unlimited then
								max_uses = this_action_data.max_uses
							end
						end
					end

					local current_actions = { { true, permanent_action, max_uses } }
					local is_first = true
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						if is_first then
							if not a or a == "" then
								-- just leave that slot to the demoted action
							else
								table.insert( current_actions, { s, a, u } )
							end
							is_first = false
						else
							table.insert( current_actions, { s, a, u } )
						end
					end
					if not fit_into_capacity( current_actions, 1, EntityGetWandCapacity( held_wand ) ) then
						GamePrint( text_get_translated( "demotion_no_space" ) )
						return
					end
					local current_permanent_actions = {}
					for pa in state_str_iter_permanent_actions( edit_panel_state.get_permanent() ) do
						table.insert( current_permanent_actions, pa )
					end
					table.remove( current_permanent_actions, j )
					edit_panel_state.set_both( table_to_state_str( current_actions ), permanent_table_to_state_str( current_permanent_actions ), wrap_key( "operation_demote_permanent_action" ) )
				end
			end
		else
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_20x20.png" )
			local _,_,_,x,y = previous_data( gui )
			local this_action_data = action_data[ permanent_action ]
			if this_action_data then
				local world_x, world_y = get_world_position( x, y )
				GameCreateSpriteForXFrames( this_action_data.sprite, world_x, world_y, false, 0, 0, 2, true )
				GameCreateSpriteForXFrames( "data/ui_gfx/inventory/icon_gun_permanent_actions.png", world_x - 2, world_y - 2, false, 0, 0, 2, true )
			end
		end
		if j % actions_per_row == 0 or j == #permanent_actions then
			GuiLayoutEnd( gui )
		end
	end
GuiLayoutEnd( gui )
GuiLayoutBeginVertical( gui, 0, screen_height * 0.96 - rows_num * ( 20 + 2 ) + 2, true )
	local note_not_selected = text_get( "spell_box_commmon_tips", shortcut_texts.select )
	local note_selected = text_get( "spell_box_commmon_tips_selected", shortcut_texts.deselect )

	local total_count = rows_num * actions_per_row
	local panel_offset = panel_row_offset * actions_per_row
	for i = 1 + panel_offset, total_count + panel_offset do
		if i % actions_per_row == 1 % actions_per_row then
			if edit_panel_state.get_autocap_enabled() or capacity - i + 1 >= actions_per_row then
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x( actions_per_row ), 0, true )
			else
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x( capacity % actions_per_row ), 0, true )
			end
		end
		local selected, action_id, uses_remaining
		if common_actions[ i ] then
			selected, action_id, uses_remaining = unpack( common_actions[ i ] )
		end
		if uses_remaining == "" then uses_remaining = nil end
		local note = selected and note_selected or note_not_selected
		if not create_real_sprite then
			local left_click, right_click = do_action_button( action_id, 0, 0, selected, nil, uses_remaining, note, show_uses_remaining )
			if left_click or right_click then
				if shortcut_check.check( shortcuts.always_cast, left_click, right_click ) then
					if action_id and action_id ~= "" then
						local current_actions = {}
						for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
							table.insert( current_actions, { s, a, u } )
						end
						if current_actions[ i ] then
							current_actions[ i ] = { false }
							edit_panel_state.set_both( table_to_state_str( current_actions ), edit_panel_state.get_permanent() .. action_id .. ",", wrap_key( "operation_promote_permanent_action" ) )
						end
					end
				elseif shortcut_check.check( shortcuts.expand_selection_left, left_click, right_click ) then
					local current_actions = {}
					local index = 1
					local last_selected_index = 1
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						if s and index < i then
							last_selected_index = index
						end
						index = index + 1
						table.insert( current_actions, { s, a, u } )
					end
					for j = last_selected_index, i, 1 do
						if current_actions[ j ] then
							current_actions[ j ][1] = true
						else
							current_actions[ j ] = { true }
						end
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_select" ) )
				elseif shortcut_check.check( shortcuts.expand_selection_right, left_click, right_click ) then	
					local current_actions = {}
					local index = 1
					local next_selected_index = -1
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						if s and index > i and next_selected_index == -1 then
							next_selected_index = index
						end
						index = index + 1
						table.insert( current_actions, { s, a, u } )
					end
					if next_selected_index ~= -1 then
						for j = i, next_selected_index, 1 do
							if current_actions[ j ] then
								current_actions[ j ][1] = true
							else
								current_actions[ j ] = { true }
							end
						end
					elseif not edit_panel_state.get_autocap_enabled() then
						for j = i, EntityGetWandCapacity( held_wand ) do
							if current_actions[ j ] then
								current_actions[ j ][1] = true
							else
								current_actions[ j ] = { true }
							end
						end
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_select" ) )
				elseif shortcut_check.check( shortcuts.duplicate, left_click, right_click ) then
					local current_actions = {}
					local selected_indexes = {}
					local index = 1
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { false, a, u } )
						if s then
							table.insert( selected_indexes, index )
						end
						index = index + 1
					end
					if current_actions[ i ] and current_actions[ i ][1] then
						return
					end
					local first = selected_indexes[1]
					if not first then return end
					local offset = i - first
					if not edit_panel_state.get_autocap_enabled() then
						for j, index in ipairs( selected_indexes ) do
							local the_other = index + offset
							if the_other > capacity then
								return
							end
						end
					end
					local selected_actions = {}
					for j, index in ipairs( selected_indexes ) do
						selected_actions[ j ] = { true, current_actions[ index ][2], current_actions[ index ][3] }
					end
					for j, index in ipairs( selected_indexes ) do
						current_actions[ index + offset ] = selected_actions[ j ]
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_duplicate_action" ) )
				elseif shortcut_check.check( shortcuts.multi_select, left_click, right_click ) then
					local current_actions = {}
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { s, a, u } )
					end
					if current_actions[ i ] then
						current_actions[ i ][1] = not current_actions[ i ][1]
					else
						current_actions[ i ] = { true }
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_select" ) )
				elseif shortcut_check.check( shortcuts.delete_action, left_click, right_click ) then
					local current_actions = {}
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { s, a, u } )
					end
					if current_actions[ i ] then
						local a = current_actions[ i ][2]
						if a and a ~= "" then
							new_action_history_entry( a )
						end
					end
					current_actions[ i ] = { true }
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_clear_action_slot" ) )
				elseif shortcut_check.check( shortcuts.delete_slot, left_click, right_click ) then
					local current_actions = {}
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { s, a, u } )
					end
					if current_actions[ i ] then
						local a = current_actions[ i ][2]
						if a and a ~= "" then
							new_action_history_entry( a )
						end
					end
					table.remove( current_actions, i )
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_delete_action_slot" ) )
				elseif shortcut_check.check( shortcuts.swap, left_click, right_click ) then
					local current_actions = {}
					local indexes_to_swap = {}
					local index = 1
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { s, a, u } )
						if s then
							table.insert( indexes_to_swap, index )
						end
						index = index + 1
					end
					local first = indexes_to_swap[1]
					if not first then return end
					local offset = i - first
					if selected then
						local temp = {}
						for j, index in ipairs( indexes_to_swap ) do
							temp[ j ] = current_actions[ index ]
						end
						local size = #indexes_to_swap
						for j = 1, size - offset do
							current_actions[ indexes_to_swap[ j + offset ] ] = temp[ j ]
						end
						for j = 1, offset do
							current_actions[ indexes_to_swap[ j ] ] = temp[ size - offset + j ]
						end
					else
						if not edit_panel_state.get_autocap_enabled() then
							for j, index in ipairs( indexes_to_swap ) do
								local the_other = index + offset
								if the_other > capacity then
									return
								end
							end
						end
						for j, index in ipairs( indexes_to_swap ) do
							local the_other = index + offset
							local temp = current_actions[ the_other ]
							current_actions[ the_other ] = current_actions[ index ]
							current_actions[ index ] = temp
						end
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_swap_actions" ) )
				elseif shortcut_check.check( shortcuts.override, left_click, right_click ) then
					local current_actions = {}
					local indexes_to_swap = {}
					local index = 1
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { s, a, u } )
						if s then
							table.insert( indexes_to_swap, index )
						end
						index = index + 1
					end
					local first = indexes_to_swap[1]
					if not first then return end
					local offset = i - first
					if not edit_panel_state.get_autocap_enabled() then
						for j, index in ipairs( indexes_to_swap ) do
							local the_other = index + offset
							if the_other > capacity then
								return
							end
						end
					end
					local selected_actions = {}
					for j, index in ipairs( indexes_to_swap ) do
						selected_actions[ j ] = current_actions[ index ]
					end
					for j, index in ipairs( indexes_to_swap ) do
						current_actions[ index + offset ] = selected_actions[ j ]
						current_actions[ index ] = { false }
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_override_actions" ) )
				elseif shortcut_check.check( shortcuts.select, left_click, right_click ) then
					local current_actions = {}
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { false, a, u } )
					end
					if current_actions[ i ] then
						current_actions[ i ][1] = true
					else
						current_actions[ i ] = { true }
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_select" ) )
				elseif shortcut_check.check( shortcuts.deselect, left_click, right_click ) then
					local current_actions = {}
					for s, a, u in state_str_iter_actions( edit_panel_state.get() ) do
						table.insert( current_actions, { s, a, u } )
					end
					if current_actions[ i ] then
						current_actions[ i ][1] = false
					else
						current_actions[ i ] = { false }
					end
					edit_panel_state.set( table_to_state_str( current_actions ), wrap_key( "operation_deselect" ) )
				end
			end
		else
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_20x20.png" )
			local _,_,_,x,y = previous_data( gui )
			local this_action_data = action_data[ action_id ]
			if this_action_data then
				local world_x, world_y = get_world_position( x, y )
				GameCreateSpriteForXFrames( this_action_data.sprite, world_x, world_y, false, 0, 0, 2, true )
			end
		end
		if i == capacity and not edit_panel_state.get_autocap_enabled() then
			GuiLayoutEnd( gui )
			break
		end

		if i % actions_per_row == 0 or i == total_count then
			GuiLayoutEnd( gui )
		end
	end
GuiLayoutEnd( gui )

if not_showing_all and not offset_reached_end then
	GuiLayoutBeginVertical( gui, 0, 95 )
		GuiLayoutBeginHorizontal( gui, horizontal_centered_x(1), 0, true )
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagedown.png" ) then
				edit_panel_state.set_offset( panel_row_offset + 1 )
			end
		GuiLayoutEnd( gui )
	GuiLayoutEnd( gui )
end

if edit_panel_state.need_sync() then
	local ability = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
	if not ability then return end
	local old_capacity = EntityGetWandCapacity( held_wand )
	local old_deck_capacity = WANDS.wand_get_stat( held_wand, "deck_capacity" )
	WANDS.wand_clear_actions( held_wand )
	local pa_num = 0
	for a in state_str_iter_permanent_actions( edit_panel_state.get_permanent() ) do
		if a ~= "" then
			pa_num = pa_num + 1
			local action_entity = CreateItemActionEntity( a, x, y )
			EntityAddChild( held_wand, action_entity )
			local item_comp = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
			ComponentSetValue2( item_comp, "permanently_attached", true )
			ComponentSetValue2( item_comp, "inventory_slot", 0, 0 )
			EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
		end
	end
	local i = 0
	local i_trimmed_end_space = 0
	for _, a, u in state_str_iter_actions( edit_panel_state.get() ) do
		-- if held_wand_actions[ index ] then
		-- 	EntityRemoveFromParent( held_wand_actions[ index ].entity )
		-- 	EntityKill( held_wand_actions[ index ].entity )
		-- end
		if a and a ~= "" then
			local action_entity = CreateItemActionEntity( a, x, y )
			EntityAddChild( held_wand, action_entity )
			local item_comp = EntityGetFirstComponentIncludingDisabled( action_entity, "ItemComponent" )
			local _, item_y = ComponentGetValue2( item_comp, "inventory_slot" )
			ComponentSetValue2( item_comp, "inventory_slot", i, item_y )
			local this_action_data = action_data[ a ]
			local never_unlimited = this_action_data.never_unlimited
			if this_action_data.max_uses then
				if world_state_unlimited_spells and not never_unlimited then
					-- CreateItemActionEntity has already done it
				elseif not u or u == "" then
					-- CreateItemActionEntity has already done it
				else
					ComponentSetValue2( item_comp, "uses_remaining", tonumber( u ) )
				end
			end
			i = i + 1
			i_trimmed_end_space = i
			EntitySetComponentsWithTagEnabled( action_entity, "enabled_in_world", false )
		elseif not edit_panel_state.get_force_compact_enabled() then
			i = i + 1
		end
	end
	local deck_capacity_taken = i_trimmed_end_space + pa_num
	if edit_panel_state.get_autocap_enabled() or old_deck_capacity < deck_capacity_taken then
		WANDS.wand_set_stat( held_wand, "deck_capacity", deck_capacity_taken )
	else
		WANDS.wand_set_stat( held_wand, "deck_capacity", old_capacity + pa_num )
	end

	force_refresh_held_wands()
	edit_panel_state.done_sync()
end