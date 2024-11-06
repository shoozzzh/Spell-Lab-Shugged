local root_id = EntityGetRootEntity( GetUpdatedEntityID() )
if not EntityHasTag( root_id, "player_unit" ) then return end
local damage_model = EntityGetFirstComponentIncludingDisabled( root_id, "DamageModelComponent" )
if not damage_model then return end
local max_hp = ComponentGetValue2( damage_model, "max_hp" )
ComponentSetValue2( damage_model, "hp", max_hp * 0.2 )