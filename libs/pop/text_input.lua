local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
    if module_name == "pop" then
        module_name = "pop.main"
    end
    return dofile_once(path .. module_name:sub(5) .. ".lua")
end

local pop = require "pop"
local kbfocus = require "pop.keyboard_focus"

---@class pop.input
local text_input = {}

local function new_prototype()
    local res = {}
    res.__index = res
    return res
end

---@class pop.text_input.surface
---@field width integer
---@field bg_9piece string
---@field margin_bg number
---@field text_offset number
local surface_mt = new_prototype()

---@type pop.text.props
local text_props_highlight = { color = { r = 255, g = 255, b = 178, a = 255 } }
local image_cursor = path .. "cursor.png"
local bg_default = path .. "text_input_bg_default.png"

function surface_mt:show(text, cursor, has_focus)
    pop.image_9piece(self.bg_9piece, self.width, pop.text_height_no_space, { margin = self.margin_bg })
    local hovered = pop.prev_mouse_inside()

    pop.pos.push(2, 0)

    if has_focus or hovered then
        pop.text(text, text_props_highlight)
    else
        pop.text(text)
    end

    if has_focus or hovered then
        local cursor_width, cursor_height = pop.measure_image(image_cursor)
        local scale = (pop.text_height_no_space - 3) / cursor_height

        local width_char_prev = pop.measure_text(text:sub(cursor - 1, cursor - 1))
        local width_char_this = pop.measure_text(text:sub(cursor, cursor))
        local width_2_chars = pop.measure_text(text:sub(cursor - 1, cursor))
        local space_between_chars = width_2_chars - width_char_prev - width_char_this

        local cursor_offset = pop.measure_text(text:sub(1, cursor - 1))
        cursor_offset = cursor_offset + space_between_chars / 2 - cursor_width / 2

        pop.pos.push(cursor_offset, 1.5)
        pop.image(image_cursor, { alpha = has_focus and 0.79 or 0.61, scale_y = scale })
        pop.pos.pop()
    end

    pop.pos.pop()
    return hovered
end

function surface_mt:to_cursor_pos(text, offset_x, offset_y)
    local desired_pos_in_text = offset_x - 2 -- -2 for text offset

    local i = 0
    local pos
    repeat
        i = i + 1
        pos = (pop.measure_text(text:sub(1, i - 1)) + pop.measure_text(text:sub(1, i))) / 2
    until pos >= desired_pos_in_text or i > #text

    return i
end

---@param width number
---@param bg_9piece string?
---@param margin_bg number?
---@return pop.text_input.surface
function text_input.simple_surface(width, bg_9piece, margin_bg)
    ---@type pop.text_input.surface
    return setmetatable({
        width = width,
        bg_9piece = bg_9piece or bg_default,
        margin_bg = margin_bg or -1,
    }, surface_mt)
end

---@class pop.text_input.raw: pop.keyboard_focus.focusee
---@field surface pop.text_input.surface
---@field cursor integer
---@field placeholder string
---@field allowed_chars string?
local raw_mt = new_prototype()

local function insert_character(str, char, index)
    return string.sub(str, 1, index - 1) .. char .. string.sub(str, index, -1)
end

---@type table<string, integer>
local keycodes = (function()
    local f = loadfile "data/scripts/debug/keycodes.lua"
    local raw = {}
    setfenv(f, raw)()
    return raw
end)()

---@type {[1]: string, [2]: string}[]
local character_keys = {
    { "Key_a",            "a", "A" },
    { "Key_b",            "b", "B" },
    { "Key_c",            "c", "C" },
    { "Key_d",            "d", "D" },
    { "Key_e",            "e", "E" },
    { "Key_f",            "f", "F" },
    { "Key_g",            "g", "G" },
    { "Key_h",            "h", "H" },
    { "Key_i",            "i", "I" },
    { "Key_j",            "j", "J" },
    { "Key_k",            "k", "K" },
    { "Key_l",            "l", "L" },
    { "Key_m",            "m", "M" },
    { "Key_n",            "n", "N" },
    { "Key_o",            "o", "O" },
    { "Key_p",            "p", "P" },
    { "Key_q",            "q", "Q" },
    { "Key_r",            "r", "R" },
    { "Key_s",            "s", "S" },
    { "Key_t",            "t", "T" },
    { "Key_u",            "u", "U" },
    { "Key_v",            "v", "V" },
    { "Key_w",            "w", "W" },
    { "Key_x",            "x", "X" },
    { "Key_y",            "y", "Y" },
    { "Key_z",            "z", "Z" },
    { "Key_1",            "1", "!" },
    { "Key_2",            "2", "@" },
    { "Key_3",            "3", "#" },
    { "Key_4",            "4", "$" },
    { "Key_5",            "5", "%" },
    { "Key_6",            "6", "^" },
    { "Key_7",            "7", "&" },
    { "Key_8",            "8", "*" },
    { "Key_9",            "9", "(" },
    { "Key_0",            "0", ")" },
    { "Key_MINUS",        "-", "_" },
    { "Key_EQUALS",       "=", "+" },
    { "Key_LEFTBRACKET",  "[", "{" },
    { "Key_RIGHTBRACKET", "]", "}" },
    { "Key_SEMICOLON",    ";", ":" },
    { "Key_APOSTROPHE",   "'", '"' },
    { "Key_GRAVE",        "`", '~' },
    { "Key_COMMA",        ",", "<" },
    { "Key_PERIOD",       ".", ">" },
    { "Key_SPACE",        " ", " " },
    { "Key_KP_DIVIDE",    "/", "/" },
    { "Key_KP_MULTIPLY",  "*", "*" },
    { "Key_KP_MINUS",     "-", "-" },
    { "Key_KP_PLUS",      "+", "+" },
    { "Key_KP_1",         "1", "1" },
    { "Key_KP_2",         "2", "2" },
    { "Key_KP_3",         "3", "3" },
    { "Key_KP_4",         "4", "4" },
    { "Key_KP_5",         "5", "5" },
    { "Key_KP_6",         "6", "6" },
    { "Key_KP_7",         "7", "7" },
    { "Key_KP_8",         "8", "8" },
    { "Key_KP_9",         "9", "9" },
    { "Key_KP_0",         "0", "0" },
    { "Key_KP_PERIOD",    ".", "." },
}

---@param text string
---@return boolean changed
---@return string new_text
function raw_mt:show(text)
    pop.call_depth_mod(1)
    local has_focus = kbfocus.is_on(self)

    local text_to_show = text
    if not has_focus and text == "" then
        text_to_show = self.placeholder
    end

    local hovered = self.surface:show(text_to_show, self.cursor, has_focus)
    local changed = false

    self.cursor = math.min(self.cursor, #text + 1)
    if not has_focus then
        self.cursor = #text + 1
    end

    -- TODO: Maybe make the region customizable? Like a click sensor?
    if InputIsMouseButtonJustDown(keycodes.Mouse_left) then
        kbfocus.set(self, hovered)
        if hovered then
            local x, y = pop.pos.get()
            local mx, my = pop.get_mouse_pos()

            self.cursor = self.surface:to_cursor_pos(text, mx - x, my - y)
        end
    elseif InputIsMouseButtonJustUp(keycodes.Mouse_right) and hovered then
        kbfocus.set(self, true)
        text = ""
        self.cursor = 1
        changed = true
    end

    if has_focus then
        local alt = InputIsKeyDown(keycodes.Key_LALT) or InputIsKeyDown(keycodes.Key_RALT)
        if InputIsKeyJustDown(keycodes.Key_LEFT) then
            if alt then
                local str_left = text:sub(1, self.cursor - 1)
                local prev_word_idx, _, _ = str_left:find "[^ ]* *$"
                if prev_word_idx then
                    self.cursor = prev_word_idx
                end
            else
                if self.cursor > 1 then
                    self.cursor = self.cursor - 1
                end
            end
        elseif InputIsKeyJustDown(keycodes.Key_RIGHT) then
            if alt then
                local str_right = text:sub(self.cursor, -1)
                local _, next_word_idx, _ = str_right:find "^ *[^ ]*"
                if next_word_idx then
                    self.cursor = self.cursor + next_word_idx
                end
            else
                if self.cursor <= #text then
                    self.cursor = self.cursor + 1
                end
            end
        elseif InputIsKeyJustDown(keycodes.Key_HOME) then
            self.cursor = 1
        elseif InputIsKeyJustDown(keycodes.Key_END) then
            self.cursor = #text + 1
        elseif InputIsKeyJustDown(keycodes.Key_BACKSPACE) then
            if self.cursor >= 2 then
                text =
                    string.sub(text, 1, self.cursor - 2)
                    .. string.sub(text, self.cursor, -1)
                self.cursor = self.cursor - 1
                changed = true
            end
        elseif InputIsKeyJustDown(keycodes.Key_DELETE) then
            if self.cursor <= #text then
                text =
                    string.sub(text, 1, self.cursor - 1)
                    .. string.sub(text, self.cursor + 1, -1)
                changed = true
            end
        else
            local shift = InputIsKeyDown(keycodes.Key_LSHIFT) or InputIsKeyDown(keycodes.Key_RSHIFT)
            if self.allowed_chars then
                for _, p in ipairs(character_keys) do
                    local char = shift and p[3] or p[2]
                    if InputIsKeyJustDown(keycodes[p[1]]) and self.allowed_chars:find(char, 1, true) then
                        text = insert_character(text, char, self.cursor)
                        self.cursor = self.cursor + 1
                        changed = true
                        break
                    end
                end
            else
                for _, p in ipairs(character_keys) do
                    local char = shift and p[3] or p[2]
                    if InputIsKeyJustDown(keycodes[p[1]]) then
                        text = insert_character(text, char, self.cursor)
                        self.cursor = self.cursor + 1
                        changed = true
                        break
                    end
                end
            end
        end
    end

    pop.call_depth_mod(-1)
    return changed, text
end

---@param surface pop.text_input.surface
---@param placeholder string?
---@param allowed_chars string?
---@return pop.text_input.raw
function text_input.new(surface, placeholder, allowed_chars)
    return setmetatable({
        surface = surface,
        cursor = 1,
        placeholder = placeholder or "",
        allowed_chars = allowed_chars,
    }, raw_mt)
end

---@class pop.text_input.wrapped
---@field inner pop.text_input.raw
---@field formatter fun(any?): string
---@field parser fun(string): any?
---@field text string
local wrapped_mt = new_prototype()

---@generic V
---@param inner pop.text_input.raw
---@param formatter fun(value: V): string
---@param parser fun(text: string): V
---@return pop.text_input.wrapped
function text_input.wrap(inner, formatter, parser)
    local res = {
        inner = inner,
        formatter = formatter,
        parser = parser,
        text = "",
    }
    local old = res.inner.on_lose_focus
    if old then
        res.inner.on_lose_focus = function()
            old()
            res.text = formatter(parser(res.text))
        end
    else
        res.inner.on_lose_focus = function()
            res.text = formatter(parser(res.text))
        end
    end
    return setmetatable(res, wrapped_mt)
end

---@generic V
---@param value V
---@return boolean changed
---@return V value
---@nodiscard
function wrapped_mt:show(value)
    local changed, text
    text = self.parser(self.text) == value and self.text or self.formatter(value)
    changed, text = self.inner:show(text)

    if changed then
        self.text = text
        return changed, self.parser(text)
    end

    return changed, value
end

return text_input
