function interacting(entity_who_interacted, entity_interacted, interactable_name)
    EntityKill(entity_interacted)
    EntityLoad("%MODULE_PATH%/lazy_loader/entity.xml", 14600, -6000)
end
