local entity_id = GetUpdatedEntityID()
local child_id = EntityLoad "%THIS_FOLDER%/child.xml"
EntityAddChild(entity_id, child_id)
