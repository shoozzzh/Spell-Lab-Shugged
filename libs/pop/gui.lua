local this_path = jit.util.funcinfo( setfenv( 1, getfenv() ) ).source:match( "^.*/" )

local gui = GuiCreate()

local constants = dofile_once( this_path .. "constants.lua" )

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
	options = constants.options,
	playback_types = constants.playback_types,
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

function pop.start_frame()
	GuiStartFrame( gui )
	id_allocator.new_frame()
	pop.screen_size = { GuiGetScreenDimensions( gui ) }
end

function pop.call_depth_mod( mod )
	pop.call_depth = pop.call_depth + mod
end

function pop.next_call_depth_mod( mod )
	pop.next_call_depth = mod
end

function pop.option_add( option )
	GuiOptionsAdd( gui, option )
end

function pop.option_remove( option )
	GuiOptionsRemove( gui, option )
end

function pop.option_clear()
	GuiOptionsClear( gui )
end

function pop.next_option( option )
	GuiOptionsAddForNextWidget( gui, option )
end

function pop.next_color( red, green, blue, alpha )
	GuiColorSetForNextWidget( gui, red, green, blue, alpha )
end

function pop.z_mod( modifier )
	GuiZSet( gui, pop.z + modifier )
end

function pop.next_z_mod( modifier )
	GuiZSetForNextWidget( gui, modifier )
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

function pop.text( x, y, text )
	local font_file, is_pixel

	local font = pop.font:get()
	if font then
		font_file, is_pixel = unpack( font )
	end

	-- scaling text is a lie in noita gui
	GuiText( gui, x, y, text, 1, font_file, is_pixel )
end

function pop.text_centered( x, y, text )
	pop.next_option( pop.options.Align_HorizontalCenter )
	pop.text( x, y, text )
end

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

	GuiImage( gui, get_id(), x, y, sprite_filename, alpha, scale, scale_y, rotation, playback_type, animation_name )
end

function pop.image_9piece( x, y, sprite_filename, width, height )
	GuiImageNinePiece( gui, get_id(), x, y, width, height, 1, sprite_filename, sprite_filename )
end

function pop.text_button( x, y, text )
	local font_file, is_pixel

	local font = pop.font:get()
	if font then
		font_file, is_pixel = unpack( font )
	end

	return GuiButton( gui, get_id(), x, y, text, 1, font_file, is_pixel )
end

function pop.button( x, y, sprite_filename )
	return GuiImageButton( gui, get_id(), x, y, "", sprite_filename )
end

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

---@param margin_x number? 2
---@param margin_y number? 2
function pop.scroll_box_begin( x, y, width, height, margin_x, margin_y )
	GuiBeginScrollContainer( gui, get_id(), x, y, width, height, true, margin_x, margin_y )
end

function pop.scroll_box_end()
	GuiEndScrollContainer( gui )
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
