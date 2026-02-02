local module_path = module_path()

local files_used_placeholders = {
	lazy_loader = {
		"entity.xml",
	},
	"reloader.xml",
}

apply_placeholders( files_used_placeholders, module_path )

---@type callbacks
local callbacks = {}

local flag_terrain_init = mod_id .. ".terrain_init"
function callbacks.OnWorldInitialized()
	if not GameHasFlagRun( flag_terrain_init ) then
		EntityLoad( module_path .. "lazy_loader/entity.xml", 14600, -6000 )
	end
end

return callbacks
