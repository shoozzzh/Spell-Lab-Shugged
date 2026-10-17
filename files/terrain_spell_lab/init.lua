---@type callbacks
local callbacks = {}

local flag_init = "%MODULE_FULL_ID%.init"
function callbacks.OnWorldInitialized()
    if not GameHasFlagRun(flag_init) then
        EntityLoad("%MODULE_PATH%/lazy_loader/entity.xml", 14600, -6000)
        GameAddFlagRun(flag_init)
    end
end

return callbacks
