local pop = require "pop"
local gui_elems = require "gui.elems"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local format = require "format"
local get_player = require "get_player"

local tag_created_twwe = "%MODULE_FULL_ID%.created_twwe"
local tag_created_nwt = "%MODULE_FULL_ID%.created_nwt"

---@param mb_utils mb_utils
return function(mb_utils)
    local player_id = get_player()

    local num_effects_positive = GameGetGameEffectCount(player_id, "EDIT_WANDS_EVERYWHERE")
    local num_effects_negative = GameGetGameEffectCount(player_id, "NO_WAND_EDITING")

    local wand_editing_level = num_effects_positive - num_effects_negative
    if wand_editing_level == 0 then
        pop.option_next "DrawSemiTransparent"
    end
    local left_click, right_click = mb_utils.button()

    local a = #EntityGetWithTag(tag_created_twwe)
    local b = #EntityGetWithTag(tag_created_nwt)
    local c = GameGetGameEffectCount(player_id, "EDIT_WANDS_EVERYWHERE") - a
    local d = GameGetGameEffectCount(player_id, "NO_WAND_EDITING") - b
    local level = a + c - b - d
    local tooltip = {
        module_tr.gain:text(module_tr.twwe:text()),
        module_tr.lose:text(module_tr.nwt:text()),
    }

    if num_effects_positive > 0 then
        tooltip[#tooltip + 1] = module_tr.num:text(module_tr.twwe:text(),
            format.decimal(a, 0), format.decimal(c, 0))
    end
    if num_effects_negative > 0 then
        tooltip[#tooltip + 1] = module_tr.num:text(module_tr.nwt:text(),
            format.decimal(b, 0), format.decimal(d, 0))
    end

    local expr = {}
    local function add_num_to_expr(num)
        if #expr > 0 then
            expr[#expr + 1] = " + "
        end
        if num > 0 then
            expr[#expr + 1] = tostring(num)
        elseif num == 0 then
            expr[#expr + 1] = "0"
        elseif num < 0 then
            expr[#expr + 1] = "("
            expr[#expr + 1] = tostring(num)
            expr[#expr + 1] = ")"
        end
    end

    if a ~= 0 or c ~= 0 then
        add_num_to_expr(a)
        add_num_to_expr(c)
    end
    if b ~= 0 or d ~= 0 then
        add_num_to_expr(-b)
        add_num_to_expr(-d)
    end

    if #expr > 0 then
        expr[#expr + 1] = " = "
    end
    expr[#expr + 1] = tostring(level)

    if level > 0 then
        expr[#expr + 1] = " > 0"
    elseif level < 0 then
        expr[#expr + 1] = " < 0"
    end

    tooltip[#tooltip + 1] = module_tr.level:text(table.concat(expr))

    if level > 0 then
        tooltip[#tooltip + 1] = module_tr.result.everywhere:key()
    elseif level == 0 then
        tooltip[#tooltip + 1] = module_tr.result.workshop:key()
    else
        tooltip[#tooltip + 1] = module_tr.result.unable:key()
    end

    if left_click then
        gui_elems.sound_button_clicked()
        local effect_to_remove = EntityGetWithTag(tag_created_nwt)[1]
        if effect_to_remove then
            EntityRemoveTag(effect_to_remove, tag_created_nwt)
            EntityRemoveFromParent(effect_to_remove)
            EntityKill(effect_to_remove)
        else
            local effect_id = EntityCreateNew()
            EntityAddChild(player_id, effect_id)
            EntityAddComponent2(effect_id, "GameEffectComponent", {
                effect = "EDIT_WANDS_EVERYWHERE",
                frames = -1,
            })
            EntityAddTag(effect_id, tag_created_twwe)
        end
    elseif right_click then
        gui_elems.sound_button_clicked()
        local effect_to_remove = EntityGetWithTag(tag_created_twwe)[1]
        if effect_to_remove then
            EntityRemoveTag(effect_to_remove, tag_created_twwe)
            EntityRemoveFromParent(effect_to_remove)
            EntityKill(effect_to_remove)
        else
            local effect_id = EntityCreateNew()
            EntityAddChild(player_id, effect_id)
            EntityAddComponent2(effect_id, "GameEffectComponent", {
                effect = "NO_WAND_EDITING",
                frames = -1,
            })
            EntityAddTag(effect_id, tag_created_nwt)
        end
    end

    pop.tooltip(unpack(tooltip))
end
