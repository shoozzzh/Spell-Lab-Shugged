shot_effect_entries = {
	{
		related_status = "BLOODY",
		extra_modifier = "critical_hit_boost",
		desc = wrap_key( "shot_effect_desc_bloody" ),
	},
	{
		related_perk = "RISKY_CRITICAL",
		extra_modifier = "critical_plus_small",
		desc = wrap_key( "shot_effect_desc_risky_critical" ),
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
		desc = wrap_key( "shot_effect_desc_food_clock" ),
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
		desc = wrap_key( "shot_effect_desc_laser_aim" ),
	},
	{
		related_perk = "LOW_RECOIL",
		extra_modifier = "low_recoil",
		metadata = {
			{ "speed_multiplier", 0.8 },
			{ wrap_key( "recoil" ), { TYPE_ADJUSTMENT.Add, -16 } },
		},
		properties = {
			{ wrap_key( "recoil" ), "x 0.5" },
		},
	},
	{
		related_perk = "BOUNCE",
		extra_modifier = "bounce",
	},
	{
		related_custom_effect = "data/entities/misc/effect_homing_shooter.xml",
		extra_modifier = "projectile_homing_shooter_wizard",
		desc = wrap_key( "shot_effect_desc_homing_shooter_wizard" ),
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
		desc = wrap_key( "shot_effect_desc_duplicate_projectile" ),
	},
	{
		related_perk = "FAST_PROJECTILES",
		extra_modifier = "fast_projectiles",
	},
	{
		related_perk = "PERSONAL_LASER",
		extra_modifier = "slow_firing",
		desc = wrap_key( "shot_effect_desc_personal_laser" ),
	},
	{
		related_perk = "GLASS_CANNON",
		game_effect = "DAMAGE_MULTIPLIER",
		max_count = 2,
		desc = wrap_key( "shot_effect_desc_glass_cannon" ),
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
		metadata = {
			{ "friendly_fire", true },
		},
		desc = wrap_key( "shot_effect_desc_twitchy" ),
	},
	{
		related_custom_effect = "data/entities/misc/neutralized.xml",
		shot_script = "data/scripts/projectiles/neutralized.lua",
		max_count = 1,
	},
}