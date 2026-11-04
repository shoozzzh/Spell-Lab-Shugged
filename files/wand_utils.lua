local tl = require "tinklin"
local s2w = require "stat_to_wand"

---@class wand_utils
local wand_utils = {}

---@param wand entity
---@return iterator<entity>
local function iter_actions(wand)
    return wand:get_children():filter(function(e)
        return e:comp_first "ItemComponent" ~= nil and e:comp_first "ItemActionComponent" ~= nil
    end)
end

---@param action entity
local function kill_action(action)
    action:set_parent(nil)
    action:kill()
end

---@param wand entity
function wand_utils.clear(wand)
    local wand = wand_utils.wand_wrap(wand)

    local capacity = wand.capacity
    iter_actions(wand.entity):each(kill_action)
    wand.capacity = capacity
end

---@class wand_utils.action
---@field id string
---@field always_cast boolean
---@field frozen boolean
---@field x integer
---@field y integer
---@field uses_remaining integer

---@param wand entity
---@return wand_utils.action[]
function wand_utils.get_all_actions(wand)
    return iter_actions(wand):foldl(function(result, action)
        local item_comp = action:comp_first "ItemComponent"
        local ia_comp = action:comp_first "ItemActionComponent"
        if not item_comp or not ia_comp then return result end

        local x, y = unpack(item_comp.inventory_slot)
        result[#result + 1] = {
            id             = ia_comp.action_id,
            always_cast    = item_comp.permanently_attached,
            frozen         = item_comp.is_frozen,
            x              = x,
            y              = y,
            uses_remaining = item_comp.uses_remaining,
        }
        return result
    end, {})
end

function wand_utils.get_ac_num(wand)
    return iter_actions(wand)
        :filter(function(action) return action:comp_first "ItemComponent".permanently_attached end)
        :length()
end

function wand_utils.actions_get_ac_num(actions)
    return tl.fun.iter(actions)
        :filter(function(action) return action.permanent end)
        :length()
end

---@class wand_utils.wand_stats
---@field capacity integer
---@field shuffle_deck_when_empty boolean
---@field actions_per_round integer
---@field speed_multiplier number
---@field reload_time integer
---@field fire_rate_wait integer
---@field spread_degrees number
---@field mana_charge_speed integer
---@field mana_max integer

---@class wand_utils.wand: wand_utils.wand_stats
---@field ab_comp AbilityComponent
---@field entity entity

local stat_setter = {
    Direct = 1,
    Gun = 2,
    GunAction = 3,
}

local stat_setters = {
    shuffle_deck_when_empty = stat_setter.Gun,
    actions_per_round = stat_setter.Gun,
    speed_multiplier = stat_setter.GunAction,
    deck_capacity = stat_setter.Gun,
    reload_time = stat_setter.Gun,
    fire_rate_wait = stat_setter.GunAction,
    spread_degrees = stat_setter.GunAction,
    mana_charge_speed = stat_setter.Direct,
    mana_max = stat_setter.Direct,
}

local wand_mt = {
    ---@param t wand_utils.wand
    ---@param k string
    __index = function(t, k)
        if k == "capacity" then
            return EntityGetWandCapacity(t.entity.id)
        end

        local ab_comp = t.ab_comp
        local setter = stat_setters[k]
        if setter == stat_setter.Direct then
            return ab_comp[k]
        elseif setter == stat_setter.Gun then
            return ab_comp:object "gun_config"[k]
        elseif setter == stat_setter.GunAction then
            return ab_comp:object "gunaction_config"[k]
        end
    end,
    ---@param t wand_utils.wand
    ---@param k string
    __newindex = function(t, k, v)
        if k == "capacity" then
            k = "deck_capacity"
            v = v + wand_utils.get_ac_num(t.entity)
        end

        local ab_comp = t.ab_comp
        local setter = stat_setters[k]
        if setter == stat_setter.Direct then
            ab_comp[k] = v
        elseif setter == stat_setter.Gun then
            ab_comp:object "gun_config"[k] = v
        elseif setter == stat_setter.GunAction then
            ab_comp:object "gunaction_config"[k] = v
        end
    end,
}

---@param wand entity
---@return wand_utils.wand
function wand_utils.wand_wrap(wand)
    return setmetatable({
        ab_comp = wand:comp_first "AbilityComponent",
        entity = wand,
    }, wand_mt)
end

---@class wand_utils.owned_wand_stats: wand_utils.wand_stats
---@field capacity integer
---@field shuffle_deck_when_empty boolean
---@field actions_per_round integer
---@field speed_multiplier number
---@field reload_time integer
---@field fire_rate_wait integer
---@field spread_degrees number
---@field mana_charge_speed integer
---@field mana_max integer
-- deck_capacity is more like a hidden technical volatile dirty thing
-- ---@field deck_capacity integer

local wand_stats_fields = {
    "capacity",
    "shuffle_deck_when_empty",
    "actions_per_round",
    "speed_multiplier",
    "reload_time",
    "fire_rate_wait",
    "spread_degrees",
    "mana_charge_speed",
    "mana_max",
}

---@param wand wand_utils.wand
---@return wand_utils.owned_wand_stats res
function wand_utils.get_owned_stats(wand)
    local res = {}
    for _, field in ipairs(wand_stats_fields) do
        res[field] = wand[field]
    end
    return res --[[@as wand_utils.owned_wand_stats]]
end

---@param wand wand_utils.wand
---@param wand_stats wand_utils.wand_stats
function wand_utils.apply_stats(wand, wand_stats)
    for _, field in ipairs(wand_stats_fields) do
        wand[field] = wand_stats[field]
    end
    local is_special_wand = false
    local sprite = wand.entity:comp_first_enabled("SpriteComponent", "item")
    if sprite then
        if not sprite.image_file:sub(-13, -1):match "wand_%d%d%d%d%.png" then
            is_special_wand = true
        end
    end
    if not is_special_wand then
        wand_utils.change_look(wand.entity, wand_utils.get_look_that_matches(wand)[1])
    end
end

---@param wand entity
---@param all_actions wand_utils.action[]
function wand_utils.set_actions(wand, all_actions)
    wand_utils.clear(wand)
    for _, a in ipairs(all_actions) do
        local action_entity = tl.entity_wrap(CreateItemActionEntity(a.id))
        local item = action_entity:comp_first "ItemComponent"
        if item then
            item:set {
                is_frozen = a.frozen,
                uses_remaining = a.uses_remaining,
                inventory_slot = tl.vec(a.x, a.y),
                permanently_attached = a.always_cast,
            }
        end
        action_entity:switch_comps("enabled_in_world", false)
        action_entity:switch_comps("enabled_in_inventory", true)
        action_entity:set_parent(wand)
    end
end

---@param wand entity
---@param look s2w.wand_look
function wand_utils.change_look(wand, look)
    local ab_comp = wand:comp_first "AbilityComponent"
    if ab_comp then
        ab_comp.sprite_file = look.file
    end

    local sp_comp = wand:comp_first("SpriteComponent", "item")
    if sp_comp then
        sp_comp:set {
            image_file = look.file,
            offset_x = look.grip_x,
            offset_y = look.grip_y,
        }
        wand:refresh_sprite_comp(sp_comp)
    end

    local hotspot_comp = wand:comp_first("HotspotComponent", "shoot_pos")
    if hotspot_comp then
        hotspot_comp.offset = tl.vec(look.tip_x, look.tip_y) - tl.vec(look.grip_x, look.grip_y)
    end
end

---@param wand wand_utils.wand
---@return s2w.wand_look[]
function wand_utils.get_look_that_matches(wand)
    local stats = {
        fire_rate_wait = wand.fire_rate_wait,
        actions_per_round = wand.actions_per_round,
        shuffle_deck_when_empty = wand.shuffle_deck_when_empty,
        deck_capacity = wand.ab_comp:object "gun_config".deck_capacity,
        reload_time = wand.reload_time,
        spread_degrees = wand.spread_degrees,
    }
    return s2w(stats)
end

---@class wand_utils.wand_data
---@field stats wand_utils.owned_wand_stats?
---@field all_actions wand_utils.action[]?
---@field name string?
---@field look s2w.wand_look?

---@param wand entity
---@param wand_data wand_utils.wand_data
function wand_utils.apply_wand_data(wand, wand_data)
    local ab_comp = wand:comp_first "AbilityComponent"
    local item_comp = wand:comp_first "ItemComponent"
    if not ab_comp or not item_comp then
        print_error "no AbilityComponent or no ItemComponent found"
        return
    end

    local wand = wand_utils.wand_wrap(wand)

    if wand_data.name then
        ab_comp.ui_name = wand_data.name
        if item_comp then
            item_comp.item_name = wand_data.name
            item_comp.always_use_item_name_in_ui = true
        end
    end

    if wand_data.all_actions then
        wand_utils.set_actions(wand.entity, wand_data.all_actions)
    end

    if wand_data.stats then
        wand_utils.apply_stats(wand, wand_data.stats)
    end
    ab_comp.mana = ab_comp.mana_max

    if wand_data.look then
        wand_utils.change_look(wand.entity, wand_data.look)
    end
end

---@param wand entity
---@param deck_capacity integer
---@return iterator<entity>
local function iter_actions_out_of_bound(wand, deck_capacity)
    return iter_actions(wand)
        :map(function(e) return e:comp_first "ItemComponent" end)
        :filter(function(item_comp)
            return item_comp.inventory_slot < deck_capacity or item_comp.permanently_attached
        end)
end

---@param wand entity
---@param action entity
---@param vel tinklin.vector
local function wand_explode_action_impl(wand, action, vel)
    action:set_parent(nil)
    action.pos = wand.pos
    action:switch_comps("enabled_in_hand", false)
    action:switch_comps("enabled_in_inventory", false)
    action:switch_comps("enabled_in_world", true)
    action:comp_first_enabled "VelocityComponent".mVelocity = vel
end

function wand_utils.explode_actions_out_of_bound(wand)
    wand = wand_utils.wand_wrap(wand)

    local vel = tl.vec(0, -100)
    iter_actions_out_of_bound(wand.entity, wand.ab_comp:object "gun_config".deck_capacity):each(function(action)
        wand_explode_action_impl(wand.entity, action, vel)
        vel[1] = vel[1] + 30
    end)
end

function wand_utils.check_actions_out_of_bound(wand)
    wand = wand_utils.wand_wrap(wand)
    return iter_actions_out_of_bound(wand.entity, wand.ab_comp:object "gun_config".deck_capacity):is_null()
end

return wand_utils
