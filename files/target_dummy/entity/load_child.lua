local entity_id = GetUpdatedEntityID()
local child_id = EntityLoad "%THIS_PATH%/child.xml"
EntityAddChild(entity_id, child_id)
