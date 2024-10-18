GuiLayoutAddVerticalSpacing( gui, 360 * 0.05 )
local x_pos = ( screen_width + 4 * ( 20 + 2 ) ) * 0.5
local highest_dps = GlobalsGetValue( "spell_lab_shugged_recent_highest_dps","" )
if #highest_dps > 0 then
	GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_dps" )..highest_dps )
end

local total_damage = GlobalsGetValue( "spell_lab_shugged_recent_total_damage","" )
if #total_damage > 0 then
	GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_total_damage" )..total_damage )
end

local player_projectiles = EntityGetWithTag("projectile_player") or {}
local highest_projectile_damage = 0
local highest_damage_projectile = nil
local total_projectile_damage = 0
local total_projectiles = #player_projectiles
for k,v in pairs( player_projectiles ) do
	local projectile = EntityGetFirstComponent( v, "ProjectileComponent" )
	if projectile then
		local damage = ComponentGetValue2( projectile, "damage" ) * 25
		if damage > highest_projectile_damage then
			highest_damage_projectile = v
			highest_projectile_damage = damage
		end
		total_projectile_damage = total_projectile_damage + damage
	end
end
if highest_damage_projectile ~= nil then
	local esx, esy = get_screen_position( EntityGetTransform( highest_damage_projectile ) )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiTextCentered( gui, esx, esy, thousands_separator( math.floor( highest_projectile_damage ) ) )
end
GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_total_projectile_damage" )..thousands_separator( math.floor( total_projectile_damage ) ) )
GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_total_projectiles_num" )..thousands_separator( math.floor( total_projectiles ) ) )