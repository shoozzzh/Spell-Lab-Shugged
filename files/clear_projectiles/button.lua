local tl = require "tinklin"
local pop = require "pop"
local tr = require "tr"
local gui_elems = require "gui.elems"

---@param proj entity
local function silent_kill(proj)
    proj:comps "ProjectileComponent":each(function(comp)
        comp.on_death_explode = false
        comp.on_lifetime_out_explode = false
    end)
    proj:comps "ExplosionComponent":each(function(comp)
        comp.trigger = "ON_CREATE"
    end)
    proj:comps "LightningComponent":each(function(comp)
        comp.meta.enabled = false
    end)
    proj:kill()
end

---@param mb_utils mb_utils
return function(mb_utils)
    if mb_utils.button() then
        gui_elems.sound_button_clicked()

        tl.entity_tagged "projectile":each(silent_kill)
        tl.entity_tagged "player_projectile":each(silent_kill)
    end
    pop.tooltip(tr["%MODULE_ID%"]:key())
end
