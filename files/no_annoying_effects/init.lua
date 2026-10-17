local mutils = require "misc_utils"
local nxml = require "nxml"
local fun = require "tinklin.fun"

dofile_once "%MODULE_PATH%/patches.lua"

---@type callbacks
local callbacks = {}

function callbacks.OnModPostInit()
    local protect_from_these_entities =
        mutils.get_globals "%MODULE_PATH%/entities_protected_from.lua".protect_from_these_entities

    fun.elems(protect_from_these_entities)
        :filter(ModDoesFileExist)
        :each(function(entity_path)
            for content in nxml.edit_file(entity_path) do
                table.insert(content.children, 1, nxml.new_element("LuaComponent", {
                    script_source_file = "%MODULE_PATH%/entity_self_remove.lua",
                    execute_on_added = "1",
                    execute_every_n_frame = "1",
                }))
            end
        end)
end

return callbacks
