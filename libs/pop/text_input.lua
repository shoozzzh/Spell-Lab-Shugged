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

---@class pop.text_input.object: pop.keyboard_focus.focusee
---@field input_anchor integer
---@field width number
---@field placeholder string
---@field allowed_chars string?
local object_mt = new_prototype()

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
function object_mt:show(text)
    pop.call_depth_mod(1)
    local has_focus = kbfocus.is_on(self)

    local text_to_show = text
    if not has_focus and text == "" then
        text_to_show = self.placeholder
    end

    pop.text_input_surface(text_to_show, self.width)
    local _, text_input_height = pop.prev_size()

    local hovered = pop.prev_mouse_inside()
    local changed = false

    self.input_anchor = math.min(self.input_anchor, #text + 1)
    if not has_focus and hovered then
        self.input_anchor = #text + 1
    end

    -- TODO: Maybe make the region customizable? Like a click sensor?
    if InputIsMouseButtonJustDown(keycodes.Mouse_left) then
        kbfocus.set(self, hovered)
        if hovered then
            local x, _ = pop.pos.get()
            local mx, _ = pop.get_mouse_pos()
            local desired_anchor_x = mx - (x + 1) -- + 1 for the margin of box

            local i = 0
            local dist
            repeat
                i = i + 1
                dist = (pop.measure_text(text:sub(1, i)) + pop.measure_text(text:sub(1, i + 1))) / 2
            until dist >= desired_anchor_x or i > #text

            self.input_anchor = i
        end
    elseif InputIsMouseButtonJustUp(keycodes.Mouse_right) and hovered then
        kbfocus.set(self, true)
        text = ""
        self.input_anchor = 1
        changed = true
    end

    if has_focus then
        local alt = InputIsKeyDown(keycodes.Key_LALT) or InputIsKeyDown(keycodes.Key_RALT)
        if InputIsKeyJustDown(keycodes.Key_LEFT) then
            if alt then
                local str_left = text:sub(1, self.input_anchor - 1)
                local prev_word_idx, _, _ = str_left:find "[^ ]* *$"
                if prev_word_idx then
                    self.input_anchor = prev_word_idx
                end
            else
                if self.input_anchor > 1 then
                    self.input_anchor = self.input_anchor - 1
                end
            end
        elseif InputIsKeyJustDown(keycodes.Key_RIGHT) then
            if alt then
                local str_right = text:sub(self.input_anchor, -1)
                local _, next_word_idx, _ = str_right:find "^ *[^ ]*"
                if next_word_idx then
                    self.input_anchor = self.input_anchor + next_word_idx
                end
            else
                if self.input_anchor <= #text then
                    self.input_anchor = self.input_anchor + 1
                end
            end
        elseif InputIsKeyJustDown(keycodes.Key_HOME) then
            self.input_anchor = 1
        elseif InputIsKeyJustDown(keycodes.Key_END) then
            self.input_anchor = #text + 1
        elseif InputIsKeyJustDown(keycodes.Key_BACKSPACE) then
            if self.input_anchor >= 2 then
                text =
                    string.sub(text, 1, self.input_anchor - 2)
                    .. string.sub(text, self.input_anchor, -1)
                self.input_anchor = self.input_anchor - 1
                changed = true
            end
        elseif InputIsKeyJustDown(keycodes.Key_DELETE) then
            if self.input_anchor <= #text then
                text =
                    string.sub(text, 1, self.input_anchor - 1)
                    .. string.sub(text, self.input_anchor + 1, -1)
                changed = true
            end
        else
            local shift = InputIsKeyDown(keycodes.Key_LSHIFT) or InputIsKeyDown(keycodes.Key_RSHIFT)
            if self.allowed_chars then
                for _, p in ipairs(character_keys) do
                    local char = shift and p[3] or p[2]
                    if InputIsKeyJustDown(keycodes[p[1]]) and self.allowed_chars:find(char, 1, true) then
                        text = insert_character(text, char, self.input_anchor)
                        self.input_anchor = self.input_anchor + 1
                        changed = true
                        break
                    end
                end
            else
                for _, p in ipairs(character_keys) do
                    local char = shift and p[3] or p[2]
                    if InputIsKeyJustDown(keycodes[p[1]]) then
                        text = insert_character(text, char, self.input_anchor)
                        self.input_anchor = self.input_anchor + 1
                        changed = true
                        break
                    end
                end
            end
        end
    end

    if has_focus or hovered then
        local input_anchor_offset = pop.measure_text(text:sub(1, self.input_anchor - 1))
        local _, anchor_image_height = pop.measure_image(path .. "input_anchor.png")
        local anchor_image_scale = (text_input_height - 4) / anchor_image_height
        pop.pos.push(2 + input_anchor_offset, 2)
        pop.image(path .. "input_anchor.png", { alpha = hovered and 0.79 or 0.61, scale_y = anchor_image_scale })
        pop.pos.pop()
    end

    pop.call_depth_mod(-1)
    return changed, text
end

---@param width number
---@param placeholder string?
---@param allowed_chars string?
---@return pop.text_input.object
function text_input.new(width, placeholder, allowed_chars)
    return setmetatable({
        input_anchor = 1,
        width = width,
        placeholder = placeholder or "",
        allowed_chars = allowed_chars,
    }, object_mt)
end

---@class pop.text_input.object_wrapper
---@field inner pop.text_input.object
---@field formatter fun(any?): string
---@field parser fun(string): any?
---@field text string
local wrapper_mt = new_prototype()

---@generic V
---@param inner pop.text_input.object
---@param formatter fun(value: V): string
---@param parser fun(text: string): V
---@return pop.text_input.object_wrapper
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
    return setmetatable(res, wrapper_mt)
end

---@generic V
---@param value V
---@return boolean changed
---@return V value
---@nodiscard
function wrapper_mt:show(value)
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
