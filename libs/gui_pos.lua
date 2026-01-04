local gui_pos = {}

function gui_pos.get_resolution(gui)
    local virtual_resolution_x = tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_X"))
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    return virtual_resolution_x, virtual_resolution_x * screen_height / screen_width
end

function gui_pos.get_pos_on_screen(gui, x, y)
    local camera_x, camera_y = GameGetCameraPos()
    local bounds_x, bounds_y, bounds_width, bounds_height = GameGetCameraBounds()
    local resolution_width, resolution_height = gui_pos.get_resolution(gui)
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    return (x - camera_x + bounds_width / 2 + tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_X"))) / resolution_width * screen_width,
        (y - camera_y + bounds_height / 2 + tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_Y"))) / resolution_height * screen_height
end

function gui_pos.get_pos_in_world(gui, x, y)
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local resolution_width, resolution_height = gui_pos.get_resolution(gui)
    local camera_x, camera_y = GameGetCameraPos()
    local bounds_x, bounds_y, bounds_width, bounds_height = GameGetCameraBounds()
    return x / screen_width * resolution_width + camera_x - bounds_width / 2 - tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_X")),
        y / screen_height * resolution_height + camera_y - bounds_height / 2 - tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_Y"))
end

return gui_pos