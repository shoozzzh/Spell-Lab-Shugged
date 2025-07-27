local wand_box_current_page_index = 1
local wand_box_selected_indexes = {}

local function wand_box_get_page_data( index )
	return mod_setting_get( "wand_box_page_" .. tostring( index ) )
end

local function wand_box_set_page_data( index, data )
	if not data then
		ModSettingRemove( "spell_lab_shugged.wand_box_page_" .. tostring( index ) )
		return
	end
	mod_setting_set( "wand_box_page_" .. tostring( index ), data )
end
if not mod_setting_get( "wand_box_page_max_index" ) then
	mod_setting_set( "wand_box_page_max_index", 1 )
	wand_box_set_page_data( 1, smallfolk.dumps( {} ) )
end

local function serialize_wand_box_page( page_index )
	if saved_wands and saved_wands[ page_index ] then
		mod_setting_set( "wand_box_page_" .. tostring( page_index ), smallfolk.dumps( saved_wands[ page_index ] ) )
	end
end

local function wand_box_new_page( index, content )
	table.insert( saved_wands, index, content )
	content = smallfolk.dumps( content )
	local max_index = mod_setting_get( "wand_box_page_max_index" )
	for i = index, max_index do
		local data_to_move = wand_box_get_page_data( i )
		wand_box_set_page_data( i + 1, data_to_move )
	end
	mod_setting_set( "wand_box_page_max_index", max_index + 1 )

	wand_box_set_page_data( index, content )
end

local function wand_box_remove_page( index )
	table.remove( saved_wands, index )
	local max_index = mod_setting_get( "wand_box_page_max_index" )
	mod_setting_set( "wand_box_page_max_index", max_index - 1 )
	for i = index + 1, max_index do
		local data_to_move = wand_box_get_page_data( i )
		wand_box_set_page_data( i - 1, data_to_move )
	end
	wand_box_set_page_data( max_index, nil )
end

saved_wands = {}
for i = 1, mod_setting_get( "wand_box_page_max_index" ) do
	local page_data = wand_box_get_page_data( i )
	if page_data then
		page_wands = smallfolk.loads( page_data )
		for _, wand in ipairs( page_wands ) do
			local capacity = wand.stats.capacity
			local deck_capacity = wand.stats.deck_capacity

			if not capacity and deck_capacity then
				capacity = deck_capacity
				for _, a in ipairs( wand.all_actions ) do
					if a.permanent then
						capacity = capacity - 1
					end
				end
				wand.stats.capacity = capacity
			end

			if not deck_capacity and capacity then
				deck_capacity = capacity
				for _, a in ipairs( wand.all_actions ) do
					if a.permanent then
						deck_capacity = deck_capacity + 1
					end
				end
				wand.stats.deck_capacity = deck_capacity
			end
		end
		table.insert( saved_wands, page_wands )
	end
end

local old_version_data = ModSettingGet( "spell_lab_shugged_saved_wands" )
if old_version_data then
	local old_version_wands = smallfolk.loads( old_version_data )
	for i = 1, math.ceil( #old_version_wands / 100 ) do
		local page = {}
		for j = 1 + ( i - 1 ) * 100, i * 100 do
			local wand = old_version_wands[ j ]
			if not wand then break end
			table.insert( page, wand )
		end
		wand_box_new_page( i, page )
	end
	ModSettingRemove( "spell_lab_shugged_saved_wands" )
	print( "[spell lab shugged] Upgraded your wand box data to the format used in new version." )
end
local t = { ["spell_lab"] = "spell_lab_saved_wands", ["EcsGui"] = "WandsConn_saved_wands" }
for name, key in pairs( t ) do
	local flag = "spell_lab_shugged.migrated_wand_box_data_from_" .. string.lower( name )
	do -- for old version stuff
		if HasFlagPersistent( flag ) then
			RemoveFlagPersistent( flag )
			ModSettingSet( flag, true )
		end
		local old_setting_key = "spell_lab_shugged_migrated_wand_box_data_from_" .. string.lower( name )
		if ModSettingGet( old_setting_key ) then
			ModSettingRemove( old_setting_key )
			ModSettingSet( flag, true )
		end
	end
	if ModSettingGet( flag ) then goto continue end
	local spell_lab_wands_data = ModSettingGet( key )
	if not spell_lab_wands_data then goto continue end
	local spell_lab_wands = smallfolk.loads( spell_lab_wands_data )
	for i, wand in ipairs( spell_lab_wands ) do
		local all_actions = {}
		local absolute_actions = wand.absolute_actions
		local permanent_actions = wand.permanent_actions
		for _, pa in ipairs( permanent_actions or {} ) do
			pa.entity = nil
			pa.item = nil
			pa.x = 0
			table.insert( all_actions, pa )
		end
		for _, a in pairs( absolute_actions or {} ) do
			a.entity = nil
			a.item = nil
			table.insert( all_actions, a )
		end
		wand.absolute_actions = nil
		wand.permanent_actions = nil
		wand.all_actions = all_actions
	end
	for i = 1, math.ceil( #spell_lab_wands / 100 ) do
		local page = {}
		for j = 1 + ( i - 1 ) * 100, i * 100 do
			local wand = spell_lab_wands[ j ]
			if not wand then break end
			table.insert( page, wand )
		end
		wand_box_new_page( i, page )
	end
	print( "[spell lab shugged] Migrated wand box data from " .. name )
	ModSettingSet( flag, true )
	::continue::
end

local wand_button_shortcuts = {
	[ shortcuts.expand_selection_left ] = function()
		local to = 1
		for i = wand_index, 1, -1 do
			if wand_box_selected_indexes[ i ] then
				to = i
				break
			end
		end
		for i = to, wand_index do
			wand_box_selected_indexes[ i ] = true
		end
	end,
	[ shortcuts.expand_selection_right ] = function()
		local to = #current_page
		for i = wand_index, #current_page do
			if wand_box_selected_indexes[ i ] then
				to = i
				break
			end
		end
		for i = wand_index, to do
			wand_box_selected_indexes[ i ] = true
		end
	end,
	[ shortcuts.multi_select ] = function()
		wand_box_selected_indexes[ wand_index ] = not wand_box_selected_indexes[ wand_index ]
	end,
	[ shortcuts.swap ] = function()
		local indexes_to_swap = {}
		for i = 1, #current_page do
			if wand_box_selected_indexes[ i ] then
				table.insert( indexes_to_swap, i )
			end
		end
		local first = indexes_to_swap[1]
		if not first then return end
		local idx = 10 * ( y_index - 1 ) + x_index
		local offset = idx - first
		if wand_box_selected_indexes[ idx ] then
			local temp = {}
			for i, index in ipairs( indexes_to_swap ) do
				temp[ i ] = current_page[ index ]
			end
			local size = #indexes_to_swap
			for i = 1, size - offset do
				current_page[ indexes_to_swap[ i + offset ] ] = temp[ i ]
			end
			for i = 1, offset do
				current_page[ indexes_to_swap[ i ] ] = temp[ size - offset + i ]
			end
		else
			for _, index in ipairs( indexes_to_swap ) do
				local the_other = index + offset
				if the_other > #current_page then
					return
				end
			end
			for _, index in ipairs( indexes_to_swap ) do
				local the_other = index + offset
				local temp = current_page[ the_other ]
				current_page[ the_other ] = current_page[ index ]
				current_page[ index ] = temp
			end
		end
	end,
	[ shortcuts.select ] = function()
		wand_box_selected_indexes = { [ wand_index ] = true }
	end,
	[ shortcuts.deselect ] = function()
		wand_box_selected_indexes[ wand_index ] = false
	end,
}

local picker = {}
picker.menu = function()
	local current_page = saved_wands[ wand_box_current_page_index ]
	GuiLayoutBeginVertical( gui, 2, 16 )
		local wand_index = 1
		for y_index = 1, 10 do
			GuiLayoutBeginHorizontal( gui, 0, 0 )
				for x_index = 1, 10 do
					local saved_wand = current_page[ wand_index ]
					if wand_index > #current_page or saved_wand == nil then break end
					do
						local spell_box
						if wand_box_selected_indexes[ wand_index ] then
							spell_box = "mods/spell_lab_shugged/files/gui/buttons/spell_box_active.png"
						else
							spell_box = "mods/spell_lab_shugged/files/gui/buttons/spell_box.png"
						end
						GuiImageButton( gui, next_id(), 0, 0, "", spell_box )
					end
					local left_click,right_click,_,x,y,_,_,_,_ = previous_data( gui )
					if left_click or right_click then
						wand_box_delete_wand_confirming = false
					end
					detect_shortcuts( gui, wand_button_shortcuts, shortcut_used_keys )
					::skip::
					do_custom_tooltip( function()
						if not shortcut_detector.is_held( shortcuts.show_wand_stats, left_click, right_click ) then
							do_simple_action_list( saved_wand.all_actions )
							GuiLayoutBeginHorizontal( gui, 0, 0 )
								GuiDimText( gui, 0, 0, GameTextGet(
									wrap_key( "wand_box_hold_something_to_show_wand_stats" ),
									shortcut_texts.show_wand_stats
								) )
							GuiLayoutEnd( gui )
						else
							do_wand_stats( gui, saved_wand.stats )
						end
					end )
					if saved_wand then
						local dynamic_wand_data = WANDS.wand_get_dynamic_wand_data_from_stats( saved_wand.stats )
						if dynamic_wand_data then
							local image_width, image_height = GuiGetImageDimensions( gui, dynamic_wand_data.file )
							
							GuiZSetForNextWidget( gui, -1 )
							GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
							GuiImage( gui, next_id(), x + ( 20 - image_height ) / 2.5, y + 10, dynamic_wand_data.file, 1.0, 1.0, 1.0, -60 / 180 * math.pi )
						end
					end
					wand_index = wand_index + 1
				end
			GuiLayoutEnd( gui )
			GuiLayoutAddVerticalSpacing( gui, -2 )
		end
	GuiLayoutEnd( gui )
end

picker.buttons = function()
	local buttons_num = 7
	if held_wand then
		buttons_num = buttons_num + 1
	end
	GuiLayoutBeginHorizontal( gui, horizontal_centered_x(buttons_num,4), percent_to_ui_scale_y(2), true )
		local current_page = saved_wands[ wand_box_current_page_index ]
		if #current_page < 100 then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/save_wand.png" ) then
				if held_wand then
					sound_button_clicked()
					local data = WANDS.wand_get_data( held_wand )
					table.insert( current_page, data )
					serialize_wand_box_page( wand_box_current_page_index )
				end
			end
			GuiTooltip( gui, wrap_key( "wand_box_save" ), "" )
		else
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/save_wand.png" )
			GuiTooltip( gui, wrap_key( "wand_box_save_reached_page_limit" ), "" )
		end
		local selected_indexes = {}
		for k = 1, #current_page do
			if wand_box_selected_indexes[ k ] then
				table.insert( selected_indexes, k )
			end
		end
		if #selected_indexes > 0 then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/delete_wand.png" ) then
				sound_button_clicked()
				if not wand_box_delete_wand_confirming then
					wand_box_delete_wand_confirming = true
				else
					if shortcut_detector.is_held( shortcuts.confirm, shortcut_used_keys ) then
						for i = #current_page, 1, -1 do
							if wand_box_selected_indexes[ i ] then
								table.remove( current_page, i )
							end
						end
						serialize_wand_box_page( wand_box_current_page_index )
						wand_box_selected_indexes = {}
					end
					wand_box_delete_wand_confirming = false
				end
			end
			if not wand_box_delete_wand_confirming then
				GuiTooltip( gui, wrap_key( "wand_box_delete" ), "" )
			else
				GuiTooltip( gui, wrap_key( "wand_box_delete" ), text_get( "deletion_confirm_button", shortcut_texts.confirm ) )
			end
		else
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/delete_wand.png" )
			GuiTooltip( gui, wrap_key( "wand_box_no_wand_selected" ), "" )
		end

		if held_wand then
			if #selected_indexes > 0 then
				if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/load_into_wand.png" ) then
					for i = 1, #current_page do
						if wand_box_selected_indexes[ i ] then
							sound_button_clicked()
							local saved_wand = current_page[ i ]
							WANDS.initialize_wand( held_wand, saved_wand )
							force_refresh_held_wands()
							reload_state_for_wand( held_wand ) -- for force compact
							wand_box_selected_indexes[ i ] = false
							break
						end
					end
				end
				GuiTooltip( gui, wrap_key( "wand_box_load_to_hand" ), "" )
			else
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
				GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/load_into_wand.png" )
				GuiTooltip( gui, wrap_key( "wand_box_no_wand_selected" ), "" )
			end
		end

		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/load_into_world.png" ) then
			local wands_to_load = {}
			for i = 1, #current_page do
				local saved_wand = current_page[ i ]
				if wand_box_selected_indexes[ i ] then
					table.insert( wands_to_load, saved_wand )
				end
			end
			for i, wand in ipairs( wands_to_load ) do
				local x, y = get_player_or_camera_position()
				local offset_x = ( i - 1 - ( #wands_to_load - 1 ) / 2 ) * 12
				local wand_ = EntityLoad( "data/entities/items/wand_level_03.xml", x + offset_x, y )
				if wand_ then
					WANDS.initialize_wand( wand_, wand )
				end
			end
			if #wands_to_load > 0 then
				sound_button_clicked()
			end
		end
		GuiTooltip( gui, wrap_key( "wand_box_load_to_world" ), "" )

		if wand_box_current_page_index > 1 then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagelast.png" ) then
				sound_button_clicked()
				wand_box_current_page_index = wand_box_current_page_index - 1
				wand_box_remove_page_confirming = false
				wand_box_selected_indexes = {}
			end
			GuiTooltip( gui, wrap_key( "wand_box_last_page" ), GameTextGet( wrap_key( "wand_box_current_page" ), wand_box_current_page_index, mod_setting_get( "wand_box_page_max_index" ) ) )
		else
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagelast.png" )
			GuiTooltip( gui, wrap_key( "wand_box_no_last_page" ), "" )
		end
		if wand_box_current_page_index < mod_setting_get( "wand_box_page_max_index" ) then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagenext.png" ) then
				sound_button_clicked()
				wand_box_current_page_index = wand_box_current_page_index + 1
				wand_box_remove_page_confirming = false
				wand_box_selected_indexes = {}
			end
			GuiTooltip( gui, wrap_key( "wand_box_next_page" ), GameTextGet( wrap_key( "wand_box_current_page" ), wand_box_current_page_index, mod_setting_get( "wand_box_page_max_index" ) ) )
		else
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagenext.png" )
			GuiTooltip( gui, wrap_key( "wand_box_no_next_page" ), "" )
		end

		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagenew.png" ) then
			sound_button_clicked()
			wand_box_remove_page_confirming = false
			wand_box_new_page( wand_box_current_page_index, {} )
			wand_box_selected_indexes = {}
		end
		GuiTooltip( gui, wrap_key( "wand_box_new_page" ), "" )
		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/pagedelete.png" ) then
			sound_button_clicked()
			if not wand_box_remove_page_confirming then
				wand_box_remove_page_confirming = true
			else
				if shortcut_detector.is_held( shortcuts.confirm, shortcut_used_keys ) then
					if mod_setting_get( "wand_box_page_max_index" ) ~= 1 then
						if wand_box_current_page_index == mod_setting_get( "wand_box_page_max_index" ) then
							wand_box_current_page_index =  wand_box_current_page_index - 1
						end
						wand_box_remove_page( wand_box_current_page_index )
					else
						wand_box_set_page_data( wand_box_current_page_index, smallfolk.dumps( {} ) )
						saved_wands[ wand_box_current_page_index ] = {}
					end
					wand_box_selected_indexes = {}
				end
				wand_box_remove_page_confirming = false
			end
		end
		if not wand_box_remove_page_confirming then
			GuiTooltip( gui, GameTextGet( wrap_key( "wand_box_delete_page" ), wand_box_current_page_index ), "" )
		else
			GuiTooltip( gui, GameTextGet( wrap_key( "wand_box_delete_page" ), wand_box_current_page_index ), text_get( "deletion_confirm_button", shortcut_texts.confirm ) )
		end
	GuiLayoutEnd( gui )
end

return picker