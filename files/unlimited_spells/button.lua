local pop = require "pop"
local tr = require "tr"
local tr_utils = require "tr_utils"
local gui_elems = require "gui.elems"
local settings = require "mod_settings"
local common_val = require "common_values"

---@param mb_utils mb_utils
return function(mb_utils)
    if not common_val.unlimited_spells then
        pop.option_next "DrawSemiTransparent"
    end
    if mb_utils.button() then
        gui_elems.sound_button_clicked()

        if not common_val.unlimited_spells then
            if not settings.get "zero_uses" then
                GameRegenItemActionsInPlayer(common_val.player.id)
            end
            local inv2_comp = common_val.player:comp_first "Inventory2Component"
            if inv2_comp then
                inv2_comp.mForceRefresh = true
                inv2_comp.mActualActiveItem = 0
            end
        end

        local ws_comp = common_val.world_state:comp_first "WorldStateComponent"
        if ws_comp then
            ws_comp.perk_infinite_spells = not common_val.unlimited_spells
        end
    end
    pop.tooltip((common_val.unlimited_spells and tr.general.option_disable or tr.general.option_enable)
        :text(tr_utils.get "$perk_unlimited_spells"))
end
