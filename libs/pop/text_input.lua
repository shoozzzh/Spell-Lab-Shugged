local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
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
    { "Key_a",     "A" },
    { "Key_b",     "B" },
    { "Key_c",     "C" },
    { "Key_d",     "D" },
    { "Key_e",     "E" },
    { "Key_f",     "F" },
    { "Key_g",     "G" },
    { "Key_h",     "H" },
    { "Key_i",     "I" },
    { "Key_j",     "J" },
    { "Key_k",     "K" },
    { "Key_l",     "L" },
    { "Key_m",     "M" },
    { "Key_n",     "N" },
    { "Key_o",     "O" },
    { "Key_p",     "P" },
    { "Key_q",     "Q" },
    { "Key_r",     "R" },
    { "Key_s",     "S" },
    { "Key_t",     "T" },
    { "Key_u",     "U" },
    { "Key_v",     "V" },
    { "Key_w",     "W" },
    { "Key_x",     "X" },
    { "Key_y",     "Y" },
    { "Key_z",     "Z" },
    { "Key_1",     "1" },
    { "Key_2",     "2" },
    { "Key_3",     "3" },
    { "Key_4",     "4" },
    { "Key_5",     "5" },
    { "Key_6",     "6" },
    { "Key_7",     "7" },
    { "Key_8",     "8" },
    { "Key_9",     "9" },
    { "Key_0",     "0" },
    { "Key_SPACE", " " },
    { "Key_MINUS", "_" },
}

---@param text string
---@return boolean changed
---@return string new_text
function object_mt:show(text)
    pop.text_input_surface(text, self.width)

    self.input_anchor = math.min(self.input_anchor, #text + 1)

    local hovered = pop.prev_mouse_inside(2)
    local changed = false
    local alt = InputIsKeyDown(keycodes.Key_LALT) or InputIsKeyDown(keycodes.Key_RALT)

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
    elseif InputIsKeyJustDown(keycodes.Key_LEFT) then
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
    elseif InputIsMouseButtonJustUp(keycodes.Mouse_right) and hovered then
        text = ""
        self.input_anchor = 1
        changed = true
    else
        if self.allowed_chars then
            for _, p in ipairs(character_keys) do
                if InputIsKeyJustDown(keycodes[p[1]]) and self.allowed_chars:find(p[2], 1, true) then
                    text = insert_character(text, p[2], self.input_anchor)
                    self.input_anchor = self.input_anchor + 1
                    changed = true
                    break
                end
            end
        else
            for _, p in ipairs(character_keys) do
                if InputIsKeyJustDown(keycodes[p[1]]) then
                    text = insert_character(text, p[2], self.input_anchor)
                    self.input_anchor = self.input_anchor + 1
                    changed = true
                    break
                end
            end
        end
    end

    local has_focus = kbfocus.is_on(self)

    if has_focus or text ~= "" then
        local input_anchor_offset = pop.measure_text(text:sub(1, self.input_anchor - 1))
        local _, anchor_image_height = pop.measure_image(path .. "input_anchor.png")
        local anchor_image_scale = (pop.text_line_height - 2) / anchor_image_height
        pop.pos.push(1 + input_anchor_offset, 2 * anchor_image_scale)
        pop.image(path .. "input_anchor.png", { scale = anchor_image_scale })
        pop.pos.pop()
    else
        pop.option_next "NonInteractive"
        pop.text_input_surface(self.placeholder, self.width)
    end

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
