local entity_id = GetUpdatedEntityID()

local lighting = ModSettingGet( "spell_lab_shugged.all_seeing_eye_lighting" )
local fog_of_war_removing = ModSettingGet( "spell_lab_shugged.all_seeing_eye_fog_of_war_removing" )

ComponentSetValue2( EntityGetFirstComponent( entity_id, "LightComponent" ), "mAlpha", lighting )
ComponentSetValue2( EntityGetFirstComponent( entity_id, "SpriteComponent" ), "alpha", fog_of_war_removing )