local mutils = require "misc_utils"
local tr = require "tr"

local format = {}

local function digit3_sep(value_text)
    local formatted, k = value_text, 0
    repeat
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    until k == 0
    return formatted
end

local function digit4_sep(value_text)
    local formatted, k = value_text, 0
    repeat
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1,%2')
    until k == 0
    return formatted
end

local function separator(text)
    return (mutils.is_cur_lang_cn() and digit4_sep or digit3_sep)(text)
end

local inf = 1 / 0
local threshold = 10 ^ 10

---@param value number
---@param never_use_scientific_notation boolean
---@param result_inf string?
---@return string
---@nodiscard
function format.damage_dummy(value, never_use_scientific_notation, result_inf)
    if value == inf then
        return result_inf or "∞"
    end
    value = value * 25
    if not never_use_scientific_notation and (math.abs(value) > threshold) then
        return ("%.10e"):format(value)
    end
    return separator(string.format("%.2f", value))
end

---@param value integer
---@param show_sign boolean?
---@return string
---@nodiscard
function format.int(value, show_sign)
    local text = ""
    if show_sign and value > 0 then
        text = "+"
    end
    text = text .. separator(("%.0f"):format(value))
    return text
end

---@param value number
---@param places integer
---@param show_sign boolean?
---@return string
---@nodiscard
function format.decimal(value, places, show_sign)
    local text = ""
    if value ~= nil then
        if show_sign and value > 0 then
            text = "+"
        end
        local power = math.pow(10, places)
        text = text .. tostring(math.floor(value * power + 0.5) / power)
    else
        return "missing"
    end
    return text
end

---@param time integer
---@param digits integer?
---@return string
---@nodiscard
function format.frames(time, digits)
    digits = digits or 2
    return format.decimal(time / 60, digits, true) .. " s (" .. tr.general.frames:text(format.int(time)) .. ")"
end

---@param min number
---@param max number
---@return string
---@nodiscard
function format.range(min, max)
    if not min or not max then return nil end
    if min ~= max then
        return ("%s - %s"):format(min, max)
    else
        return tostring(min)
    end
end

---@param str string
---@param wrap_size integer?
---@return string
---@nodiscard
function format.word_wrap(str, wrap_size)
    if GameTextGet "$current_language" ~= "English" then
        return str
    end
    if wrap_size == nil then wrap_size = 60 end
    local last_space_index = 1
    local last_wrap_index = 0
    for i = 1, #str do
        if str:sub(i, i) == " " then
            last_space_index = i
        end
        if str:sub(i, i) == "\n" then
            last_space_index = i
            last_wrap_index = i
        end
        if i - last_wrap_index > wrap_size then
            str = str:sub(1, last_space_index - 1) .. "\n" .. str:sub(last_space_index + 1)
            last_wrap_index = i
        end
    end
    return str
end

return format
