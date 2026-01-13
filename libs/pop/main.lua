local this_path = jit.util.funcinfo( setfenv( 1, getfenv() ) ).source:match( "^.*/" )

local gui = GuiCreate()

local const = dofile_once( this_path .. "constants.lua" )
local pc = dofile_once( this_path .. "pos_convert.lua" )

-- had given up on lsp-ing this
local function new_prop()
	local prop = {
		stack = {},
		next_value = nil,
	}

	function prop.next( p )
		prop.next_value = p
	end

	function prop.push( p )
		prop.stack[ #prop.stack + 1 ] = p
	end

	function prop.pop()
		prop.stack[ #prop.stack ] = nil
	end

	function prop.get()
		local result = prop.next_value
		prop.next_value = nil

		if result == nil then
			result = prop.stack[ #prop.stack ]
		end

		return result
	end

	return prop
end

---@class font
---@field file string
---@field is_pixel bool

---@class image_xform
---@field alpha number?
---@field scale number?
---@field scale_y number?
---@field rotation number?

---@class image_animation
---@field playback_type playback_type?
---@field name string?

---@class pop
local pop = {
	gui_obj = gui,
	screen_size = { 1260, 720 },
	options = const.options,
	playback_types = const.playback_types,
	z = 0,
	call_depth = 0,
	call_depth_next = nil,
	---@class prop_font
	---@field next fun( font: font )
	---@field push fun( font: font )
	---@field pop fun()
	---@field get fun(): font?
	font = new_prop(),
	---@class prop_image_xform
	---@field next fun( image_xform: image_xform )
	---@field push fun( image_xform: image_xform )
	---@field pop fun()
	---@field get fun(): image_xform?
	image_xform = new_prop(),
	---@class prop_image_animation
	---@field next fun( image_animation: image_animation )
	---@field push fun( image_animation: image_animation )
	---@field pop fun()
	---@field get fun(): image_animation?
	image_animation = new_prop(),
	text_line_height = 6,
	---@type dragging_data?
	dragging = nil,
}

local id_allocator = dofile( this_path .. "id_allocator.lua" )
local function get_id()
	local extra_call_depth = 2 + pop.call_depth
	if pop.call_depth_next then
		extra_call_depth = extra_call_depth + pop.call_depth_next
		pop.call_depth_next = nil
	end
	return id_allocator.get_id( extra_call_depth )
end

function pop.call_depth_mod( mod )
	pop.call_depth = pop.call_depth + mod
end

function pop.next_call_depth_mod( mod )
	pop.next_call_depth = mod
end

local option_list = {}
---@type table<gui_option,bool>
pop.option = setmetatable( {}, {
	__newindex = function( t, k, v )
		local option = const.options[ k ]
		if not option then
			print_error( ('Option "%s" doesn\'t exist'):format( k ) )
			return
		end
		if v then
			GuiOptionsAdd( gui, option )
		else
			GuiOptionsRemove( gui, option )
		end
		option_list[ k ] = v
	end,
	__index = function( t, k )
		return option_list[ k ]
	end
} )

function pop.option_clear()
	option_list = {}
	GuiOptionsClear( gui )
end

function pop.start_frame()
	GuiStartFrame( gui )
	id_allocator.new_frame()
	pop.screen_size = { GuiGetScreenDimensions( gui ) }
	pop.z = 0
	pop.option_clear()
	_, pop.text_line_height = GuiGetTextDimensions( gui, "|" )
end

---@param option gui_option
function pop.option_next( option )
	local option_val = const.options[ option ]
	if option_val then
		GuiOptionsAddForNextWidget( gui, option_val )
	else
		print_error( ('Option "%s" doesn\'t exist'):format( option ) )
	end
	return pop.option_next
end

---@class color
---@field r integer
---@field g integer
---@field b integer
---@field a integer

local function h2d( h )
	return ( h + 1 ) / 256
end

---@param color color
function pop.color_next( color )
	GuiColorSetForNextWidget( gui, h2d( color.r ), h2d( color.g ), h2d( color.b ), h2d( color.a ) )
end

function pop.z_mod( modifier )
	pop.z = pop.z + modifier
	GuiZSet( gui, pop.z )
end

function pop.z_mod_next( modifier )
	GuiZSetForNextWidget( gui, pop.z + modifier )
end

function pop.animate_begin()
	GuiAnimateBegin( gui )
	return true
end

function pop.animate_end()
	GuiAnimateEnd( gui )
end

function pop.animate_fade_in( speed, step, reset )
	GuiAnimateAlphaFadeIn( gui, get_id(), speed, step, reset)
end

function pop.animate_scale_in( acceleration, reset )
	GuiAnimateScaleIn( gui, get_id(), acceleration, reset )
end

---@param x number
---@param y number
---@param text string
function pop.text( x, y, text )
	local font_file, is_pixel

	local font = pop.font:get()
	if font then
		font_file, is_pixel = unpack( font )
	end

	-- scaling text is a lie in noita gui
	GuiText( gui, x, y, text, 1, font_file or "", is_pixel )
end

---@param x number
---@param y number
---@param sprite_filename string
function pop.image( x, y, sprite_filename )
	local alpha, scale, scale_y, rotation = 1, 1, 0, nil
	local playback_type, animation_name

	local xform = pop.image_xform:get()
	if xform then
		alpha, scale, scale_y, rotation = xform.alpha, xform.scale, xform.scale_y, xform.rotation
	end

	local animation = pop.image_animation:get()
	if animation then
		playback_type, animation_name = animation.playback_type, animation.name
	end

	GuiImage( gui, get_id(), x, y, sprite_filename, alpha, scale, scale_y, rotation, playback_type, animation_name or "" )
end

---@param x number
---@param y number
---@param sprite_filename string
---@param width number
---@param height number
function pop.image_9piece( x, y, sprite_filename, width, height )
	GuiImageNinePiece( gui, get_id(), x, y, width, height, 1, sprite_filename, sprite_filename )
end

---@param x number
---@param y number
---@param text string
---@return bool
---@return bool
function pop.text_button( x, y, text )
	local font_file, is_pixel

	local font = pop.font:get()
	if font then
		font_file, is_pixel = unpack( font )
	end

	return GuiButton( gui, get_id(), x, y, text, 1, font_file or "", is_pixel )
end

---@param x number
---@param y number
---@param sprite_filename string
---@return bool
---@return bool
function pop.button( x, y, sprite_filename )
	return GuiImageButton( gui, get_id(), x, y, "", sprite_filename )
end

---@param x number
---@param y number
---@param value number
---@param width number
---@return number
function pop.slider( x, y, value, width )
	return GuiSlider( gui, get_id(), x, y, "", value, 0, 1, value, 0, "", width )
end

function pop.input_text( x, y, value, width, max_length, allowed_chars )
	return GuiTextInput( gui, get_id(), x, y, value, width, max_length, allowed_chars )
end

function pop.input_any_text( x, y, value, width, max_length )
	return GuiTextInput( gui, get_id(), x, y, value, width, max_length, "" )
end

function pop.input_int( x, y, value, width, max_length )
	local old_text = ("%.0f"):format( value )
	local new_text = GuiTextInput( gui, get_id(), x, y, old_text, width, max_length, "0123456789+-" )
	return tonumber( new_text )
end

function pop.input_float( x, y, value, width, max_length )
	local old_text = ("%.3f"):format( value )
	local new_text = GuiTextInput( gui, get_id(), x, y, old_text, width, max_length, "0123456789+-." )
	return tonumber( new_text )
end

function pop.autobox_begin()
	GuiBeginAutoBox( gui )
	return true
end

function pop.autobox_end( sprite_filename, margin, min_width, min_height )
	GuiEndAutoBoxNinePiece( gui, margin, min_width, min_height, false, 0, sprite_filename, sprite_filename )
end

-- no we don't use vanilla tooltip function

local function tooltip( content_fn, x, y )
	pop.call_depth_mod(1)
	GuiLayoutBeginLayer( gui )
	GuiBeginAutoBox( gui )
	content_fn( x, y )
	pop.z_mod_next(1)
	GuiEndAutoBoxNinePiece( gui )
	GuiLayoutEndLayer( gui )
	pop.call_depth_mod(-1)
end

function pop.tooltip( ... )
	local text = { ... }

	pop.tooltip_custom( 2, 0, true )( function( x, y )
		for _, line in ipairs( text ) do
			line = GameTextGetTranslatedOrNot( line )
			for t in string.gmatch( line or "", "[^\n]+" ) do
				pop.text( x, y, t )
				y = y + pop.text_line_height
			end
		end
	end )
end

local function autobox_size( content_fn )
	if pop.invis_begin() then
		tooltip( content_fn, 0, 0 )
		pop.invis_end()
	end

	return pop.prev_size()
end

local function show_tooltip_custom( callback, x_min, x_max, x_offset, y, animated )
	if not callback then return end
	x_offset = x_offset or 0

	local _, tooltip_height = autobox_size( callback )

	local x_mid = ( x_min + x_max ) / 2

	local align_left = x_mid > pop.screen_size[1] / 2
	local old_align_Left
	if align_left then
		old_align_Left = pop.option.Align_Left
		pop.option.Align_Left = true
	end

	local x
	x_offset = x_offset + 5 + 2
	if align_left then
		x = x_min
		x = x - x_offset
	else
		x = x_max
		x = x + x_offset
	end

	if y + tooltip_height > pop.screen_size[2] then
		y = pop.screen_size[2] - tooltip_height
	end

	pop.z_mod(-1024)

	if animated then
		pop.animate_begin()
		pop.animate_fade_in( 0.08, 0.1, false )
		pop.animate_scale_in( 0.08, false )
	end

	tooltip( callback, x, y )

	if animated then
		pop.animate_end()
	end

	pop.z_mod(1024)

	if align_left then
		pop.option.Align_Left = old_align_Left
	end
end

function pop.tooltip_custom( x_offset, y_offset, animated )
	return function( content_fn )
		if not pop.prev_hovered() then return end
		local x, y = pop.prev_pos()
		local width, _ = pop.prev_size()
		show_tooltip_custom( content_fn, x, x + width, x_offset, y + y_offset, animated )
	end
end

---@param margin_x number? 2
---@param margin_y number? 2
function pop.scroll_box_begin( x, y, width, height, margin_x, margin_y )
	GuiBeginScrollContainer( gui, get_id(), x, y, width, height, true, margin_x, margin_y )
end

function pop.scroll_box_end()
	GuiEndScrollContainer( gui )
end

function pop.invis_begin()
	GuiAnimateBegin( gui )
	GuiAnimateAlphaFadeIn( gui, get_id(), 0, 0, true )
	return true
end

function pop.invis_end()
	GuiAnimateEnd( gui )
end

-- dimension getters don't belong to a gui wrapper

function pop.prev_clicked()
	local left_clicked, right_clicked = GuiGetPreviousWidgetInfo( gui )
	return left_clicked, right_clicked
end

function pop.prev_hovered()
	local _, _, hovered = GuiGetPreviousWidgetInfo( gui )
	return hovered
end

function pop.prev_pos()
	local _, _, _, x, y = GuiGetPreviousWidgetInfo( gui )
	return x, y
end

function pop.prev_size()
	local _, _, _, _, _, width, height = GuiGetPreviousWidgetInfo( gui )
	return width, height
end

---@param margin number?
---@return boolean
local function mouse_inside_area( x, y, width, height, margin )
	margin = margin or 0
	local mx, my = pc.world_to_screen( DEBUG_GetMouseWorld() )
	return -margin + x < mx and mx < x + width + margin and -margin + y < my and my < y + height + margin
end

---@param margin number?
---@return boolean
function pop.prev_mouse_inside( margin )
	local x, y = pop.prev_pos()
	local width, height = pop.prev_size()
	return mouse_inside_area( x, y, width, height, margin )
end

function pop.block_mousewheel()
	local mx, my = pc.world_to_screen( DEBUG_GetMouseWorld() )
	if pop.invis_begin() then
		pop.option_next "Layout_NoLayouting" "AlwaysClickable"
		GuiBeginScrollContainer( gui, get_id(), mx - 25, my - 25, 50, 50, false, 0, 0 )
		GuiEndScrollContainer( gui )
		pop.invis_end()
	end
end

function pop.matrix( x, y, cell_2dlist, cell_width, cell_height, cell_gui_func )
	for _, row in ipairs( cell_2dlist ) do
		for _, cell in ipairs( row ) do
			cell_gui_func( x, y, cell )
			x = x + cell_width
		end
		y = y + cell_height
	end
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return number x
---@return number y
---@return bool dragging
function pop.draggable_space( x, y, width, height, use_right_click )
	local id = get_id()
	local keycode = 1
	if use_right_click then
		keycode = 2
	end
	if not pop.dragging then
		if InputIsMouseButtonJustDown( keycode ) and mouse_inside_area( x, y, width, height ) then
			local mx, my = pc.world_to_screen( DEBUG_GetMouseWorld() )
			---@class dragging_data
			pop.dragging = {
				id = id,
				pos_x = mx - x,
				pos_y = my - y,
			}
			return x, y, true
		end
		return x, y, false
	elseif pop.dragging.id == id then
		local mx, my = pc.world_to_screen( DEBUG_GetMouseWorld() )
		x, y = mx - pop.dragging.pos_x, my - pop.dragging.pos_y

		if not InputIsMouseButtonDown( keycode ) then
			pop.dragging = nil
		end

		return x, y, true
	end
	return x, y, false
end

return pop
