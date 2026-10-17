-- this file is left at its location for compatiblity reasons(between spell lab shugged and iota multiplayer)

---@diagnostic disable-next-line: lowercase-global
_G["get" .. "_player"] = function()
    return EntityGetWithTag "player_unit"[1]
end
