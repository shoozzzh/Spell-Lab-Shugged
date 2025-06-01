SCROLL_TABLE_WIDTH = 174
function do_scroll_table( scroll_id, width, height, height_autofit, hover_callback, cell_list, cell_gui_func, row_size )
	row_size = row_size or 8
	width = width or SCROLL_TABLE_WIDTH
	if height_autofit then
		local num_rows = math.max( 1, math.ceil( #cell_list / row_size ) )
		height = math.min( num_rows * 20, height or 160 )
	end
	height = math.max( height, 20 )
	local _x, _y

	GuiBeginScrollContainer( gui, scroll_id, 0, 0, width, height )
		do
			local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
			_x, _y = x, y
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
	return _x, _y, width, height
end

function do_flag_toggle_image_button( filepath, flag, option_text, click_callback, description )
	local mod_settings_key = wrap_setting_key( flag )
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

function do_action_button( action_id, x, y, selected, tooltip_func, uses_remaining, note, extra_gui, empty_slot_show_tooltip, no_title )
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	local image_sprite = "mods/spell_lab_shugged/files/gui/buttons/empty_spell.png"
	local this_action_data =  action_data[action_id]
	local left_click,right_click,hover
	local spell_box_suffix = ""

	GuiLayoutBeginHorizontal( gui, 0, 0 )
	
	if this_action_data then spell_box_suffix = spell_box_suffix .. "_" .. this_action_data.type end
	if this_action_data then
		image_sprite = this_action_data.sprite
	end
	local this_action_metadata = action_metadata[ action_id ]

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
					GuiDimText( gui, 0, 0, note )
				end
			GuiLayoutEnd( gui )
		end, 2, -2 ) -- make it looks as if it belongs to the spell box
	end

	GuiZSetForNextWidget( gui, 1 )
	GuiImage( gui, next_id(), -20, 0, "mods/spell_lab_shugged/files/gui/buttons/spell_box"..spell_box_suffix..".png", 1.0, 1.0, 0 )
	if extra_gui then
		local _,_,_,x,y,_,_,_,_,_,_ = previous_data( gui )
		extra_gui( x, y, this_action_data, uses_remaining )
	end

	GuiLayoutEnd( gui )

	if left_click or right_click then
		sound_action_button_clicked()
	end
	return left_click, right_click
end

function do_fake_action_button( action_type, action_sprite, name, id, desc, type, semi_transparent, uses_remaining, properties )
	GuiLayoutBeginHorizontal( gui, 0, 0 )

	GuiImageButton( gui, next_id(), 2, 2, "", "mods/spell_lab_shugged/files/gui/buttons/transparent_16x16.png" )
	
	local left_click, right_click,hover,x1,y1 = previous_data( gui )
	do_custom_tooltip( function()
		GuiLayoutBeginVertical( gui, 0, 0, true )
			GuiText( gui, 0, 0, name )
			if id then
				GuiDimText( gui, 0, 0, id )
			end
			if type then
				GuiColoredText( gui, 0.5, 0.5, 1.0, 1.0, 0, 0, type )
			end
			GuiText( gui, 0, 0, desc )
			if properties and #properties > 0 then
				GuiLayoutAddVerticalSpacing( gui, 5 )
				do_property_list( properties )
			end
		GuiLayoutEnd( gui )
	end, 2, -2 )
	
	local sprite_width, sprite_height = GuiGetImageDimensions( gui, action_sprite )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	if semi_transparent then
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
	end
	GuiImageButton( gui, next_id(), x1 - 2 + ( 20 - sprite_width ) / 2, y1 - 2 + ( 20 - sprite_height ) / 2, "", action_sprite, 1 )

	GuiZSetForNextWidget( gui, 1 )
	if semi_transparent then
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawSemiTransparent )
	end
	local spell_box_suffix = tostring( action_type or ACTION_TYPE_PROJECTILE )
	if hover then
		spell_box_suffix = spell_box_suffix .. "_hover"
	end
	GuiImage( gui, next_id(), --[[-( 2 + sprite_width / 2 + 10 )]]-20, 0, "mods/spell_lab_shugged/files/gui/buttons/spell_box_"..spell_box_suffix..".png", 1.0, 1.0, 0 )
	if uses_remaining then
		show_uses_remaining( x1, y1, nil, uses_remaining )
	end

	GuiLayoutEnd( gui )

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

function show_uses_remaining( x, y, _, uses_remaining, scale )
	if not uses_remaining or tonumber( uses_remaining ) < 0 then return end
	scale = scale or 1
	local offset = -2 * scale
	x, y = x + offset, y + offset
	GuiZSetForNextWidget( gui, -1 )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiText( gui, x, y, tostring( uses_remaining ), scale, "data/fonts/font_pixel_noshadow.xml", true )
end

function do_property_list( lines )
	for _, p in ipairs( lines ) do
		local name = p[1]
		local value = p[2]
		GuiLayoutBeginHorizontal( gui, 0, 0 )
			GuiColoredText( gui, 0.811, 0.811, 0.811, 1.0, 0, 0, name )
			local _,_,_,_,_,width,_,_,_,_,_ = previous_data( gui )
			GuiColoredText( gui, 1.0, 0.75, 0.5, 1.0, 72 - width, 0, tostring( value ) )
		GuiLayoutEnd( gui )
		GuiLayoutAddVerticalSpacing( gui, -2 )
	end
end

function do_least_tooltip( this_action_data, this_action_metadata )
	GuiDimText( gui, 0, 0, this_action_data.id )
	GuiColoredText( gui, 0.5, 0.5, 1.0, 1.0, 0, 0, GameTextGetTranslatedOrNot( type_text[ this_action_data.type ] ) )
end

function do_verbose_tooltip( this_action_data, this_action_metadata )
	local c_lines = c_metadata_to_lines( this_action_metadata.c )
	local projectiles_lines, num_proj_lines = proj_metadata_to_lines( this_action_metadata.projectiles )
	
	local title = GameTextGetTranslatedOrNot( this_action_data.name )
	if this_action_data.max_uses then
		title = title .. ( "(" .. tostring( this_action_data.max_uses ) .. ")" )
	end
	GuiText( gui, 0, 0, title )
	
	GuiDimText( gui, 0, 0, this_action_data.id )
	GuiColoredText( gui, 0.5, 0.5, 1.0, 1.0, 0, 0, GameTextGetTranslatedOrNot( type_text[ this_action_data.type ] ) )
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

function show_tooltip( content_fn, x, y )
	GuiLayoutBeginLayer( gui )
		GuiLayoutBeginVertical( gui, x, y, true )
			GuiBeginAutoBox( gui )
				content_fn()
				GuiZSetForNextWidget( gui, 1 )
			GuiEndAutoBoxNinePiece( gui )
		GuiLayoutEnd( gui )
	GuiLayoutEndLayer( gui )
end

function GuiTooltip( gui, ... )
	local texts = { ... }
	do_custom_tooltip( function()
		GuiLayoutBeginVertical( gui, 0, 0 )
			local is_first = true
			for i, text in ipairs( texts ) do
				text = GameTextGetTranslatedOrNot( text )
				for t in string.gmatch( text or "", "[^\n]+" ) do
					if is_first then
						is_first = false
					else
						GuiLayoutAddVerticalSpacing( gui, 2 )
					end
					GuiText( gui, 0, 0, t )
				end
			end
		GuiLayoutEnd( gui )
	end, 2, 0, true )
end

local function autobox_size( content_fn )
	local id_offset = 0
	local function next_id()
		id_offset = id_offset + 1
		return id_offset
	end

	GuiIdPushString( gui, "INVISIBLE_TOOLTIP" )

	GuiAnimateBegin( gui )
	GuiAnimateAlphaFadeIn( gui, next_id(), 0, 0, false )

	show_tooltip( content_fn, 0, 0 )

	GuiAnimateEnd( gui )

	GuiIdPop( gui )

	local _,_,_,_,_,width,height,draw_x,draw_y,draw_width,draw_height = previous_data( gui )
	return width, height
end

function do_custom_tooltip( callback, x_offset, y_offset, animated )
	if not callback then return end
	x_offset = x_offset or 0
	y_offset = y_offset or 0

	local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = previous_data( gui )
	if not hover then return end

	local tooltip_width, tooltip_height = autobox_size( callback )

	GuiIdPushString( gui, "TOOLTIP" )

	if animated then
		GuiAnimateBegin( gui )
		GuiAnimateAlphaFadeIn( gui, 2 * peek_next_id(), 0.08, 0.1, false )
		GuiAnimateScaleIn( gui, 2 * peek_next_id() + 1, 0.08, false )
	end

	GuiZSet( gui, -1024 )

	local align_left = x + width / 2 > screen_width / 2 
	if align_left then
		GuiOptionsAdd( gui, GUI_OPTION.Align_Left )
	end

	x_offset = x_offset + 5 + 2
	if align_left then
		x_offset = -x_offset
	else
		x_offset = x_offset + width
	end

	if y + y_offset + tooltip_height > screen_height then
		y_offset = y_offset - ( y + y_offset + tooltip_height - screen_height )
	end

	show_tooltip( callback, x + x_offset, y + y_offset )

	if align_left then
		GuiOptionsRemove( gui, GUI_OPTION.Align_Left )
	end

	GuiZSet( gui, 1024 )

	if animated then
		GuiAnimateEnd( gui )
	end

	GuiIdPop( gui )
end

local function show_simple_action_image( action_id, uses_remaining )
	if action_id and action_id ~= "" then
		local this_action_data = action_data[ action_id ]
		local sprite = ( this_action_data and this_action_data.sprite ) and this_action_data.sprite or "data/ui_gfx/gun_actions/_unidentified.png"
		GuiZSetForNextWidget( gui, -1 )
		GuiImage( gui, next_id(), 0, 0, sprite, 1.0, 0.5, 0 )
		GuiImage( gui, next_id(), -11, -1, "mods/spell_lab_shugged/files/gui/buttons/spell_box.png", 1.0, 0.5, 0 )
	else
		GuiImage( gui, next_id(), -1, -1, "mods/spell_lab_shugged/files/gui/buttons/spell_box.png", 1.0, 0.5, 0 )
	end
	GuiZSet( gui, -1 )
	local _,_,_,x,y = previous_data( gui )
	show_uses_remaining( x, y, nil, uses_remaining, 0.5 )
	GuiZSet( gui, 1 )
end

function do_simple_action_list( all_actions )
	local common_actions = {}
	local permanent_actions = {}
	local max_x = 0
	for _, a in ipairs( all_actions ) do
		if a.permanent then
			table.insert( permanent_actions, a.action_id )
		else
			if a.x ~= 0 then
				common_actions[ a.x + 1 ] = { a.action_id, a.uses_remaining }
				max_x = math.max( max_x, a.x + 1 )
			else
				common_actions[ max_x + 1 ] = { a.action_id, a.uses_remaining }
				max_x = max_x + 1
			end
		end
	end
	do_simple_permanent_action_list( permanent_actions )
	do_simple_common_action_list( common_actions, max_x )
end

function do_simple_permanent_action_list( permanent_actions )
	if #permanent_actions == 0 then return end
	GuiLayoutBeginHorizontal( gui, 0, 0 )
	for _,permanent_action in pairs( permanent_actions ) do
		show_simple_action_image( permanent_action )
	end
	GuiLayoutEnd( gui )
	GuiLayoutAddVerticalSpacing( gui, 1 )
end

function do_simple_common_action_list( common_actions, max_x )
	if max_x <= 0 then return end
	local actions_per_row = 26
	for i = 1, max_x do
		if i % actions_per_row == 1 then
			GuiLayoutBeginHorizontal( gui, 0, 0 )
		end
		show_simple_action_image( unpack( common_actions[ i ] or {} ) )
		if i % actions_per_row == 0 or i == max_x then
			GuiLayoutEnd( gui )
		end
	end
end

function do_flat_action_list( actions )
	for _,action_id in ipairs( actions ) do
		local this_action_data = action_data[action_id]
		if this_action_data then GuiImage( gui, next_id(), 0, 0, this_action_data.sprite, 1.0, 0.5, 0 ) end
	end
end

function do_wand_stats( gui, stats )
	for _, v in ipairs( wand_stats ) do
		if stats[ v.stat ] then
			GuiLayoutBeginHorizontal( gui, 0, 0 )
				GuiText( gui, 0, 0, v.label )
				local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = previous_data( gui )
				GuiColoredText( gui, 1.0, 0.75, 0.5, 1.0, 72 - width, 0, v.text_callback( stats[ v.stat ] ) )
			GuiLayoutEnd( gui )
			GuiLayoutAddVerticalSpacing( gui, -4 )
		end
	end
end