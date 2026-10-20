local pop = require "pop"
local format = require "format"
local settings = require "mod_settings"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])

return function()
    if not settings.get "damage_info" then return end
    -- GuiLayoutAddVerticalSpacing( gui, 360 * 0.05 )

    local player_projectiles = EntityGetWithTag "%MOD_ID%.player_projectile" or {}
    local total_projectile_damage = 0
    local total_projectiles = #player_projectiles
    for _, v in pairs(player_projectiles) do
        local projectile = EntityGetFirstComponent(v, "ProjectileComponent")
        if projectile then
            local damage = ComponentGetValue2(projectile, "damage")
            total_projectile_damage = total_projectile_damage + math.max(damage, 0)
        end
    end

    local x_pos = (pop.screen_size[1] + 4 * (20 + 2)) * 0.5
    pop.pos.push(x_pos, 0)

    local layout = pop.layout_stack(0, pop.text_line_height)
    layout:next(function()
        pop.text(module_tr.total_proj_dmg:text(format.damage(total_projectile_damage, false, "inf")))
    end)
    layout:next(function()
        pop.text(module_tr.total_projectiles_num:text(total_projectiles))
    end)

    pop.pos.pop()
end
