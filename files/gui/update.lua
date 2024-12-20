if initialized == nil then initialized = false end

if initialized == false then
	initialized = true
	-- Force cache refresh to ensure we have the latest files
	__loaded = {}
	-- NOTE: Using GameTextGetXX may be wastey. Consider caching some of the ui elements like [?] and [X] and only update them when the menu is clicked
	print( "[spell lab] setting up GUI" )
	dofile_once( "data/scripts/gun/gun.lua" )
	dofile_once( "data/scripts/lib/utilities.lua" )
	dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua")
	dofile_once( "mods/spell_lab_shugged/files/gui/get_player.lua" )
	WANDS = dofile_once( "mods/spell_lab_shugged/files/lib/wands.lua")
	dofile_once( "data/scripts/debug/keycodes.lua" )
	smallfolk = dofile_once( "mods/spell_lab_shugged/files/lib/smallfolk.lua" )

	player = get_player()

	gui = gui or GuiCreate()
	GuiStartFrame( gui )
	screen_width, screen_height = GuiGetScreenDimensions( gui )
	local id_offset = 0
	local mod_settings_prefix = "spell_lab_shugged."

	function mod_setting_get( key )
		return ModSettingGet( mod_settings_prefix .. key )
	end
	function mod_setting_set( key, value )
		return ModSettingSet( mod_settings_prefix .. key, value )
	end

	local transl_key_prefix = "$spell_lab_shugged_"

	function wrap_key( key )
		if string.sub( key, 1, 1 ) == "$" then
			return key
		end
		return transl_key_prefix .. key
	end
	function text_get_translated( key )
		return GameTextGetTranslatedOrNot( wrap_key( key ) )
	end

	local version = "Shugged v1.7.5"

	function maxn( t )
		local result = table.maxn( t )
		if result == 0 and not t[0] then return -1 end
		return result
	end

	function next_id()
		id_offset = id_offset + 1
		return id_offset
	end

	function previous_data( gui )
		local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = GuiGetPreviousWidgetInfo( gui )
		if left_click == 1 then left_click = true elseif left_click == 0 then left_click = false end
		if right_click == 1 then right_click = true elseif right_click == 0 then right_click = false end
		if hover == 1 then hover = true elseif hover == 0 then hover = false end
		return left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height
	end

	function sound_button_clicked()
		if mod_setting_get( "button_click_sound" ) then
			GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
		end
	end

	function sound_action_button_clicked()
		if mod_setting_get( "action_button_click_sound" ) then
			GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
		end
	end

	type_text = {
		[ACTION_TYPE_MODIFIER]          = "$inventory_actiontype_modifier",
		[ACTION_TYPE_PROJECTILE]        = "$inventory_actiontype_projectile",
		[ACTION_TYPE_STATIC_PROJECTILE] = "$inventory_actiontype_staticprojectile",
		[ACTION_TYPE_OTHER]             = "$inventory_actiontype_other",
		[ACTION_TYPE_MATERIAL]          = "$inventory_actiontype_material",
		[ACTION_TYPE_DRAW_MANY]         = "$inventory_actiontype_drawmany",
		[ACTION_TYPE_UTILITY]           = "$inventory_actiontype_utility",
		[ACTION_TYPE_PASSIVE]           = "$inventory_actiontype_passive",
	}

	function percent_to_ui_scale_y( y )
		return y * screen_height / 100
	end

	function horizontal_centered_x( buttons_num, offset )
		offset = offset or 0
		return screen_width / 2 - ( ( buttons_num - offset ) * 22 + 2 ) / 2
	end

	sorted_actions = {}
	action_data = {}
	for k, _ in pairs( type_text ) do
		sorted_actions[ k ] = {}
	end
	for _, action in pairs( actions ) do
		sorted_actions[action.type][ #sorted_actions[action.type] + 1 ] = action
		action_data[action.id] = action
	end
	action_metadata, extra_modifier_metadata, metadata_to_show =
		unpack( dofile( "mods/spell_lab_shugged/files/gui/action_metadata.lua" ) )
	local is_panel_open = false

	function get_player_or_camera_position()
		if player then
			x, y = EntityGetTransform( player )
			return x, y
		end
		return GameGetCameraPos()
	end

	function get_held_wand()
		if not player then return end
		local wands
		for _, child_id in ipairs( EntityGetAllChildren( player ) or {} ) do
			if EntityGetName( child_id ) == "inventory_quick" then
				wands = EntityGetAllChildren( child_id, "wand" )
				break
			end
		end
		if not wands or #wands == 0 then return end
		local inv2 = EntityGetFirstComponent( player, "Inventory2Component" )
		local active_item = ComponentGetValue2( inv2, "mActiveItem" )
		for _, wand_id in pairs( wands ) do
			if wand_id == active_item then
				return wand_id
			end
		end
	end

	function get_screen_position( x, y )
		local camera_x, camera_y = GameGetCameraPos()
		local res_width = MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" )
		local res_height = MagicNumbersGetValue( "VIRTUAL_RESOLUTION_Y" )
		local ax = (x - camera_x) / res_width * screen_width
		local ay = (y - camera_y) / res_height * screen_height
		return ax + screen_width * 0.5, ay + screen_height * 0.5
	end

	function get_world_position( x, y )
		local camera_x, camera_y = GameGetCameraPos()
		local res_width = MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" )
		local res_height = MagicNumbersGetValue( "VIRTUAL_RESOLUTION_Y" )
		local ax, ay = x - screen_width * 0.5, y - screen_height * 0.5
		local wx = ax * res_width / screen_width + camera_x
		local wy = ay * res_height / screen_height + camera_y
		return wx, wy
	end

	local cached_mouse_x, cached_mouse_y
	function get_mouse_pos_on_screen()
		if not cached_mouse_x or not cached_mouse_y then
			cached_mouse_x, cached_mouse_y = get_screen_position( DEBUG_GetMouseWorld() )
		end
		return cached_mouse_x, cached_mouse_y
	end

	function scroll_box_no_wand_switching( hovered )
		if hovered then
			local mx, my = get_mouse_pos_on_screen()
			GuiIdPushString( gui, "NO_MORE_WAND_SWITCHING" )
			GuiAnimateBegin( gui )
			GuiAnimateAlphaFadeIn( gui, 1, 0, 0, true )
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.AlwaysClickable )
			GuiBeginScrollContainer( gui, 2, mx - 25, my - 25, 50, 50, false, 0, 0 )
			GuiEndScrollContainer( gui )
			GuiAnimateEnd( gui )
			GuiIdPop( gui )
			ModTextFileSetContent_Saved( "mods/spell_lab_shugged/scroll_box_hovered.txt", "true" )
		else
			ModTextFileSetContent_Saved( "mods/spell_lab_shugged/scroll_box_hovered.txt", "false" )
		end
	end

	function force_refresh_held_wands()
		if not player then return end
		local inv2_comp = EntityGetFirstComponent( player, "Inventory2Component" )
		if not inv2_comp then return end
		ComponentSetValue2( inv2_comp, "mForceRefresh", true )
		ComponentSetValue2( inv2_comp, "mActualActiveItem", 0 )
		ComponentSetValue2( inv2_comp, "mDontLogNextItemEquip", true )
	end

	function clear_held_wand_wait()
		if not held_wand then return false end
		local ab_comp = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
		if not ab_comp then return false end
		ComponentSetValue2( ab_comp, "mReloadFramesLeft", 0 )
		ComponentSetValue2( ab_comp, "mNextFrameUsable", now )
		ComponentSetValue2( ab_comp, "mReloadNextFrameUsable", now )
		return true
	end

	function block_upcoming_wand_shooting()
		if not held_wand then return end
		local ab_comp = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
		if not ab_comp then return end
		ComponentSetValue2( ab_comp, "mReloadFramesLeft", math.max( 10, ComponentGetValue2( ab_comp, "mReloadFramesLeft" ) ) )
		ComponentSetValue2( ab_comp, "mNextFrameUsable", math.max( now + 10, ComponentGetValue2( ab_comp, "mNextFrameUsable" ) ) )
		ComponentSetValue2( ab_comp, "mReloadNextFrameUsable", math.max( now + 10, ComponentGetValue2( ab_comp, "mReloadNextFrameUsable" ) ) )
	end

	function is_action_unlocked( action )
		if action then
			return not action.spawn_requires_flag or HasFlagPersistent( action.spawn_requires_flag )
		end
		return false
	end

	dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_utils.lua" )
	dofile_once( "mods/spell_lab_shugged/files/gui/pickers.lua" )

	action_id_to_idx = {}

	for i, a in ipairs( actions ) do
		if a.id and a.id ~= "" then
			action_id_to_idx[ a.id ] = i
		end
	end

	function word_wrap( str, wrap_size )
		if GameTextGetTranslatedOrNot( "current_language" ) ~= "English" then
			return str
		end
		if wrap_size == nil then wrap_size = 60 end
		local last_space_index = 1
		local last_wrap_index = 0
		for i=1,#str do
			if str:sub(i,i) == " " then
				last_space_index = i
			end
			if str:sub(i,i) == "\n" then
				last_space_index = i
				last_wrap_index = i
			end
			if i - last_wrap_index > wrap_size then
				str = str:sub(1,last_space_index-1) .. "\n" .. str:sub(last_space_index + 1)
				last_wrap_index = i
			end
		end
		return str
	end

	wand_stats = dofile( "mods/spell_lab_shugged/files/gui/wand_stats.lua" )

	SCROLL_TABLE_WIDTH = 174

	function do_scroll_table( scroll_id, width, height, height_autofit, hover_callback, cell_list, cell_gui_func, row_size )
		row_size = row_size or 8
		width = width or SCROLL_TABLE_WIDTH
		if height_autofit then
			local num_rows = math.max( 1, math.ceil( #cell_list / row_size ) )
			height = math.min( num_rows * 20, height or 160 )
		end

		GuiBeginScrollContainer( gui, scroll_id, 0, 0, width, math.max( height, 20 ) )
			do
				local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
				local mx, my = get_mouse_pos_on_screen()
				-- extra 2 pixels for the margins
				local hovered = -2 <= mx - x and mx - x <= width + 2 and -2 <= my - y and my - y <= height + 2
				if hover_callback then
					hover_callback( hovered )
				end
				scroll_box_no_wand_switching( hovered )
			end
			GuiLayoutBeginVertical( gui, 0, 0 )
				local index = 1
				local cell = cell_list[ index ]
				while cell do
					GuiLayoutBeginHorizontal( gui, 0, 0 )
						local cells_in_row = 0
						while cell and cells_in_row < row_size do
							cell_gui_func( cell, index )
							cells_in_row = cells_in_row + 1
							index = index + 1
							cell = cell_list[ index ]
						end
					GuiLayoutEnd( gui )
					GuiLayoutAddVerticalSpacing( gui, -2 )
				end
				if index == 1 then -- no cell to show
					GuiText( gui, 0, 0, wrap_key( "scroll_table_nothing" ) )
				end
			GuiLayoutEnd( gui )
		GuiEndScrollContainer( gui )
	end

	function do_flag_toggle_image_button( filepath, flag, option_text, click_callback, description )
		local mod_settings_key = mod_settings_prefix .. flag
		if not ModSettingGet( mod_settings_key ) then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		local left_click, right_click = GuiImageButton( gui, next_id(), 0, 0, "", filepath )
		if left_click then
			sound_button_clicked()
			local new = not ModSettingGet( mod_settings_key )
			ModSettingSet( mod_settings_key, new )
			if click_callback then
				click_callback( new )
			end
		end
		option_text = option_text or flag
		option_text = text_get_translated( option_text )
		if ModSettingGet( mod_settings_key ) then
			GuiTooltip( gui, text_get_translated( "disable" ) .. option_text, description or "" )
		else
			GuiTooltip( gui, text_get_translated( "enable" ) .. option_text, description or "" )
		end
		return left_click, right_click
	end

	function do_action_image( id, action_id, x, y, alpha, scale_x, scale_y, rotation )
		x = x or 0
		y = y or 0
		alpha = alpha or 1.0
		scale_x = scale_x or 1.0
		scale_y = scale_y or 1.0
		rotation = rotation or 0.0

		local image_sprite = "mods/spell_lab_shugged/files/gui/buttons/empty_spell.png"
		local this_action_data = action_data[action_id]
		local spell_box_suffix = ""
		if this_action_data then spell_box_suffix = spell_box_suffix .. "_" .. this_action_data.type end
		if this_action_data then
			image_sprite = this_action_data.sprite
		end
		GuiImage( gui, id, x, y, image_sprite, alpha, scale_x, scale_y, rotation )
		GuiZSetForNextWidget( gui, 1 )
		GuiImage( gui, next_id(), -20, 0, "mods/spell_lab_shugged/files/gui/buttons/spell_box"..spell_box_suffix..".png", 1.0, 1.0, 0 )
	end

	function do_action_button( action_id, x, y, selected, click_callback, tooltip_func, uses_remaining, note, extra_gui, empty_slot_show_tooltip, no_title )
		if x == nil then x = 0 end
		if y == nil then y = 0 end
		local image_sprite = "mods/spell_lab_shugged/files/gui/buttons/empty_spell.png"
		local this_action_data =  action_data[action_id]
		local left_click,right_click,hover
		local spell_box_suffix = ""
		
		if this_action_data then spell_box_suffix = spell_box_suffix .. "_" .. this_action_data.type end
		if this_action_data then
			image_sprite = this_action_data.sprite
		end
		local this_action_metadata = action_metadata[ action_id ]

		GuiZSetForNextWidget( gui, 0 )
		GuiImageButton( gui, next_id(), 2, 2, "", image_sprite )
		local left_click,right_click,hover = previous_data( gui )

		if selected then
			spell_box_suffix = spell_box_suffix .. "_active"
		elseif hover then
			spell_box_suffix = spell_box_suffix .. "_hover"
		end

		--if tooltip_string ~= nil then GuiTooltip( gui, tooltip_string, "" ) end
		--if this_action_data then GuiTooltip( gui, GameTextGetTranslatedOrNot( this_action_data.name ) .. " (" .. this_action_data.id .. ")", "" ) end
		if this_action_data or empty_slot_show_tooltip then
			do_custom_tooltip( function()
				GuiLayoutBeginVertical( gui, 0, 0 )
					if this_action_data and not no_title then
						local title = GameTextGetTranslatedOrNot( this_action_data.name )
						if uses_remaining then
							title = title .. "(" .. tostring( uses_remaining ) .. ")"
						end
						GuiText( gui, 0, 0, title )
					end
					if tooltip_func then
						tooltip_func( this_action_data, this_action_metadata )
					end
					if note then
						GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1.0 )
						GuiText( gui, 0, 0, note )
					end
				GuiLayoutEnd( gui )
			end, nil, 10, 0 )
		end

		GuiZSetForNextWidget( gui, 1 )
		GuiImage( gui, next_id(), -20, 0, "mods/spell_lab_shugged/files/gui/buttons/spell_box"..spell_box_suffix..".png", 1.0, 1.0, 0 )
		if extra_gui then
			local _,_,_,x,y,_,_,_,_,_,_ = previous_data( gui )
			extra_gui( x, y, this_action_data, uses_remaining )
		end
		if left_click or right_click then
			sound_action_button_clicked()
			if click_callback then
				click_callback( left_click, right_click )
			end
		end
	end

	function do_fake_action_button( action_type, action_sprite, name, id, desc, type, semi_transparent, uses_remaining, properties )
		GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_20x20.png" )
		local left_click,right_click,hover,x1,y1 = previous_data( gui )
		do_custom_tooltip( function()
			GuiLayoutBeginVertical( gui, 0, 0, true )
				GuiText( gui, 0, 0, name )
				if id then
					GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1.0 )
					GuiText( gui, 0, 0, id )
				end
				if type then
					GuiColorSetForNextWidget( gui, 0.5, 0.5, 1.0, 1.0 )
					GuiText( gui, 0, 0, type )
				end
				GuiColorSetForNextWidget( gui, 0.811, 0.811, 0.811, 1.0 )
				GuiText( gui, 0, 0, desc )
				if properties and #properties > 0 then
					GuiLayoutAddVerticalSpacing( gui, 5 )
					do_property_list( properties )
				end
			GuiLayoutEnd( gui )
		end, nil, 10, 0 )

		local spell_box_suffix = tostring( action_type or ACTION_TYPE_PROJECTILE )
		if hover then
			spell_box_suffix = spell_box_suffix .. "_hover"
		end

		GuiLayoutBeginLayer( gui )
			GuiZSetForNextWidget( gui, 0 )
			local sprite_width, sprite_height = GuiGetImageDimensions( gui, action_sprite )
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			if semi_transparent then
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			end
			GuiImageButton( gui, next_id(), x1 + ( 20 - sprite_width ) / 2--[[ - 20]], y1 + ( 20 - sprite_height ) / 2, "", action_sprite, 1 )
			GuiZSetForNextWidget( gui, 1 )
			if semi_transparent then
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			end
			GuiImage( gui, next_id(), --[[-( 2 + sprite_width / 2 + 10 )]]x1, y1, "mods/spell_lab_shugged/files/gui/buttons/spell_box_"..spell_box_suffix..".png", 1.0, 1.0, 0 )
			if uses_remaining then
				show_uses_remaining( x1, y1, nil, uses_remaining )
			end
		GuiLayoutEndLayer( gui )

		return left_click, right_click
	end

	function show_permanent_icon( x, y )
		GuiZSetForNextWidget( gui, -1 )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
		GuiImage( gui, next_id(), x-2, y-2, "data/ui_gfx/inventory/icon_gun_permanent_actions.png", 1.0, 1.0, 0 )
	end

	function show_locked_state( x, y, this_action_data )
		if not this_action_data or not this_action_data.spawn_requires_flag then return end
		if HasFlagPersistent( this_action_data.spawn_requires_flag ) then
			if mod_setting_get( "show_icon_unlocked" ) then
				GuiZSetForNextWidget( gui, -1 )
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
				GuiImage( gui, next_id(), x+14, y-2, "mods/spell_lab_shugged/files/gui/unlocked.png", 0.3, 1.0, 0 )
			end
		else
			GuiZSetForNextWidget( gui, -1 )
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
			GuiImage( gui, next_id(), x+14, y-2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
		end
	end

	function show_uses_remaining( x, y, _, uses_remaining )
		if not uses_remaining then return end
		GuiZSetForNextWidget( gui, -1 )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
		GuiText( gui, x-2, y-2, tostring( uses_remaining ), 1, "data/fonts/font_pixel_noshadow.xml", true )
	end

	function do_property_list( lines )
		for _, p in ipairs( lines ) do
			local name = p[1]
			local value = p[2]
			GuiLayoutBeginHorizontal( gui, 0, 0 )
				GuiColorSetForNextWidget( gui, 0.811, 0.811, 0.811, 1.0 )
				GuiText( gui, 0, 0, name )
				GuiColorSetForNextWidget( gui, 1.0, 0.75, 0.5, 1.0 )
				local _,_,_,_,_,width,_,_,_,_,_ = previous_data( gui )
				GuiText( gui, 72 - width, 0, tostring( value ) )
			GuiLayoutEnd( gui )
			GuiLayoutAddVerticalSpacing( gui, -2 )
		end
	end

	function do_verbose_tooltip( this_action_data, this_action_metadata )
		local num_lines = 1 -- wait
		local other_offset = 0

		local c_lines = c_metadata_to_lines( this_action_metadata.c )
		num_lines = num_lines + #c_lines

		local projectiles_lines, num_proj_lines = proj_metadata_to_lines( this_action_metadata.projectiles )
		num_lines = num_lines + num_proj_lines

		GuiColorSetForNextWidget( gui, 0, 0, 0, 0 )
		GuiText( gui, 0, 0, " " )
		local _,_,_,_,y,_,text_height,_,_,_,_ = previous_data( gui )
		GuiLayoutAddVerticalSpacing( gui, -text_height )
		local _, screen_height = GuiGetScreenDimensions( gui )
		local tooltip_height = ( num_lines + 4 ) * ( text_height ) + 5
		local tooltip_bottom = y + tooltip_height + 36 -- extra space
		if tooltip_bottom > screen_height then
			GuiLayoutAddVerticalSpacing( gui, screen_height - tooltip_bottom )
		end

		local title = GameTextGetTranslatedOrNot( this_action_data.name )
		if this_action_data.max_uses then
			title = title .. ( "(" .. tostring( this_action_data.max_uses ) .. ")" )
		end
		GuiText( gui, 0, 0, title )

		GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1.0 )
		GuiText( gui, 0, 0, this_action_data.id )
		GuiColorSetForNextWidget( gui, 0.5, 0.5, 1.0, 1.0 )
		GuiText( gui, 0, 0, GameTextGetTranslatedOrNot( type_text[ this_action_data.type ] ) )
		GuiColorSetForNextWidget( gui, 0.811, 0.811, 0.811, 1.0 )
		GuiText( gui, 0, 0, word_wrap( GameTextGetTranslatedOrNot( this_action_data.description ) ) )
		if not this_action_metadata then return end
		GuiLayoutAddVerticalSpacing( gui, 5 )
		if this_action_metadata.projectiles then
			GuiText( gui, 0, 0, wrap_key( "spell_data" ) )
		end

		do_property_list( c_lines )

		local only_one_proj = #projectiles_lines == 1
		for proj_index, proj_lines in ipairs( projectiles_lines ) do
			if only_one_proj then
				GuiText( gui, 0, 0, wrap_key( "projectile_data" ) )
			else
				GuiText( gui, 0, 0, GameTextGet( wrap_key( "projectile_nth_data" ), tostring( proj_index ) ) )
			end
			do_property_list( proj_lines )
		end
	end

	function do_custom_tooltip( callback, z, x_offset, y_offset )
		if z == nil then z = -12 end
		local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = previous_data( gui )
		if x_offset == nil then x_offset = 0 end
		if y_offset == nil then y_offset = 0 end
		if hover then
			GuiZSet( gui, z )
			GuiLayoutBeginLayer( gui )
				GuiLayoutBeginVertical( gui, ( x + x_offset + width ), ( y + y_offset ), true )
					GuiBeginAutoBox( gui )
						if callback ~= nil then callback() end
						GuiZSetForNextWidget( gui, z + 1 )
					GuiEndAutoBoxNinePiece( gui )
				GuiLayoutEnd( gui )
			GuiLayoutEndLayer( gui )
			GuiZSet( gui, 0 )
		end
	end

	local function show_simple_action_image( action_id )
		if action_id and action_id ~= "" then
			local this_action_data = action_data[ action_id ]
			local sprite = ( this_action_data and this_action_data.sprite ) and this_action_data.sprite or "data/ui_gfx/gun_actions/_unidentified.png"
			GuiZSetForNextWidget( gui, -14 )
			GuiImage( gui, next_id(), 0, 0, sprite, 1.0, 0.5, 0 )
			GuiZSetForNextWidget( gui, -13 )
			GuiImage( gui, next_id(), -11, -1, "mods/spell_lab_shugged/files/gui/buttons/spell_box.png", 1.0, 0.5, 0 )
		else
			GuiZSetForNextWidget( gui, -13 )
			GuiImage( gui, next_id(), -1, -1, "mods/spell_lab_shugged/files/gui/buttons/spell_box.png", 1.0, 0.5, 0 )
		end
	end
	function do_simple_action_list( all_actions )
		local common_actions = {}
		local permanent_actions = {}
		local max_x = -1
		for _, a in ipairs( all_actions ) do
			if a.permanent then
				table.insert( permanent_actions, a.action_id )
			else
				if a.x ~= 0 then
					common_actions[ a.x ] = a.action_id
					max_x = math.max( max_x, a.x )
				else
					max_x = max_x + 1
					common_actions[ max_x ] = a.action_id
				end
			end
		end
		do_simple_permanent_action_list( permanent_actions )
		do_simple_common_action_list( common_actions, max_x )
	end
	function do_simple_permanent_action_list( permanent_actions )
		if #permanent_actions > 0 then
			GuiLayoutBeginHorizontal( gui, 0, 0 )
			for _,permanent_action in pairs( permanent_actions ) do
				show_simple_action_image( permanent_action )
			end
			GuiLayoutEnd( gui )
			GuiLayoutAddVerticalSpacing( gui, 1 )
		end
	end
	function do_simple_common_action_list( common_actions, max_x )
		local actions_per_row = 26
		if max_x > -1 then
			for i = 0, max_x do
				if i % actions_per_row == 0 then
					GuiLayoutBeginHorizontal( gui, 0, 0 )
				end
				show_simple_action_image( common_actions[ i ] )
				if i % actions_per_row == actions_per_row - 1 or i == max_x then
					GuiLayoutEnd( gui )
				end
			end
		end
	end

	function do_flat_action_list( actions )   
		for _,action_id in ipairs(actions) do
			local this_action_data = action_data[action_id]
			if this_action_data then GuiImage( gui, next_id(), 0, 0, this_action_data.sprite, 1.0, 0.5, 0 ) end
		end
	end

	function do_wand_stats( gui, stats )
		for _, v in ipairs( wand_stats ) do
			if stats[ v.stat ] then
				GuiLayoutBeginHorizontal( gui, 0, 0 )
					GuiColorSetForNextWidget( gui, 0.811, 0.811, 0.811, 1.0 )
					GuiText( gui, 0, 0, v.label )
					GuiColorSetForNextWidget( gui, 1.0, 0.75, 0.5, 1.0 )
					local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = previous_data( gui )
					GuiText( gui, 72 - width, 0, v.text_callback( stats[ v.stat ] ) )
				GuiLayoutEnd( gui )
				GuiLayoutAddVerticalSpacing( gui, -4 )
			end
		end
	end

	dofile_once( "mods/spell_lab_shugged/files/gui/edit_panel_api.lua" )

	dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_listener.lua" )
	dofile_once( "mods/spell_lab_shugged/files/gui/keyboard_focus.lua" )

	function show_edit_panel_toggle_options()
		local edit_panel_state = access_edit_panel_state( held_wand )
		local force_compact_enabled = edit_panel_state.get_force_compact_enabled()
		if not force_compact_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/force_compact.png" ) then
			sound_button_clicked()
			edit_panel_state.set_force_compact_enabled( not force_compact_enabled )
			edit_panel_state.force_sync()
		end
		GuiTooltip( gui, text_get_translated( force_compact_enabled and "disable" or "enable" ) .. text_get_translated( "wand_force_compact" ), text_get_translated( "wand_force_compact_description" ) .. "\n" .. text_get_translated( "inventory_get_ignored" )  )
		local autocap_enabled = edit_panel_state.get_autocap_enabled()
		if not autocap_enabled then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
		end
		if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/automatic_capacity.png" ) then
			sound_button_clicked()
			edit_panel_state.set_autocap_enabled( not autocap_enabled )
			if autocap_enabled and edit_panel_state.get_force_compact_enabled() then
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
			end
		end
		GuiTooltip( gui, text_get_translated( autocap_enabled and "disable" or "enable" ) .. text_get_translated( "automatic_capacity" ), wrap_key( "automatic_capacity_description" ) )
		local function cant_undo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" )
			GuiTooltip( gui, text_get_translated( "cant_undo" ), "" )
		end
		local function cant_redo()
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
			GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" )
			GuiTooltip( gui, text_get_translated( "cant_redo" ), "" )
		end
		local operation_to_undo = edit_panel_state.peek_undo()
		local operation_to_redo = edit_panel_state.peek_redo()
		if operation_to_undo then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/undo.png" ) then
				sound_button_clicked()
				edit_panel_state.undo()
			end
			GuiTooltip( gui, text_get_translated( "undo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_undo ),
				GameTextGet( wrap_key( "current_history" ), edit_panel_state.get_current_history_index() ) )
		else cant_undo() end
		if operation_to_redo then
			if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/redo.png" ) then
				sound_button_clicked()
				edit_panel_state.redo()
			end
			GuiTooltip( gui, text_get_translated( "redo" ) .. " " .. GameTextGetTranslatedOrNot( operation_to_redo ),
				GameTextGet( wrap_key( "current_history" ), edit_panel_state.get_current_history_index() ) )
		else cant_redo() end
	end

	function do_gui()
		ctrl = InputIsKeyDown( Key_LCTRL ) or InputIsKeyDown( Key_RCTRL )
		shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
		alt = InputIsKeyDown( Key_LALT ) or InputIsKeyDown( Key_RALT )

		cached_mouse_x, cached_mouse_y = nil, nil

		now = GameGetFrameNum()
		id_offset = 0
		GuiStartFrame( gui )
		screen_width, screen_height = GuiGetScreenDimensions( gui )
		GuiIdPushString( gui, "spell_lab_shugged" )
		GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )
		GuiOptionsAdd( gui, GUI_OPTION.HandleDoubleClickAsClick )
		GuiOptionsAdd( gui, GUI_OPTION.ClickCancelsDoubleClick )

		world_state = GameGetWorldStateEntity()
		if EntityGetIsAlive( world_state ) then
			local comp_worldstate = EntityGetFirstComponent( world_state, "WorldStateComponent" )
			world_state_unlimited_spells = ComponentGetValue2( comp_worldstate, "perk_infinite_spells" )
		end

		player = get_player()
		held_wand = get_held_wand()

		dofile( "mods/spell_lab_shugged/files/gui/wand_listener.lua" )

		update_keyboard_input( listen_keyboard() )

		if selecting_mortal_to_transform then
			if shift then
				local error_msg = nil
				local mx, my = DEBUG_GetMouseWorld()
				local mortal_id = EntityGetClosestWithTag( mx, my, "mortal" )
				local mortal_x, mortal_y = EntityGetTransform( mortal_id )
				if not is_valid_entity( mortal_id ) or ( mx - mortal_x ) ^ 2 + ( my - mortal_y ) ^ 2 > 1600 then
					mortal_id = EntityGetClosestWithTag( mx, my, "enemy" )
					mortal_x, mortal_y = EntityGetTransform( mortal_id )
					if not is_valid_entity( mortal_id ) or ( mx - mortal_x ) ^ 2 + ( my - mortal_y ) ^ 2 > 1600 then
						error_msg = text_get_translated( "transform_mortal_failed_no_mortal_found" )
					end
				end
				if EntityHasTag( mortal_id, "player_unit" ) or EntityHasTag( mortal_id, "polymorphed_player" ) then
					error_msg = text_get_translated( "transform_mortal_failed_cant_transform_player" )
				end
				if EntityHasTag( mortal_id, "spell_lab_shugged_target_dummy" ) then
					error_msg = text_get_translated(  "transform_mortal_failed_already_transformed" )
				end
				if not error_msg then
					-- GameDropAllItems( mortal_id )
					local comp_names_to_disable = {
						"AnimalAIComponent",
						"PhysicsAIComponent",
						"FishAIComponent",
						"AdvancedFishAIComponent",
						"BossDragonComponent",
						"WormComponent",
						"WormAIComponent",
						"BossHealthBarComponent",
						"CameraBoundComponent",
					}
					for _, comp_name in ipairs( comp_names_to_disable ) do
						for _, c in ipairs( EntityGetComponent( mortal_id, comp_name ) or {} ) do
							EntitySetComponentIsEnabled( mortal_id, c, false )
						end
					end
					for _, ctrl_comp in ipairs( EntityGetComponentIncludingDisabled( mortal_id, "ControlsComponent" ) or {} ) do
						ComponentSetValue2( ctrl_comp, "enabled", false )
					end
					local cp_comp = EntityGetFirstComponentIncludingDisabled( mortal_id, "CharacterPlatformingComponent" )
					if cp_comp then
						for _, field_name in ipairs( {
							"velocity_min_x",
							"velocity_min_y",
							"velocity_max_x",
							"velocity_max_y",
							"pixel_gravity",
							"run_velocity",
							"fly_velocity_x",
							"fly_speed_up",
							"fly_speed_down",
						} ) do
							ComponentSetValue2( cp_comp, field_name, 0 )
						end
					end
					local cd_comp = EntityGetFirstComponentIncludingDisabled( mortal_id, "CharacterDataComponent" )
					if cd_comp then
						ComponentSetValue2( cd_comp, "mVelocity", 0, 0 )
					end
					for _, pbody_id in ipairs( PhysicsBodyIDGetFromEntity( mortal_id ) ) do
						PhysicsBodyIDSetGravityScale( pbody_id, 0 )
						local x, y, a = PhysicsBodyIDGetTransform( pbody_id )
						PhysicsBodyIDSetTransform( pbody_id, x, y, a, 0, 0 )
					end
					local dm_comp = EntityGetFirstComponentIncludingDisabled( mortal_id, "DamageModelComponent" )
					if dm_comp then
						ComponentSetValue2( dm_comp, "wait_for_kill_flag_on_death", true )
					end
					dm_comp = EntityGetFirstComponent( mortal_id, "DamageModelComponent" )
					if dm_comp then
						ComponentSetValue2( dm_comp, "wait_for_kill_flag_on_death", true )
					end
					EntityAddComponent2( mortal_id, "LuaComponent", {
						_tags="enabled_in_world",
						script_source_file = "mods/spell_lab_shugged/files/scripts/transformed_mortal_update.lua",
						execute_every_n_frame = 1,
					} )
					EntityLoadToEntity( "mods/spell_lab_shugged/files/entities/dummy_target/base_dummy_target.xml", mortal_id )
					EntityAddTag( mortal_id, "spell_lab_shugged_target_dummy" )
					GamePrint( GameTextGet( wrap_key( "transform_mortal_succeeded" ), GameTextGetTranslatedOrNot( EntityGetName( mortal_id ) ) ) )
				else
					GamePrint( error_msg )
				end
				selecting_mortal_to_transform = false
			end
		end

		if is_panel_open and not GameIsInventoryOpen() and player and not GameHasFlagRun( "gkbrkn_config_menu_open" ) then
			GuiLayoutBeginVertical( gui, 0, 360 * 0.02, true )
				GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )
					if GlobalsGetValue( "spell_lab_shugged_checkpoint", "0" ) == "0" then
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
					end
					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spell_lab_shugged.png" )
					do
						local left_click, right_click = previous_data( gui )
						if left_click then
							sound_button_clicked()
							if GlobalsGetValue( "spell_lab_shugged_checkpoint", "0" ) == "0" then
								local px, py = EntityGetTransform( player )
								GlobalsSetValue( "spell_lab_shugged_checkpoint", math.floor( px )..","..math.floor( py ) )
								EntityApplyTransform( player, 14600, -6050 )
								GameSetCameraPos( 14600, -6050 )
							else
								if not shift then
									local s = string_split( GlobalsGetValue( "spell_lab_shugged_checkpoint", "0" ), "," )
									local cx = tonumber( s[1] )
									local cy = tonumber( s[2] ) - 10
									EntityApplyTransform( player, cx, cy )
									GameSetCameraPos( cx, cy )
								else
									EntityApplyTransform( player, 250, -100 )
									GameSetCameraPos( 250, -100 )
								end
								GlobalsSetValue( "spell_lab_shugged_checkpoint", "0" )
							end
						elseif right_click then
							if GlobalsGetValue( "spell_lab_shugged_checkpoint", "0" ) ~= "0" then
								sound_button_clicked()
								EntityLoad( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
							end
						end
					end
					if GlobalsGetValue( "spell_lab_shugged_checkpoint", "0" ) == "0" then
						GuiTooltip( gui, wrap_key( "enter_spell_lab" ), "" )
					else
						GuiTooltip( gui, wrap_key( "leave_spell_lab" ), wrap_key( "reload_spell_lab" ) )
					end

					do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/edit_wands.png", PICKERS.SpellPicker, "spell_picker", function( showing )
						if showing and held_wand and mod_setting_get( "quick_spell_picker" ) then
							mod_setting_set( "show_wand_edit_panel", true )
						end
					end )
					do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/wand_spawner.png", PICKERS.WandPicker, "wand_spawner" )
					do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/wand_list.png", PICKERS.WandBox, "wand_box" )
					do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/spell_groups.png", PICKERS.SpellGroupBox, "spell_group_box", function( showing )
						if showing and held_wand then
							mod_setting_set( "show_wand_edit_panel", true )
						end
					end )
					do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/shot_effects.png", PICKERS.ShotEffects, "shot_effects" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/show_toggles.png", "show_toggle_options", "toggle_options" )
					do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/damage_info.png", "damage_info" )
					do
						local gif_mode = mod_setting_get( "gif_mode" )
						local description = wrap_key( gif_mode and "gif_mode_disable" or "gif_mode_enable" )
						local left_click, right_click = do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/show_wand_edit_panel.png", "show_wand_edit_panel", "wand_edit_panel", nil, description )
						if right_click then
							sound_button_clicked()
							mod_setting_set( "gif_mode", not gif_mode )
						end
					end
				GuiLayoutEnd( gui )

				GuiLayoutBeginHorizontal( gui, horizontal_centered_x(9,4), percent_to_ui_scale_y(2), true )
					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/shortcut_tips.png" )
					GuiTooltip( gui, wrap_key( "shortcut_tips_title" ), wrap_key( "shortcut_tips" ) )

					if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_projectiles.png" ) then
						sound_button_clicked()
						for k,v in pairs( EntityGetWithTag( "projectile" ) or {} ) do
							local projectile = EntityGetFirstComponent( v, "ProjectileComponent" )
							if projectile ~= nil then
								ComponentSetValue2( projectile, "on_death_explode", false )
								ComponentSetValue2( projectile, "on_lifetime_out_explode", false )
							end
							EntityKill(v)
						end
						for k,v in pairs( EntityGetWithTag( "player_projectile" ) or {} ) do
							local projectile = EntityGetFirstComponent( v, "ProjectileComponent" )
							if projectile ~= nil then
								ComponentSetValue2( projectile, "on_death_explode", false )
								ComponentSetValue2( projectile, "on_lifetime_out_explode", false )
							end
							EntityKill(v)
						end
					end
					GuiTooltip( gui, wrap_key( "clear_projectiles" ), "" )

					do
						local raw_value_key = "spell_lab_shugged.wand_cast_delay_fixed_to_raw_value"
						local cast_delay_key = "spell_lab_shugged.wand_cast_delay_fixed_to"
						local reload_time_key = "spell_lab_shugged.wand_reload_time_fixed_to"

						local fixed_to_raw_value = GlobalsGetValue( raw_value_key, "0" ) == "1"
						local cast_delay_fixed_to = tonumber( GlobalsGetValue( cast_delay_key, "" ) )
						local reload_time_fixed_to = tonumber( GlobalsGetValue( reload_time_key, "" ) )

						if fixed_to_raw_value or ( cast_delay_fixed_to and reload_time_fixed_to ) then
							local left_click, right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wait.png" )
							if left_click then
								if clear_held_wand_wait() then sound_button_clicked() end
							elseif right_click then
								if fixed_to_raw_value then
									GlobalsSetValue( raw_value_key, "" )
									sound_button_clicked()
								elseif cast_delay_fixed_to and reload_time_fixed_to then
									GlobalsSetValue( cast_delay_key, "" )
									GlobalsSetValue( reload_time_key, "" )
									sound_button_clicked()
								end
							end
							local _,_,_,x,y = previous_data( gui )
							if fixed_to_raw_value then
								local raw_value_text = GameTextGetTranslatedOrNot( wrap_key( "wand_raw_value" ) )
								GuiTooltip( gui, wrap_key( "wand_ready" ), GameTextGet( wrap_key( "wand_cast_delay_fixed_to" ), raw_value_text, raw_value_text ) )
							elseif cast_delay_fixed_to and reload_time_fixed_to then
								GuiTooltip( gui, wrap_key( "wand_ready" ), GameTextGet( wrap_key( "wand_cast_delay_fixed_to" ),
								format_time( cast_delay_fixed_to ), format_time( reload_time_fixed_to ) ) )
							end
							GuiZSetForNextWidget( gui, -1 )
							GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
							GuiImage( gui, next_id(), x - 2, y - 2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
						else
							local left_click, right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wait.png" )
							if shift and left_click then
								if held_wand then
									local ab_comp = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" )
									if ab_comp then
										local cast_delay = WANDS.ability_component_get_stat( ab_comp, "fire_rate_wait" )
										local reload_time = WANDS.ability_component_get_stat( ab_comp, "reload_time" )
										GlobalsSetValue( cast_delay_key, tostring( cast_delay ) )
										GlobalsSetValue( reload_time_key, tostring( reload_time ) )
										sound_button_clicked()
									end
								end
							elseif shift and right_click then
								GlobalsSetValue( cast_delay_key, "0" )
								GlobalsSetValue( reload_time_key, "0" )
								sound_button_clicked()
							elseif alt and ( left_click or right_click ) then
								GlobalsSetValue( raw_value_key, "1" )
								sound_button_clicked()
							elseif left_click then
								if clear_held_wand_wait() then sound_button_clicked() end
							end
						end
						GuiTooltip( gui, wrap_key( "wand_ready" ), wrap_key( "wand_ready_description" ) )
					end

					if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/clear_wand.png" ) then
						if held_wand then
							sound_button_clicked()
							access_edit_panel_state( held_wand ).set( "", wrap_key( "operation_clear_held_wand" ) )
						end
					end
					GuiTooltip( gui, wrap_key( "clear_held_wand" ), "" )

					local num_effects_positive = GameGetGameEffectCount( player, "EDIT_WANDS_EVERYWHERE" )
					local num_effects_negative = GameGetGameEffectCount( player, "NO_WAND_EDITING" )
					local wand_editing_level = num_effects_positive - num_effects_negative
					if wand_editing_level > 0 then
						GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/edit_wands_everywhere.png" )
					elseif wand_editing_level < 0 then
						GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/edit_wands_everywhere.png" )
					else
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
						GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/edit_wands_everywhere.png" )
					end
					do
						local left_click,right_click = previous_data( gui )
						if left_click then
							sound_button_clicked()
							local effect_to_remove = EntityGetWithTag( "spell_lab_shugged_effect_no_wand_editing" )[1]
							if effect_to_remove then
								EntityRemoveTag( effect_to_remove, "spell_lab_shugged_effect_no_wand_editing" )
								EntityRemoveFromParent( effect_to_remove )
								EntityKill( effect_to_remove )
							else
								local effect_id = EntityCreateNew()
								EntityAddChild( player, effect_id )
								EntityAddComponent2( effect_id, "GameEffectComponent", {
									effect = "EDIT_WANDS_EVERYWHERE",
									frames = -1,
								} )
								EntityAddTag( effect_id, "spell_lab_shugged_effect_edit_wands_everywhere" )
							end
						elseif right_click then
							sound_button_clicked()
							local effect_to_remove = EntityGetWithTag( "spell_lab_shugged_effect_edit_wands_everywhere" )[1]
							if effect_to_remove then
								EntityRemoveTag( effect_to_remove, "spell_lab_shugged_effect_edit_wands_everywhere" )
								EntityRemoveFromParent( effect_to_remove )
								EntityKill( effect_to_remove )
							else
								local effect_id = EntityCreateNew()
								EntityAddChild( player, effect_id )
								EntityAddComponent2( effect_id, "GameEffectComponent", {
									effect = "NO_WAND_EDITING",
									frames = -1,
								} )
								EntityAddTag( effect_id, "spell_lab_shugged_effect_no_wand_editing" )
							end
						end
					end
					do
						local a = #EntityGetWithTag( "spell_lab_shugged_effect_edit_wands_everywhere" )
						local b = #EntityGetWithTag( "spell_lab_shugged_effect_no_wand_editing" )
						local c = GameGetGameEffectCount( player, "EDIT_WANDS_EVERYWHERE" ) - a
						local d = GameGetGameEffectCount( player, "NO_WAND_EDITING" ) - b
						local t = { GameTextGet( wrap_key( "edit_wands_everywhere_lose" ), GameTextGetTranslatedOrNot( "$perk_edit_wands_everywhere" ) ) }
						if num_effects_positive > 0 then
							table.insert( t, GameTextGet( wrap_key( "edit_wands_everywhere_num" ), c, a, GameTextGetTranslatedOrNot( "$perk_edit_wands_everywhere" ) ) )
						end
						if num_effects_negative > 0 then
							table.insert( t, GameTextGet( wrap_key( "edit_wands_everywhere_num" ), d, b, GameTextGetTranslatedOrNot( "$perk_no_wand_editing" ) ) )
						end
						
						GuiTooltip( gui, GameTextGet( wrap_key( "edit_wands_everywhere_gain" ), GameTextGetTranslatedOrNot( "$perk_edit_wands_everywhere" ) ), table.concat( t, "\n" ) )
					end
					local hp_fixer = EntityGetWithName( "spell_lab_shugged_hp_fixer" )
					if hp_fixer ~= 0 then
						local hp_comp = get_variable_storage_component( hp_fixer, "hp" )
						local max_hp_comp = get_variable_storage_component( hp_fixer, "max_hp" )
						local hp_fixed_to = ComponentGetValue2( hp_comp, "value_float" )
						local max_hp_fixed_to = ComponentGetValue2( max_hp_comp, "value_float" )
						local _,right_click = GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/heart.png" )
						if right_click then
							sound_button_clicked()
							EntityKill( hp_fixer )
						end
						local _,_,_,x,y = previous_data( gui )
						GuiTooltip( gui, GameTextGet( wrap_key( "hp_fixed_to" ),
							format_damage( hp_fixed_to ), format_damage( max_hp_fixed_to ) ), "" )
						GuiZSetForNextWidget( gui, -1 )
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
						GuiImage( gui, next_id(), x - 2, y - 2, "mods/spell_lab_shugged/files/gui/locked.png", 1.0, 1.0, 0 )
					else
						if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/heart.png" ) then
							sound_button_clicked()
							if shift then
								EntityAddChild( player, EntityLoad( "mods/spell_lab_shugged/files/entities/hp_fixer.xml" ) )
							else
								local damage_model = EntityGetFirstComponentIncludingDisabled( player, "DamageModelComponent" )
								if damage_model then
									local max_hp = ComponentGetValue2( damage_model, "max_hp" )
									ComponentSetValue2( damage_model, "hp", max_hp )
								end
							end
						end
						GuiTooltip( gui, wrap_key( "full_hp" ), "" )
					end


					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spawn_target_dummy.png" )
					do
						local left_click,right_click = previous_data( gui )
						if left_click then
							sound_button_clicked()
							local x,y = get_player_or_camera_position()
							EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target.xml", x, y )
						elseif right_click then
							sound_button_clicked()
							local x,y = get_player_or_camera_position()
							EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target_final.xml", x, y )
						end
					end
					GuiTooltip( gui, wrap_key( "spawn_target_dummy" ), wrap_key( "spawn_target_dummy_description" ) )
					if not selecting_mortal_to_transform then
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
					end
					if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/transform_into_target_dummy.png" ) then
						sound_button_clicked()
						selecting_mortal_to_transform = not selecting_mortal_to_transform
					end
					GuiTooltip( gui, wrap_key( "transform_mortal_into_target_dummy" ), wrap_key( "transform_mortal_into_target_dummy_description" ) )

					GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spawn_convenient_wand.png" )
					do
						local left_click,right_click = previous_data( gui )
						local wand_data = {
							stats = {
								shuffle_deck_when_empty = false,
								actions_per_round = 1,
								fire_rate_wait = 10,
								reload_time = 20,
								mana_max = 100000,
								mana_charge_speed = 100000,
								capacity = 26,
								spread_degrees = 0,
								speed_multiplier = 1,
							},
							sprite = {
								file = "data/items_gfx/wands/wand_0821.png",
								hotspot = {
									x = 18.0,
									y = 0.0,
								},
								x = 4,
								y = 3,
							},
						}
						if left_click then
							sound_button_clicked()
							local x, y = get_player_or_camera_position()
							local wand = EntityLoad( "data/entities/items/wand_level_01.xml", x, y )
							WANDS.initialize_wand( wand, wand_data )
						elseif right_click and held_wand then
							sound_button_clicked()
							WANDS.initialize_wand( held_wand, wand_data, false )
						end
					end
					GuiTooltip( gui, wrap_key( "spawn_best_wand" ), wrap_key( "spawn_best_wand_description" ) )
				GuiLayoutEnd( gui )

				if mod_setting_get( "show_toggle_options" ) then
					GuiLayoutBeginHorizontal( gui, horizontal_centered_x(8,4), percent_to_ui_scale_y(2), true )
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_projectiles.png", "disable_casting" )
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_toxic_statuses.png", "disable_toxic_statuses", nil, nil, wrap_key( "disable_toxic_statuses_description" ) )
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/invincible.png", "invincible", "$status_protection_all" )
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/disable_polymorphing.png", "no_polymorphing", "$status_protection_polymorph" )
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/no_recoil.png", "no_recoil" )

						if not world_state_unlimited_spells then
							GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
						end
						if GuiImageButton( gui, next_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/unlimited_spells.png" ) then
							sound_button_clicked()
							if EntityGetIsAlive( world_state ) then
								local comp_worldstate = EntityGetFirstComponent( world_state, "WorldStateComponent" )
								ComponentSetValue2( comp_worldstate, "perk_infinite_spells", not world_state_unlimited_spells )
							end
							if not world_state_unlimited_spells then
								if not mod_setting_get( "zero_uses" ) then
									GameRegenItemActionsInPlayer( player )
								end
								local inventory2 = EntityGetFirstComponent( player, "Inventory2Component" )
								if inventory2 ~= nil then
									ComponentSetValue2( inventory2, "mForceRefresh", true )
									ComponentSetValue2( inventory2, "mActualActiveItem", 0 )
								end
							end
						end
						GuiTooltip( gui, text_get_translated( world_state_unlimited_spells and "disable" or "enable" ) .. text_get_translated( "$perk_unlimited_spells" ), "" )

						local desc = wrap_key( "creative_mode_flight_description" )
						if DebugGetIsDevBuild() then
							desc = GameTextGetTranslatedOrNot( desc ) .. "\n" .. text_get_translated( "creative_mode_flight_note_dev_exe" )
						end
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/creative_mode_flight.png", "creative_mode_flight", nil, nil, desc )
						do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/better_all_seeing_eye.png", "better_all_seeing_eye", "$perk_remove_fog_of_war" )
					GuiLayoutEnd( gui )
				end

				do_active_picker_buttons()

				if mod_setting_get( "damage_info" ) then
					dofile( "mods/spell_lab_shugged/files/gui/damage_info.lua" )
				end
			GuiLayoutEnd( gui )

			do_active_picker_menu()

			if mod_setting_get( "show_wand_edit_panel" ) then
				dofile( "mods/spell_lab_shugged/files/gui/edit_panel_shown.lua" )
			end
		else
			change_keyboard_focus( Focus_PlayerControls )
		end

		local mod_button_reservation = tonumber( GlobalsGetValue( "spell_lab_shugged_mod_button_reservation", "0" ) )
		local current_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_current", "0" ) )
		if current_button_reservation > mod_button_reservation then
			current_button_reservation = mod_button_reservation
		elseif current_button_reservation < mod_button_reservation then
			current_button_reservation = math.max( 0, mod_button_reservation + ( current_button_reservation - mod_button_reservation ) )
		else
			current_button_reservation = mod_button_reservation
		end
		GlobalsSetValue( "mod_button_tr_current", tostring( current_button_reservation + 15 ) )
		
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.AlwaysClickable )
		if GuiImageButton( gui, next_id(), screen_width - 14 - current_button_reservation, 2, "", "mods/spell_lab_shugged/files/gui/wrench.png" ) then
			sound_button_clicked()
			is_panel_open = not is_panel_open
		end
		
		do
			local mx, my = get_mouse_pos_on_screen()
			local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
			if x < mx and mx < x + width and y < my and my < y + height then
				local text = wrap_key( ( is_panel_open and "hide" or "show" ) .. "_spell_lab" )
				local text_width = GuiGetTextDimensions( gui, text )
				GuiZSetForNextWidget( gui, -100 )
				GuiLayoutBeginLayer( gui )
					GuiLayoutBeginVertical( gui, ( x + width - text_width - 24 ), ( y + 10 ), true )
						GuiBeginAutoBox( gui )
							GuiZSetForNextWidget( gui, -100 )
							GuiText( gui, 0, 0, text )
							GuiZSetForNextWidget( gui, -100 )
							GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1.0 )
							GuiText( gui, 0, 0, version )
						GuiZSetForNextWidget( gui, -99 )
						GuiEndAutoBoxNinePiece( gui )
					GuiLayoutEnd( gui )
				GuiLayoutEndLayer( gui )
			end
		end

		GuiIdPop( gui )
	end
	print("[spell lab] done setting up GUI")
end

do_gui()