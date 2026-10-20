local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])

---@type shot_effect[]
shot_effect_entries = {
    {
        related_status = "BLOODY",
        extra_modifier = "critical_hit_boost",
        desc = module_tr.desc.bloody:key(),
    },
    {
        related_perk = "RISKY_CRITICAL",
        extra_modifier = "critical_plus_small",
        desc = module_tr.desc.risky_critical:key(),
    },
    {
        related_perk = "PROJECTILE_HOMING",
        game_effect = "PROJECTILE_HOMING",
    },
    {
        related_perk = "PROJECTILE_HOMING_SHOOTER",
        extra_modifier = { "powerful_shot", "projectile_homing_shooter" },
    },
    {
        related_perk = "FOOD_CLOCK",
        extra_modifier = "food_clock",
        desc = module_tr.desc.food_clock:key(),
    },
    {
        related_custom_effect = "data/entities/misc/effect_damage_plus_small.xml",
        icon = "data/items_gfx/perks/hungry_ghost.png",
        extra_modifier = "damage_plus_small",
        dont_use_fetched_metadata = true,
        properties = {
            { "$inventory_mod_damage", "+7.5" },
            { "$inventory_mod_damage", "x 1.25" },
        },
    },
    {
        related_perk = "EXTRA_KNOCKBACK",
        extra_modifier = "extra_knockback",
    },
    {
        related_perk = "LOWER_SPREAD",
        extra_modifier = "lower_spread",
    },
    {
        related_perk = "LASER_AIM",
        extra_modifier = "laser_aim",
        desc = module_tr.desc.laser_aim:key(),
    },
    {
        related_perk = "LOW_RECOIL",
        extra_modifier = "low_recoil",
        dont_use_fetched_metadata = true,
        properties = {
            { "speed_multiplier",              "x 0.8" },
            { tr.action_metadata.recoil:key(), "x 0.5 - 16" },
        },
    },
    {
        related_perk = "BOUNCE",
        extra_modifier = "bounce",
    },
    {
        related_custom_effect = "data/entities/misc/effect_homing_shooter.xml",
        extra_modifier = "projectile_homing_shooter_wizard",
        desc = module_tr.desc.homing_shooter_wizard:key(),
    },
    {
        id = "essence_alcohol",
        icon = "data/items_gfx/essences/essence_alcohol.png",
        name = "$item_essence_alcohol",
        desc = "$itemdesc_essence_alcohol",
        source_type = "$item_essence_alcohol",
        extra_modifier = "projectile_alcohol_trail",
    },
    {
        related_perk = "DUPLICATE_PROJECTILE",
        extra_modifier = "duplicate_projectile",
        equivalent_action_type = ACTION_TYPE_UTILITY,
        desc = module_tr.desc.duplicate_projectile:key(),
    },
    {
        related_perk = "FAST_PROJECTILES",
        extra_modifier = "fast_projectiles",
    },
    {
        related_perk = "PERSONAL_LASER",
        extra_modifier = "slow_firing",
        desc = module_tr.desc.personal_laser:key(),
    },
    {
        related_perk = "GLASS_CANNON",
        game_effect = "DAMAGE_MULTIPLIER",
        max_count = 2,
        desc = module_tr.desc.glass_cannon:key(),
    },
    {
        related_perk = "LOW_HP_DAMAGE_BOOST",
        game_effect = "LOW_HP_DAMAGE_BOOST",
        custom_child_entity = "mods/spell_lab_shugged/files/entities/low_hp_triggerer.xml",
        max_count = 1,
    },
    {
        related_status = "BERSERK",
        game_effect = "BERSERK",
        max_count = 1,
    },
    {
        related_custom_effect = "data/entities/misc/effect_twitchy.xml",
        shot_script = "data/scripts/status_effects/twitchy_shot.lua",
        max_count = 1,
        properties = {
            { "friendly_fire", tr.action_metadata.enables:key() },
        },
        desc = module_tr.desc.twitchy:key(),
    },
    {
        related_custom_effect = "data/entities/misc/neutralized.xml",
        shot_script = "data/scripts/projectiles/neutralized.lua",
        max_count = 1,
    },
}
