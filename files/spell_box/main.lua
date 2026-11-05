local settings = require "mod_settings"
local pop = require "pop"

local gokis = function(action_type, selected, hovered, alpha)
    local spell_box = { "%MODULE_PATH%/goki/spell_box" }
    if action_type then
        spell_box[#spell_box + 1] = "_"
        spell_box[#spell_box + 1] = tostring(action_type)
    end
    if selected then
        spell_box[#spell_box + 1] = "_active"
    elseif hovered then
        spell_box[#spell_box + 1] = "_hover"
    end
    spell_box[#spell_box + 1] = ".png"

    pop.image(table.concat(spell_box), { alpha = alpha })
end

local vanilla_bgs = {
    [0] = "data/ui_gfx/inventory/item_bg_projectile.png",
    [1] = "data/ui_gfx/inventory/item_bg_static_projectile.png",
    [2] = "data/ui_gfx/inventory/item_bg_modifier.png",
    [3] = "data/ui_gfx/inventory/item_bg_draw_many.png",
    [4] = "data/ui_gfx/inventory/item_bg_material.png",
    [5] = "data/ui_gfx/inventory/item_bg_other.png",
    [6] = "data/ui_gfx/inventory/item_bg_utility.png",
    [7] = "data/ui_gfx/inventory/item_bg_passive.png",
}

local vanilla = function(action_type, selected, hovered)
    local box = selected
        and "data/ui_gfx/inventory/full_inventory_box_highlight.png"
        or "data/ui_gfx/inventory/full_inventory_box.png"

    pop.image(box)

    if action_type == nil then return end

    pop.image(vanilla_bgs[action_type])
end

---@type table<string,spellbox_pack>
local spellbox_packs = {
    ---@class spellbox_pack
    ---@field func fun(action_type: int, selected: bool, hovered: bool, alpha: number)
    ---@field ui_name table<string, string>
    GOKIS = {
        func = gokis,
        ui_name = {
            zh_cn = "Goki 经典方案",
            DEFAULT = "Goki's Classic Sprites",
        },
    },
    VANILLA = {
        func = vanilla,
        ui_name = {
            zh_cn = "Noita 原版方案",
            DEFAULT = "Vanilla Sprites",
        },
    },
}

local current_pack
local function update()
    current_pack = spellbox_packs[settings.get_or_default("spellbox_pack", "GOKIS")].func
end
update()

local spell_box = {}

spell_box.update = update

---@param action_type int
---@param selected bool
---@param hovered bool
---@param alpha number
function spell_box.show(action_type, selected, hovered, alpha)
    current_pack(action_type, selected, hovered, alpha)
end

return spell_box
