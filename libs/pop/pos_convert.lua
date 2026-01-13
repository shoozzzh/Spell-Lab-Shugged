local pos_convert = {}

local gui = GuiCreate()
GuiStartFrame( gui )

---@return number
---@return number
local function get_res_offset()
    return tonumber( MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_X") ),
        tonumber( MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_Y") )
end

local function get_screen_size()
    GuiStartFrame( gui )
    return GuiGetScreenDimensions( gui )
end

---@return number
---@return number
function pos_convert.get_res()
    local virtual_res_x, _ = tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_X"))
    local screen_width, screen_height = GuiGetScreenDimensions( gui )
    return virtual_res_x, virtual_res_x * screen_height / screen_width
end

-- perfect algorithms by ImmortalDamned

---@param x number
---@param y number
---@return number
---@return number
function pos_convert.world_to_screen( x, y )
    local camera_x, camera_y = GameGetCameraPos()
    local _, _, bounds_width, bounds_height = GameGetCameraBounds()
    local res_width, res_height = pos_convert.get_res()
    local res_offset_x, res_offset_y = get_res_offset()
    local screen_width, screen_height = get_screen_size()
    return ( x - camera_x + bounds_width / 2 + res_offset_x ) / res_width * screen_width,
        ( y - camera_y + bounds_height / 2 + res_offset_y ) / res_height * screen_height
end

---@param x number
---@param y number
---@return number
---@return number
function pos_convert.screen_to_world( x, y )
    local camera_x, camera_y = GameGetCameraPos()
    local _, _, bounds_width, bounds_height = GameGetCameraBounds()
    local res_width, res_height = pos_convert.get_res()
    local res_offset_x, res_offset_y = get_res_offset()
    local screen_width, screen_height = get_screen_size()
    return x / screen_width * res_width + camera_x - bounds_width / 2 - res_offset_x,
        y / screen_height * res_height + camera_y - bounds_height / 2 - res_offset_y
end

return pos_convert
