---@alias shortcut string[]

local keystroke_listener = require "shortcuts.keystroke_listener"

local detector = {
    ---@type string[]?
    detection_range = nil,
}

local cache = {}

local function xor(a, b) return (a == true) ~= (b == true) end

---@param shortcut shortcut
---@return table<string,bool>
local function to_set(shortcut)
    local inverted = cache[shortcut]
    if inverted == nil then
        inverted = {}
        if type(shortcut) == "table" then
            for _, key in ipairs(shortcut) do
                inverted[key] = true
            end
        end
        cache[shortcut] = inverted
    end
    return inverted
end

local last_update_frame = 0

local function update_if_needed()
    local now = GameGetFrameNum()
    if now == last_update_frame then
        return
    end
    last_update_frame = now
    keystroke_listener:update()
end

---@param shortcut shortcut
---@param left_click bool?
---@param right_click bool?
---@param range string[]?
---@return boolean
function detector.is_fired(shortcut, left_click, right_click, range)
    if #shortcut == 0 then return false end
    update_if_needed()

    local key_set = to_set(shortcut)

    local trigger_key = shortcut[#shortcut]
    if trigger_key == "Mouse_left" then
        if xor(left_click, key_set.Mouse_left) then return false end
    elseif trigger_key == "Mouse_right" then
        if xor(right_click, key_set.Mouse_right) then return false end
    else
        if not keystroke_listener.just_down[trigger_key] then return false end
    end

    for _, key in pairs(range or detector.detection_range or keystroke_listener.listened_keys) do
        if xor(keystroke_listener.down[key], key_set[key]) then return false end
    end

    return true
end

---@param shortcut shortcut
---@param range string[]?
---@return boolean
function detector.is_held(shortcut, range)
    if #shortcut == 0 then return false end
    update_if_needed()

    local key_set = to_set(shortcut)

    for _, key in pairs(range or detector.detection_range or keystroke_listener.listened_keys) do
        if xor(keystroke_listener.down[key], key_set[key]) then return false end
    end

    return true
end

return detector
