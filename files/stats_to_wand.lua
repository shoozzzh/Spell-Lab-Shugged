-- this is the same as the algorithm in gun_procedural.lua

---@class s2w.wand_stats
---@field fire_rate_wait integer
---@field actions_per_round integer
---@field shuffle_deck_when_empty boolean
---@field deck_capacity integer
---@field spread_degrees integer
---@field reload_time integer

---@class s2w.wand_stats0
---@field fire_rate_wait integer
---@field actions_per_round integer
---@field shuffle_deck_when_empty integer
---@field deck_capacity integer
---@field spread_degrees integer
---@field reload_time integer

---@class s2w.wand_look
---@field file string
---@field grip_x number
---@field grip_y number
---@field tip_x number
---@field tip_y number

---@class s2w.wand_pattern: s2w.wand_stats0, s2w.wand_look
---@field name string

local mutils = require "misc_utils"
local wands = mutils.get_globals "data/scripts/gun/procedural/wands.lua".wands --[[@as s2w.wand_pattern[] ]]

local function diff(gun, wand)
    local score = 0
    score = score + (math.abs(gun.fire_rate_wait - wand.fire_rate_wait) * 2)
    score = score + (math.abs(gun.actions_per_round - wand.actions_per_round) * 20)
    score = score + (math.abs(gun.shuffle_deck_when_empty - wand.shuffle_deck_when_empty) * 30)
    score = score + (math.abs(gun.deck_capacity - wand.deck_capacity) * 5)
    score = score + math.abs(gun.spread_degrees - wand.spread_degrees)
    score = score + math.abs(gun.reload_time - wand.reload_time)
    return score
end

local function clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

local function copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

---@param stats s2w.wand_stats
---@return s2w.wand_look[]
local function s2w(stats)
    local stats_reduced = {}

    stats_reduced.fire_rate_wait = clamp(((stats.fire_rate_wait + 5) / 7) - 1, 0, 4)
    stats_reduced.actions_per_round = clamp(stats.actions_per_round - 1, 0, 2)
    stats_reduced.shuffle_deck_when_empty = stats.shuffle_deck_when_empty and 1 or 0
    stats_reduced.deck_capacity = clamp((stats.deck_capacity - 3) / 3, 0, 7)
    stats_reduced.spread_degrees = clamp(((stats.spread_degrees + 5) / 5) - 1, 0, 2)
    stats_reduced.reload_time = clamp(((stats.reload_time + 5) / 25) - 1, 0, 2)

    local res = {}
    local best_score = math.huge

    for _, wand in pairs(wands) do
        local score = diff(stats_reduced, wand)
        if score == 0 and best_score == 0 then
            res[#res + 1] = wand
        elseif score <= best_score then
            res[1] = wand
            best_score = score
        end
    end

    for index, wand in ipairs(res) do
        res[index] = copy(wand)
    end

    return res
end

return s2w
