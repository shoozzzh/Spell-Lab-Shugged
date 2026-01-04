local x, y = 14600, -6000
LoadPixelScene( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wang.png", "", 14600-640, -6000-360, "mods/spell_lab_shugged/files/biome_impl/wand_lab/background.png", true, false, nil, 50, true )
EntityLoad( "mods/spell_lab_shugged/files/biome_impl/wand_lab/reload_lab.xml", x, y )
EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target.xml", x - 100, y )
EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target_final.xml", x + 100, y )
EntityLoad( "data/entities/buildings/workshop_spell_visualizer.xml", x - 78, y - 50 )
EntityLoad( "data/entities/buildings/workshop_aabb.xml", x - 78, y - 50 )