local module_path = module_path()

local files_used_placeholders = {
    entity = {
        "base.xml",
        "child.xml",
        "entity.xml",
        "entity_final.xml",
    },
    fonts = {
        "red.xml",
        "blue.xml",
        "grey.xml",
        "green.xml",
    },
}

apply_placeholders(files_used_placeholders, module_path)
