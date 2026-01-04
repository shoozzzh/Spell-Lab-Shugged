GuiImageButton( gui, get_id(), 0, 0, "", "mods/spell_lab_shugged/files/gui/buttons/spawn_convenient_wand.png" )
do
	local left_click,right_click = previous_data( gui )
	local wand_data = {
		stats = {
			shuffle_deck_when_empty = false,
			actions_per_round = 1,
			fire_rate_wait = 10,
			reload_time = 20,
			mana_max = 100000,
			mana_charge_speed = 100000,
			capacity = 26,
			spread_degrees = 0,
			speed_multiplier = 1,
		},
		sprite = {
			file = "data/items_gfx/wands/wand_0821.png",
			hotspot = {
				x = 18.0,
				y = 0.0,
			},
			x = 4,
			y = 3,
		},
	}
	if left_click then
		sound_button_clicked()
		local x, y = get_player_or_camera_position()
		local wand = EntityLoad( "data/entities/items/wand_level_01.xml", x, y )
		WANDS.initialize_wand( wand, wand_data )
	elseif right_click and held_wand then
		sound_button_clicked()
		WANDS.initialize_wand( held_wand, wand_data, false )
	end
end
GuiTooltip( gui, wrap_key( "spawn_best_wand" ), wrap_key( "spawn_best_wand_description" ) )
