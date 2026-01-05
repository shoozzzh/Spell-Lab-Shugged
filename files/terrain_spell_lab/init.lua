---@type callbacks
local callbacks = {}

function OnPlayerSpawned( player_id )
	if not GameHasFlagRun( "spell_lab_shugged_init" ) then
		EntityLoad( mod_path .. "files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
		GameAddFlagRun( "spell_lab_shugged_init" )
	end
end
