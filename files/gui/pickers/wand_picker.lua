local picker = {}
picker.menu = function()
	GuiBeginAutoBox( gui )
		GuiLayoutBeginVertical( gui, 5, 24 )
			GuiLayoutBeginHorizontal( gui, 0, 0 )
				GuiLayoutBeginVertical( gui, 0, 0 )
					local precise_mode = mod_setting_get( "wand_picker_precise_mode" )
					for _, stat in ipairs( wand_stats ) do
						GuiLayoutBeginHorizontal( gui, 0, 0 )
							local width = GuiGetTextDimensions( gui, stat.label )
							GuiColorSetForNextWidget( gui, 0.811, 0.811, 0.811, 1.0 )
							GuiText( gui, 60 - width, 0, stat.label )
							local _, _, _, x, y, width = previous_data( gui )
							GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
							GuiColorSetForNextWidget( gui, 1.0, 0.75, 0.5, 1.0 )
							GuiText( gui, x + width + 10, y, stat.text_callback( stat.current ) )
							if not precise_mode then
								stat.current = stat.value_callback( GuiSlider( gui, next_id(), 70, 0, " ", stat.current, stat.min, stat.max, stat.default, 1.0, stat.formatter, 140 ) )
							else
								local first_button = true
								for _, button in ipairs( stat.buttons_precise_mode or {} ) do
									local _x = 0
									if first_button then
										_x = 70
										first_button = false
									end
									local text = button.text
									if type( text ) == "function" then
										text = text()
									end
									GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
									GuiButton( gui, _x, 0, text, next_id() )
									local left_click, right_click = previous_data( gui )
									if type( stat.current ) == "boolean" then
										stat.current = stat.current and 1 or 0
									end
									if left_click then
										stat.current = stat.current + button.value
										GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
									elseif right_click then
										stat.current = stat.current - button.value
										GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
									end
								end
								if stat.name == "shuffle_deck_when_empty" then
									stat.current = math.min( stat.max, math.max( stat.min, stat.current ) )
								end
							end
						GuiLayoutEnd( gui )
					end
					GuiLayoutBeginHorizontal( gui, 0, 2 )
					if GuiButton( gui, 0, 0, wrap_key( "wand_picker_spawn_wand" ), next_id() ) then
						if player then
							local x, y = EntityGetTransform( player )
							local wand = EntityLoad( "data/entities/items/wand_level_01.xml", x, y )
							local wand_data = {
								stats = {}
							}
							for _,stat_data in ipairs( wand_stats ) do
								wand_data.stats[stat_data.stat] = stat_data.current
							end
							wand_data.stats["shuffle_deck_when_empty"] = wand_data.stats["shuffle_deck_when_empty"] == 1
							WANDS.initialize_wand( wand, wand_data )
						end
					end
					if held_wand then
						if GuiButton( gui, 8, 0, wrap_key( "wand_picker_copy_held_wand" ), next_id() ) then
							if held_wand then
								local stats = WANDS.wand_get_stats( held_wand )
								if stats then
									for k,v in pairs( stats ) do
										for _,stat_data in ipairs( wand_stats ) do
											if stat_data.stat == k then
												stat_data.current = v
												break
											end
										end
									end
								end
							end
						end
						if GuiButton( gui, 8, 0, wrap_key( "wand_picker_update_held_wand" ), next_id() ) then
							if player then
								local held_wand = get_entity_held_or_random_wand( player, false )
								if held_wand then
									local x, y = EntityGetTransform( player )
									local wand_data = {
										stats = {}
									}
									for _,stat_data in ipairs( wand_stats ) do
										wand_data.stats[stat_data.stat] = stat_data.current
									end
									local do_update = true
									local deck_capacity = wand_data.stats.capacity + WANDS.wand_get_num_actions_permanent( wand )
									if not WANDS.wand_check_actions_out_of_bound( held_wand, deck_capacity ) then
										if not shift then
											GamePrint( text_get_translated( "wand_picker_exploding_actions" ) )
											do_update = false
										end
									end
									if do_update then
										wand_data.stats.shuffle_deck_when_empty = wand_data.stats.shuffle_deck_when_empty == 1
										WANDS.initialize_wand( held_wand, wand_data, false )
										WANDS.wand_explode_actions_out_of_bound( held_wand )
										force_refresh_held_wands()
									end
								end
							end
						end
					end
					if GuiButton( gui, 8, 0, GameTextGet( wrap_key( "wand_picker_precise_mode" ), text_get_translated( precise_mode and "disable" or "enable" ) ), next_id() ) then
						mod_setting_set( "wand_picker_precise_mode", not precise_mode )
					end
					if precise_mode then
						GuiTooltip( gui, wrap_key( "wand_picker_precise_mode_tips" ), "" )
					end
					GuiLayoutEnd( gui )
				GuiLayoutEnd( gui )
			GuiLayoutEnd( gui )
		GuiLayoutEnd( gui )
		GuiZSetForNextWidget( gui, 1 )
	GuiEndAutoBoxNinePiece( gui )
end

picker.buttons = function() end

return picker