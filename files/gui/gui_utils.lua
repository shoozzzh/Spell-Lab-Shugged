local gui_z = 0
do
	local old_GuiZSet = GuiZSet
	function GuiZSet( gui, z )
		gui_z = gui_z + z
		old_GuiZSet( gui, gui_z )
	end

	local old_GuiZSetForNextWidget = GuiZSetForNextWidget
	function GuiZSetForNextWidget( gui, z )
		old_GuiZSetForNextWidget( gui, gui_z + z )
	end
end
function reset_z()
	gui_z = 0
end

local cache_frame
local cached_mouse_x, cached_mouse_y
function get_mouse_pos_on_screen()
	if now ~= cache_frame or not cached_mouse_x or not cached_mouse_y then
		cached_mouse_x, cached_mouse_y = get_screen_position( DEBUG_GetMouseWorld() )
		cache_frame = now
	end
	return cached_mouse_x, cached_mouse_y
end

function percent_to_ui_scale_y( y )
	return y * screen_height / 100
end

function horizontal_centered_x( buttons_num, offset )
	offset = offset or 0
	return screen_width / 2 - ( ( buttons_num - offset ) * 22 + 2 ) / 2
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

function previous_data( gui )
	return GuiGetPreviousWidgetInfo( gui )
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

function previous_hovered( margin )
	margin = margin or 0
	local mx, my = get_mouse_pos_on_screen()
	local _,_,_,x,y,width,height,_,_,_,_ = previous_data( gui )
	return -margin + x < mx and mx < x + width + margin and -margin + y < my and my < y + height + margin
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

local ID_GAP = 64
local id_remainder_table = {}
local next_id_remainder = 1

-- to avoid any id confliction
function do_content_wrapped( content_fn, push_this_string )
	local id_offset = id_remainder_table[ push_this_string ]
	if not id_offset then
		id_offset = next_id_remainder
		id_remainder_table[ push_this_string ] = next_id_remainder
		next_id_remainder = next_id_remainder + 1
	end
	local peek_next_id = function()
		return id_offset
	end
	local next_id = function()
		id_offset = id_offset + ID_GAP
		return id_offset
	end

	local e = getfenv( content_fn )
	e.id_offset = id_offset
	e.peek_next_id = peek_next_id
	e.next_id = next_id
	setfenv( content_fn, e )

	GuiIdPushString( gui, push_this_string )
	content_fn()
	GuiIdPop( gui )
end

-- usage: detect_shortcuts( gui, { [{"Mouse_left"}] = xxx, [{"Mouse_right"}] = yyy, } )
function detect_shortcuts( gui, shortcutz, detection_range, left_click, right_click, hover, args )
	local _left_click, _right_click, _hover = previous_data( gui )
	if left_click == nil then left_click = _left_click end
	if right_click == nil then right_click = _right_click end
	if hover == nil then hover = _hover end

	if not hover then return end

	for shortcut, do_what in pairs( shortcutz ) do
		if shortcut_detector.is_fired( shortcut, left_click, right_click, detection_range ) then
			do_what( unpack( args ) )
			return
		end
	end
end