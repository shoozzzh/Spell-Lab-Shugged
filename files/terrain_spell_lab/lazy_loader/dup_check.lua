if EntityGetWithName "%MODULE_FULL_ID%.lazy_loader" ~= 0 then
    EntityKill(GetUpdatedEntityID())
end
