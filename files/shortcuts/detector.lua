---@alias shortcut string[]

local keystroke_listener = require "shortcuts.keystroke_listener"

local detector = {
    ---@type string[]?
    detection_range = nil,
}

local cache = {}

local xor = function(a, b) return (a and not b) or (not a and b) end

---@param shortcut shortcut
---@param dont_cache bool
---@return table<string,bool>
local function get_inverted(shortcut, dont_cache)
    local inverted = cache[shortcut]
    if inverted == nil then
        inverted = {}
        if type(shortcut) == "table" then
            for _, key in ipairs(shortcut) do
                inverted[key] = true
            end
        end
        if not dont_cache then
            cache[shortcut] = inverted
        end
    end
    return inverted
end

---@param shortcut shortcut
---@param left_click bool?
---@param right_click bool?
---@param dont_cache bool?
---@return boolean
function detector.is_fired(shortcut, left_click, right_click, dont_cache)
    if #shortcut == 0 then return false end

    local inverted_shortcut = get_inverted(shortcut, dont_cache)

    local trigger_key = shortcut[#shortcut]
    if trigger_key == "Mouse_left" then
        if (left_click ~= true) ~= inverted_shortcut.Mouse_left then return false end
    elseif trigger_key == "Mouse_right" then
        if (right_click ~= true) ~= inverted_shortcut.Mouse_right then return false end
    else
        if not keystroke_listener.just_down[trigger_key] then return false end
    end

    for _, key in pairs(detector.detection_range or keystroke_listener.listened_keys) do
        if keystroke_listener.down[key] ~= inverted_shortcut[key] then return false end
    end

    return true
end

---@param shortcut shortcut
---@param dont_cache bool?
---@return boolean
function detector.is_held(shortcut, dont_cache)
    if #shortcut == 0 then return false end

    local inverted_shortcut = get_inverted(shortcut, dont_cache)

    for _, key in pairs(detector.detection_range or keystroke_listener.listened_keys) do
        if keystroke_listener.down[key] ~= inverted_shortcut[key] then return false end
    end

    return true
end

return detector
