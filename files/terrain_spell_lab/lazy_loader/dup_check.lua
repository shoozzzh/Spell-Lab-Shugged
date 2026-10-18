if EntityGetWithName "%MODULE_FULL_ID%.lazy_loader" ~= GetUpdatedEntityID() then
    EntityKill(GetUpdatedEntityID())
end
