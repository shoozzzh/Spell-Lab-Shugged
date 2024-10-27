GuiLayoutAddVerticalSpacing( gui, 360 * 0.05 )
local x_pos = ( screen_width + 4 * ( 20 + 2 ) ) * 0.5
local highest_dps = GlobalsGetValue( "spell_lab_shugged_recent_highest_dps","" )
if #highest_dps > 0 then
	GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_dps" ) .. highest_dps )
end

local total_damage = GlobalsGetValue( "spell_lab_shugged_recent_total_damage","" )
if #total_damage > 0 then
	GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_total_damage" ) .. total_damage )
end

local player_projectiles = EntityGetWithTag( "spell_lab_shugged_player_projectile" ) or {}
local total_projectile_damage = 0
local total_projectiles = #player_projectiles
for k,v in pairs( player_projectiles ) do
	local projectile = EntityGetFirstComponent( v, "ProjectileComponent" )
	if projectile then
		local damage = ComponentGetValue2( projectile, "damage" )
		total_projectile_damage = total_projectile_damage + damage
	end
end
GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_total_projectile_damage" ) .. separator( math.floor( total_projectile_damage * 25 + 0.5 ) ) )
GuiTextCentered( gui, x_pos, 0, text_get_translated( "damage_info_total_projectiles_num" ) .. separator( math.floor( total_projectiles ) ) )