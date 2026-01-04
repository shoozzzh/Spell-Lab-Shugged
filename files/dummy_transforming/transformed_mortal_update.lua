for _, pbody_id in ipairs( PhysicsBodyIDGetFromEntity( GetUpdatedEntityID() ) ) do
	local x, y, a = PhysicsBodyIDGetTransform( pbody_id )
	PhysicsBodyIDSetTransform( pbody_id, x, y, a, 0, 0 )
end