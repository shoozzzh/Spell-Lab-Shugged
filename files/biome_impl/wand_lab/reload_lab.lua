function item_pickup( entity_item )
	EntityKill( entity_item )
	-- LoadPixelScene( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wang.png", "", 14600-640, -6000-360, "mods/spell_lab_shugged/files/biome_impl/wand_lab/background.png", true, false, nil, 50, true )
	EntityLoad( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
end