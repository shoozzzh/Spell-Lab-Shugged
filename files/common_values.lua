local tl = require "tinklin"
local sc = require "shortcuts"
local get_player = require "get_player"

---@class common_values
local common_val = {}

local function get_held_wand(player)
    if not player then return end

    local inv2_comp = player:comp_first_enabled "Inventory2Component"
    if not inv2_comp then return end

    return inv2_comp.mActiveItem
end

local function get_world_dest_pos()
    local player_id = get_player()
    if player_id then
        local x, y = EntityGetTransform(player_id)
        return x, y
    elseif EntityGetIsAlive(GameGetWorldStateEntity()) then -- GameGetCameraPos() crashes during init-ing
        return GameGetCameraPos()
    else
        return 0, 0
    end
end

---@type entity?
common_val.player = tl.entity_wrap(0)
---@type entity?
common_val.held_wand = tl.entity_wrap(0)
---@type entity?
common_val.world_state = tl.entity_wrap(0)

---@param field string
---@param id entity_id
local function update_entity(field, id)
    if id == nil then
        common_val[field] = nil
        return
    elseif id and (common_val[field] == nil) then
        common_val[field] = tl.entity_wrap(id)
    end
    common_val[field].id = id
end

function common_val.update()
    update_entity("player", get_player())
    update_entity("held_wand", get_held_wand(common_val.player))

    common_val.now = GameGetFrameNum()

    ---@type {[1]: number, [2]: number}
    common_val.world_dest_pos = { get_world_dest_pos() }

    update_entity("world_state", GameGetWorldStateEntity())

    local ws_comp = common_val.world_state:comp_first "WorldStateComponent"
    common_val.unlimited_spells = (ws_comp ~= nil) and ws_comp.perk_infinite_spells

    common_val.ctrl = sc.detector.is_held(sc.table.modifier_key_1)
    common_val.shift = sc.detector.is_held(sc.table.modifier_key_2)
    common_val.alt = sc.detector.is_held(sc.table.modifier_key_3)
end

common_val.update()

return common_val
