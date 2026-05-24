mod_id = "spell_lab_shugged"
mod_path = "mods/" .. mod_id .. "/"

mod_version = "Shugged v1.8.11"

mod_setting_prefix = mod_id .. "."

setmetatable(_G, { __index = { ModTextFileSetContent = ModTextFileSetContent } })

-- ModLuaFileAppend( "data/scripts/gun/gun.lua", mod_path .. "files/append/gun/no_recoil.lua" )
-- ModLuaFileAppend( "data/scripts/gun/gun.lua", mod_path .. "files/append/gun/cast_delay_fixer.lua" )
-- ModLuaFileAppend( "data/scripts/gun/gun.lua", mod_path .. "files/append/gun/disable_casting.lua" )

mod_setting = dofile_once(mod_path .. "files/mod_setting.lua")
format = dofile_once(mod_path .. "files/format.lua")
entfd = dofile_once(mod_path .. "files/entity_folder.lua")

stream = dofile_once(mod_path .. "libs/stream.lua")
tl = dofile_once(mod_path .. "libs/tinklin/main.lua")

dofile(mod_path .. "libs/polytools/polytools_init.lua").init(mod_path .. "libs/polytools/")

local translations = ModTextFileGetContent(mod_path .. "files/translations.csv")
local main = "data/translations/common.csv"
local main_content = ModTextFileGetContent(main)
if main_content:sub(#main_content, #main_content) ~= "\n" then
	main_content = main_content .. "\n"
end
ModTextFileSetContent(main, main_content .. translations:gsub("^[^\n]*\n", "", 1))

local default_settings = {
	["quick_spell_picker"] = true,
	["spell_replacement"] = true,
	["show_toggle_options"] = true,
	["show_locked_spells"] = true,
}

for key, value in pairs(default_settings) do
	if mod_setting.get(key) == nil then
		mod_setting.set(key, value)
	end
end

local function replace_placeholders(file, folder)
	file = folder .. file
	if not ModDoesFileExist(file) then
		print_error "file does not exist at:"
		print_error(file)
	end
	local content = ModTextFileGetContent(file)
	content = content:gsub("___", mod_id)
	content = content:gsub("__THIS_FOLDER__", folder)
	ModTextFileSetContent(file, content)
end

function apply_placeholders(path, folder)
	for key, value in pairs(path) do
		if type(key) == "number" then
			replace_placeholders(value, folder)
		elseif type(key) == "string" then
			apply_placeholders(value, folder .. key .. "/")
		end
	end
end

function OnPlayerSpawned(player_id)
	dofile_once(mod_path .. "libs/controls_freezer.lua").unfreeze()
end

local module_list = dofile_once(mod_path .. "files/module_list.lua")

---@class callbacks
---@field OnBiomeConfigLoaded fun()?
---@field OnCountSecrets (fun(): total: integer, found: integer)?
---@field OnMagicNumbersAndWorldSeedInitialized fun()?
---@field OnModInit fun()?
---@field OnModPostInit fun()?
---@field OnModPreInit fun()?
---@field OnModSettingsChanged fun()?
---@field OnPausePreUpdate fun()?
---@field OnPausedChanged fun(is_paused: boolean, is_inventory_pause: boolean)?
---@field OnPlayerDied fun(player_entity: entity_id)?
---@field OnPlayerSpawned fun(player_entity: entity_id)?
---@field OnWorldInitialized fun()?
---@field OnWorldPostUpdate fun()?
---@field OnWorldPreUpdate fun()?

local callbacks = {
	OnBiomeConfigLoaded = {},
	OnCountSecrets = {},
	OnMagicNumbersAndWorldSeedInitialized = {},
	OnModInit = {},
	OnModPostInit = {},
	OnModPreInit = {},
	OnModSettingsChanged = {},
	OnPausePreUpdate = {},
	OnPausedChanged = {},
	OnPlayerDied = {},
	OnPlayerSpawned = {},
	OnWorldInitialized = {},
	OnWorldPostUpdate = {},
	OnWorldPreUpdate = {},
}

local _module_path = mod_path .. "files/%s/"

for _, module in ipairs(module_list) do
	local init_lua = _module_path:format(module) .. 'init.lua'
	if not ModDoesFileExist(init_lua) then goto continue end

	---@type callbacks
	local module_callbacks = dofile(init_lua) or {}

	for name, funcs in pairs(callbacks) do
		funcs[#funcs + 1] = module_callbacks[name]
	end

	::continue::
end

for name, funcs in pairs(callbacks) do
	if #funcs > 0 then
		_G[name] = function(...)
			for _, f in ipairs(funcs) do f(...) end
		end
	end
end
