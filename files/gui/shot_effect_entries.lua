shot_effect_entries = {
	{
		related_status = "BLOODY",
		extra_modifiers = "critical_hit_boost",
	},
	{
		related_perk = "RISKY_CRITICAL",
		extra_modifiers = "critical_plus_small",
	},
	{
		related_perk = "PROJECTILE_HOMING_SHOOTER",
		extra_modifiers = { "powerful_shot", "projectile_homing_shooter" },
	},
	{
		related_perk = "FOOD_CLOCK",
		extra_modifiers = "food_clock",
	},
	{
		related_perk = "HUNGRY_GHOST",
		extra_modifiers = "damage_plus_small",
		max_count = -1,
	},
	{
		related_perk = "EXTRA_KNOCKBACK",
		extra_modifiers = "extra_knockback",
	},
	{
		related_perk = "LOWER_SPREAD",
		extra_modifiers = "lower_spread",
	},
	{
		related_perk = "LASER_AIM",
		extra_modifiers = "laser_aim",
	},
	{
		related_perk = "LOW_RECOIL",
		extra_modifiers = "low_recoil",
	},
	{
		related_perk = "BOUNCE",
		extra_modifiers = "bounce",
	},
	{
		id = "PROJECTILE_HOMING_SHOOTER_WIZARD",
		icon = "data/ui_gfx/status_indicators/homing_shooter.png",
		name = "$status_homing_shooter",
		desc = "$statusdesc_homing_shooter",
		extra_modifiers = "projectile_homing_shooter_wizard",
	},
	{
		id = "essence_alcohol",
		icon = "data/items_gfx/essences/essence_alcohol.png",
		name = "$item_essence_alcohol",
		desc = "$itemdesc_essence_alcohol",
		extra_modifiers = "projectile_alcohol_trail",
	},
	{
		related_perk = "DUPLICATE_PROJECTILE",
		extra_modifiers = "duplicate_projectile",
		equivalent_action_type = ACTION_TYPE_UTILITY,
	},
	{
		related_perk = "FAST_PROJECTILES",
		extra_modifiers = "fast_projectiles",
	},
	{
		related_perk = "PERSONAL_LASER",
		extra_modifiers = "slow_firing",
	},
	{
		id = "STATUS_TWITCHY",
		icon = "data/ui_gfx/status_indicators/twitchy.png",
		name = "$status_twitchy",
		desc = "$statusdesc_twitchy",
		scripts_shot = "mods/spell_lab_shugged/files/scripts/saved/twitchy_shot.lua",
		max_count = 1,
	},
	{
		id = "STATUS_NEUTRALIZED",
		icon = "data/ui_gfx/status_indicators/neutralized.png",
		name = "$effect_neutralized",
		desc = "$effectdesc_neutralized",
		scripts_shot = "mods/spell_lab_shugged/files/scripts/saved/neutralized.lua",
		max_count = 1,
	},
}