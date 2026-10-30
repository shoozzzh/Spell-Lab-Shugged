local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
    return dofile_once(path .. module_name:sub(5) .. ".lua")
end
local gui = GuiCreate()

local const = require "pop.constants"
local pc = require "pop.pos_convert"
local id_allocator = require "pop.id_allocator"

---@class pop
local pop = {
    gui_obj = gui,
    screen_size = { 1260, 720 },
    text_line_height = 6,
    ---@type dragging_data?
    dragging = nil,
}

setmetatable(pop, {
    __gc = function(t)
        GuiDestroy(t.gui_obj)
    end,
})

---@alias pop.layer
---| "BACKGROUND"
---|>"MID"
---| "FOREGROUND"
---| "TOOLTIP"
---| "DEBUG"

---@class pop.z
pop.z = {
    --TODO: Adjust these values with the depthes of vanilla gui in mind
    ---@type table<pop.layer, number>
    layer_base_z = {
        BACKGROUND = 100,
        MID = 0,
        FOREGROUND = -100,
        TOOLTIP = -200,
        DEBUG = -2000,
    },
    step = -0.01,
    ---@type table<pop.layer, number>
    layer_next_z = {},
    ---@type pop.layer
    layer_cur = "MID",
    new_frame = function(self)
        self.layer_cur = "MID"

        local t = {}
        for k, v in pairs(self.layer_base_z) do
            t[k] = v
        end
        self.layer_next_z = t
    end,
    ---@return number z
    get = function(self)
        local res = self.layer_next_z[self.layer_cur]
        self.layer_next_z[self.layer_cur] = res + self.step
        return res
    end,
}
pop.z:new_frame() -- initialize pop.z.layer_next_z

---@class pop.pos
pop.pos = {
    stack = {},
    ---@param x number
    ---@param y number
    ---@return boolean
    push = function(x, y)
        pop.pos.stack[#pop.pos.stack + 1] = { x, y }
        return true
    end,
    pop = function()
        pop.pos.stack[#pop.pos.stack] = nil
    end,
    ---@return number x
    ---@return number y
    get = function()
        local x, y = 0, 0
        for _, offset in ipairs(pop.pos.stack) do
            x, y = x + offset[1], y + offset[2]
        end
        return x, y
    end,
    ---@param x number
    ---@param y number
    layer = function(x, y)
        ---@param content_fn fun()
        return function(content_fn)
            local stack = pop.pos.stack
            pop.pos.stack = {}
            pop.pos.push(x, y)
            content_fn()
            pop.pos.pop()
            pop.pos.stack = stack
        end
    end,
}

pop.call_depth = 0

local function get_id()
    return id_allocator.get_id(2 + pop.call_depth)
end

---@param mod integer
function pop.call_depth_mod(mod)
    pop.call_depth = pop.call_depth + mod
end

local function new_prototype(metatable)
    metatable.__index = metatable
    return metatable
end

local option_list = {}
---@type table<pop.gui_option,bool>
pop.option = setmetatable({}, {
    __newindex = function(t, k, v)
        local option = const.options[k]
        if not option then
            print_error(('Option "%s" doesn\'t exist'):format(k))
            return
        end
        if v then
            GuiOptionsAdd(gui, option)
        else
            GuiOptionsRemove(gui, option)
        end
        option_list[k] = v
    end,
    __index = function(t, k)
        return option_list[k]
    end,
})

function pop.option_clear()
    option_list = {}
    GuiOptionsClear(gui)
end

function pop.start_frame()
    GuiStartFrame(gui)
    id_allocator.new_frame()
    pop.screen_size = { GuiGetScreenDimensions(gui) }
    pop.z:new_frame()
    pop.option_clear()
    _, pop.text_line_height = GuiGetTextDimensions(gui, "|")
end

---@param option pop.gui_option
function pop.option_next(option)
    local option_val = const.options[option]
    if option_val then
        GuiOptionsAddForNextWidget(gui, option_val)
    else
        print_error(('Option "%s" doesn\'t exist'):format(option))
    end
    return pop.option_next
end

---@class pop.general_props.color
---@field r integer
---@field g integer
---@field b integer
---@field a integer

local function hex2dec(h)
    return (h + 1) / 256
end

---@param color pop.general_props.color
local function next_color(color)
    GuiColorSetForNextWidget(gui, hex2dec(color.r), hex2dec(color.g), hex2dec(color.b), hex2dec(color.a))
end

-- TODO: impl bucket mechanic

---@param layer pop.layer
function pop.layer(layer)
    ---@param content_fn fun()
    return function(content_fn)
        local stored = pop.z.layer_cur
        pop.z.layer_cur = layer
        content_fn()
        pop.z.layer_cur = stored
    end
end

local function next_z_step()
    GuiZSetForNextWidget(gui, pop.z:get())
end

function pop.animate_begin()
    GuiAnimateBegin(gui)
    return true
end

function pop.animate_end()
    GuiAnimateEnd(gui)
end

function pop.animate_fade_in(speed, step, reset)
    GuiAnimateAlphaFadeIn(gui, get_id(), speed, step, reset)
end

function pop.animate_scale_in(acceleration, reset)
    GuiAnimateScaleIn(gui, get_id(), acceleration, reset)
end

---@class pop.text.props
---@field color pop.general_props.color?

---@param text string
---@param props pop.text.props?
function pop.text(text, props)
    local x, y = pop.pos.get()

    if props then
        if props.color then
            next_color(props.color)
        end
    end

    next_z_step()
    -- scaling text is a lie in noita gui
    GuiText(gui, x, y, text)
end

---@class pop.text_pixel.props
---@field font string?
---@field scale number?
---@field color pop.general_props.color?

-- well maybe you can make sure you use xml fonts
---@param text string
---@param props pop.text_pixel.props?
function pop.text_pixel(text, props)
    local x, y = pop.pos.get()
    local font, scale = "data/fonts/font_pixel.xml", 1

    if props then
        font = props.font or font
        scale = props.scale or scale
        if props.color then
            next_color(props.color)
        end
    end

    next_z_step()
    GuiText(gui, x, y, text, scale, font, true)
end

---@param text string
---@param font string
---@param color pop.general_props.color?
function pop.text_non_pixel(text, font, color)
    local x, y = pop.pos.get()

    if color then
        next_color(color)
    end

    next_z_step()
    GuiText(gui, x, y, text, 1, font, false)
end

---@class pop.button_text.props
---@field color pop.general_props.color?

---@param text string
---@param props pop.button_text.props?
function pop.button_text(text, props)
    local x, y = pop.pos.get()

    if props then
        if props.color then
            next_color(props.color)
        end
    end

    next_z_step()
    -- scaling text is a lie in noita gui
    return GuiButton(gui, get_id(), x, y, text)
end

---@class pop.button_text_pixel.props
---@field font string?
---@field scale number?
---@field color pop.general_props.color?

---@param text string
---@param props pop.button_text_pixel.props?
function pop.button_text_pixel(text, props)
    local x, y = pop.pos.get()
    local font, scale = "data/fonts/font_pixel.xml", 1

    if props then
        font = props.font or font
        scale = props.scale or scale
        if props.color then
            next_color(props.color)
        end
    end

    next_z_step()
    return GuiButton(gui, get_id(), x, y, text, scale, font, true)
end

---@param text string
---@param font string
---@param color pop.general_props.color?
---@return boolean left_click
---@return boolean right_click
function pop.button_text_non_pixel(text, font, color)
    local x, y = pop.pos.get()

    if color then
        next_color(color)
    end

    next_z_step()
    return GuiButton(gui, get_id(), x, y, text, 1, font, false)
end

---@param text string
---@param line_spacing number?
---@return number width
---@return number height
function pop.measure_text(text, line_spacing)
    return GuiGetTextDimensions(gui, text, 1, line_spacing or 2)
end

---@class pop.measure_text_pixel.options
---@field font string?
---@field scale number?
---@field line_spacing number?

---@param text string
---@param options pop.measure_text_pixel.options?
---@return number width
---@return number height
function pop.measure_text_pixel(text, options)
    local font, scale, line_spacing = "data/fonts/font_pixel.xml", 1, 2

    if options then
        font = options.font or font
        scale = options.scale or scale
        line_spacing = options.line_spacing or line_spacing
    end

    return GuiGetTextDimensions(gui, text, scale, line_spacing, font, true)
end

---@param text string
---@param font string
---@param line_spacing number?
---@return number width
---@return number height
function pop.measure_text_non_pixel(text, font, line_spacing)
    return GuiGetTextDimensions(gui, text, 1, line_spacing or 2, font, false)
end

---@class pop.image.props
---@field alpha number?
---@field scale number?
---@field scale_y number?
---@field rotation number?
---@field animation pop.image.props.animation?

---@class pop.image.props.animation
---@field playback_type pop.playback_type?
---@field name string?

---@param sprite_filename string
---@param props pop.image.props?
function pop.image(sprite_filename, props)
    local x, y = pop.pos.get()
    local alpha, scale, scale_y, rotation = 1, 1, 0, 0
    local playback_type, animation_name = 0, ""

    if props then
        alpha = props.alpha or alpha
        scale = props.scale or scale
        scale_y = props.scale_y or scale_y
        rotation = props.rotation or rotation

        if props.animation then
            if props.animation.playback_type then
                playback_type = const.playback_types[props.animation.playback_type] or playback_type
            end
            animation_name = props.animation.name or animation_name
        end
    end

    next_z_step()
    GuiImage(gui, get_id(), x, y, sprite_filename, alpha, scale, scale_y, rotation, playback_type, animation_name)
end

---@param sprite_filename string
---@param width number
---@param height number
function pop.image_9piece(sprite_filename, width, height)
    local x, y = pop.pos.get()
    next_z_step()
    GuiImageNinePiece(gui, get_id(), x, y, width, height, 1, sprite_filename, sprite_filename)
end

---@param sprite_filename string
---@param scale number
---@return number width
---@return number height
function pop.measure_image(sprite_filename, scale)
    return GuiGetImageDimensions(gui, sprite_filename, scale or 1)
end

---@param sprite_filename string
---@return bool
---@return bool
---@nodiscard
function pop.button(sprite_filename)
    local x, y = pop.pos.get()
    next_z_step()
    return GuiImageButton(gui, get_id(), x, y, "", sprite_filename)
end

---@param value number
---@param width number
---@return number
---@nodiscard
function pop.slider(value, width)
    local x, y = pop.pos.get()
    next_z_step()
    return GuiSlider(gui, get_id(), x, y, "", value, 0, 1, value, 0, "", width)
end

--TODO: check if these max_length's are really used anywhere

---@param value string
---@param width number
---@param max_length integer
---@param allowed_chars string
---@return string
---@nodiscard
function pop.input_text(value, width, max_length, allowed_chars)
    local x, y = pop.pos.get()
    next_z_step()
    return GuiTextInput(gui, get_id(), x, y, value, width, max_length, allowed_chars)
end

---@param value string
---@param width number
---@param max_length integer
---@return string
---@nodiscard
function pop.input_any_text(value, width, max_length)
    local x, y = pop.pos.get()
    next_z_step()
    return GuiTextInput(gui, get_id(), x, y, value, width, max_length, "")
end

---@param value integer
---@param width number
---@param max_length integer
---@return integer
---@nodiscard
function pop.input_int(value, width, max_length)
    local x, y = pop.pos.get()
    local old_text = ("%.0f"):format(value)
    next_z_step()
    local new_text = GuiTextInput(gui, get_id(), x, y, old_text, width, max_length, "0123456789+-")
    return tonumber(new_text)
end

---@param value number
---@param width number
---@param max_length integer
---@return number
---@nodiscard
function pop.input_float(value, width, max_length)
    local x, y = pop.pos.get()
    local old_text = ("%.3f"):format(value)
    next_z_step()
    local new_text = GuiTextInput(gui, get_id(), x, y, old_text, width, max_length, "0123456789+-.")
    return tonumber(new_text)
end

---@param content_fn fun()
---@return number x
---@return number y
---@return number width
---@return number height
---@nodiscard
function pop.detect_bound(content_fn)
    GuiBeginAutoBox(gui)

    content_fn()

    if pop.invis_begin() then
        GuiEndAutoBoxNinePiece(gui, 0)
        pop.invis_end()
    end

    local x, y = pop.prev_pos()
    local width, height = pop.prev_size()
    return x, y, width, height
end

-- no we don't use vanilla tooltip function

local function tooltip(content_fn, x, y)
    local z = pop.z:get()
    GuiLayoutBeginLayer(gui)
    GuiBeginAutoBox(gui)

    pop.pos.layer(x, y)(content_fn)

    GuiZSetForNextWidget(gui, z)
    GuiEndAutoBoxNinePiece(gui)
    GuiLayoutEndLayer(gui)
end

---@vararg string
function pop.tooltip(...)
    local text = { ... }

    -- don't need to care about ids here
    pop.tooltip_custom(2, 0, true)(function()
        local layout = pop.layout_stack(0, pop.text_line_height)
        for _, line in ipairs(text) do
            for t in string.gmatch(GameTextGetTranslatedOrNot(line), "[^\n]+") do
                layout:next(function() pop.text(t) end)
            end
        end
    end)
end

local function show_tooltip_custom(content_fn, x_min, x_max, x_offset, y, animated)
    x_offset = x_offset or 0

    if pop.invis_begin() then
        tooltip(content_fn, 0, 0)
        pop.invis_end()
    end

    local _, tooltip_height = pop.prev_size()

    local x_mid = (x_min + x_max) / 2

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

    pop.layer "TOOLTIP" (function()
        if animated then
            pop.animate_begin()
            pop.animate_fade_in(0.08, 0.1, false)
            pop.animate_scale_in(0.08, false)
        end

        tooltip(content_fn, x, y)

        if animated then
            pop.animate_end()
        end
    end)

    if align_left then
        pop.option.Align_Left = old_align_Left
    end
end

---@param x_offset number
---@param y_offset number
---@param animated boolean?
---@return fun(content_fn: fun())
function pop.tooltip_custom(x_offset, y_offset, animated)
    animated = animated ~= true
    return function(content_fn)
        if not pop.prev_hovered() then return end
        local x, y = pop.prev_pos()
        local width, _ = pop.prev_size()
        show_tooltip_custom(content_fn, x, x + width, x_offset, y + y_offset, animated)
    end
end

---@param margin_x number? 2
---@param margin_y number? 2
function pop.scroll_box_begin(width, height, margin_x, margin_y)
    local x, y = pop.pos.get()
    margin_x = margin_x or 2
    margin_y = margin_y or 2
    GuiBeginScrollContainer(gui, get_id(), x, y, width, height, true, margin_x, margin_y)

    pop.pos.layer(0, 0)(function()
        -- pop.image "data/ui_gfx/decorations/9piece0_gray.png"
        pop.invis_begin()
        pop.text_pixel "|"
        pop.invis_end()
    end)
    local _, test_y = pop.prev_pos()
    pop.pos.push(0, test_y - y)

    GuiLayoutEnd(gui)
    return true
end

function pop.scroll_box_end()
    pop.pos.pop()
    GuiLayoutBeginVertical(gui, 0, 0)
    GuiEndScrollContainer(gui)
end

function pop.invis_begin()
    GuiAnimateBegin(gui)
    GuiAnimateAlphaFadeIn(gui, get_id(), 0, 0, true)
    return true
end

function pop.invis_end()
    GuiAnimateEnd(gui)
end

---@nodiscard
function pop.prev_clicked()
    local left_clicked, right_clicked = GuiGetPreviousWidgetInfo(gui)
    return left_clicked, right_clicked
end

---@nodiscard
function pop.prev_hovered()
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    return hovered
end

---@nodiscard
function pop.prev_pos()
    local _, _, _, x, y = GuiGetPreviousWidgetInfo(gui)
    return x, y
end

---@nodiscard
function pop.prev_size()
    local _, _, _, _, _, width, height = GuiGetPreviousWidgetInfo(gui)
    return width, height
end

---@param margin number?
---@return boolean
---@nodiscard
local function mouse_inside_area(x, y, width, height, margin)
    margin = margin or 0
    local mx, my = pc.world_to_screen(DEBUG_GetMouseWorld())
    return -margin + x < mx and mx < x + width + margin and -margin + y < my and my < y + height + margin
end

---@param margin number?
---@return boolean
---@nodiscard
function pop.prev_mouse_inside(margin)
    local x, y = pop.prev_pos()
    local width, height = pop.prev_size()
    return mouse_inside_area(x, y, width, height, margin)
end

function pop.block_mousewheel()
    local mx, my = pc.world_to_screen(DEBUG_GetMouseWorld())
    if pop.invis_begin() then
        pop.option_next "Layout_NoLayouting" "AlwaysClickable"
        GuiBeginScrollContainer(gui, get_id(), mx - 25, my - 25, 50, 50, false, 0, 0)
        GuiEndScrollContainer(gui)
        pop.invis_end()
    end
end

---@param width number
---@param height number
---@param use_right_click bool
---@return number x
---@return number y
---@return bool dragging
---@nodiscard
function pop.draggable_space(width, height, use_right_click)
    local x, y = pop.pos.get()
    local id = get_id()
    local keycode = 1
    if use_right_click then
        keycode = 2
    end
    if not pop.dragging then
        if InputIsMouseButtonJustDown(keycode) and mouse_inside_area(x, y, width, height) then
            local mx, my = pc.world_to_screen(DEBUG_GetMouseWorld())
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
        local mx, my = pc.world_to_screen(DEBUG_GetMouseWorld())
        x, y = mx - pop.dragging.pos_x, my - pop.dragging.pos_y

        if not InputIsMouseButtonDown(keycode) then
            pop.dragging = nil
        end

        return x, y, true
    end
    return x, y, false
end

---@param width number
---@param height number
---@return bool hovered
---@nodiscard
function pop.hoverable_space(width, height)
    local x, y = pop.pos.get()
    return mouse_inside_area(x, y, width, height)
end

if false then
    ---@class pop.layout
    local layout = {}

    ---@param content_fn fun()
    function layout:next(content_fn) end

    ---@param shift_x number
    ---@param shift_y number
    function layout:shift(shift_x, shift_y) end
end

---@class pop.layout_stack: pop.layout

local layout_stack_mt = new_prototype {
    next = function(self, content_fn)
        pop.pos.push(self.x, self.y)
        content_fn()
        pop.pos.pop()

        self.x = self.x + self.offset_x
        self.y = self.y + self.offset_y
    end,
    shift = function(self, shift_x, shift_y)
        self.x = self.x + shift_x
        self.y = self.y + shift_y
    end,
}

---@param offset_x number
---@param offset_y number
---@return pop.layout
---@nodiscard
function pop.layout_stack(offset_x, offset_y)
    ---@type pop.layout_stack
    return setmetatable({ x = 0, y = 0, offset_x = offset_x, offset_y = offset_y }, layout_stack_mt)
end

---@class pop.layout_hwrap: pop.layout

local layout_hwrap_mt = new_prototype {
    next = function(self, content_fn)
        pop.pos.push(self.x, self.y)
        content_fn()
        pop.pos.pop()

        self.cur_line_size = self.cur_line_size + 1
        if self.cur_line_size < self.line_size then
            self.x = self.x + self.offset_x
        else
            self.cur_line_size = 0
            self.x = 0
            self.y = self.y + self.offset_y
        end
    end,
    shift = function(self, shift_x, shift_y)
        self.x = self.x + shift_x
        self.y = self.y + shift_y
    end,
}

---@param offset_x number
---@param offset_y number
---@param line_size integer
---@return pop.layout
---@nodiscard
function pop.layout_hwrap(offset_x, offset_y, line_size)
    ---@type pop.layout_hwrap
    return setmetatable({
        x = 0,
        y = 0,
        offset_x = offset_x,
        offset_y = offset_y,
        cur_line_size = 0,
        line_size = line_size,
    }, layout_hwrap_mt)
end

return pop
