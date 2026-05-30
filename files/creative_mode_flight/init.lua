local module_path = module_path()

local files_used_placeholders = {
    player_child = {
        "entity.xml",
        "update.xml",
    },
}

apply_placeholders(files_used_placeholders, module_path)
