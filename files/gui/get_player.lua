-- this file is left at its location for compatiblity reasons(between spell lab shugged and iota multiplayer)

getfenv().get_player = function()
    return EntityGetWithTag "player_unit"[1]
end
