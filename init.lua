mod_id = "spell_lab_shugged"
mod_path = "mods/" .. mod_id .. "/"

mod_version = "Shugged v1.8.11"

setmetatable( _G, { __index = { ModTextFileSetContent = ModTextFileSetContent } } )

ModLuaFileAppend( "data/scripts/gun/gun.lua", mod_path .. "files/append/gun/no_recoil.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", mod_path .. "files/append/gun/cast_delay_fixer.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", mod_path .. "files/append/gun/disable_casting.lua" )

dofile( mod_path .. "files/lib/polytools/polytools_init.lua" ).init( mod_path .. "files/lib/polytools/" )

local translations = ModTextFileGetContent( mod_path .. "files/translations.csv" )
local main = "data/translations/common.csv"
local main_content = ModTextFileGetContent( main )
if main_content:sub( #main_content, #main_content ) ~= "\n" then
	main_content = main_content .. "\n"
end
ModTextFileSetContent( main, main_content .. translations:gsub( "^[^\n]*\n", "", 1 ) )

function OnModPostInit()
	local nxml = dofile_once( mod_path .. "files/lib/nxml.lua" )
	dofile_once( mod_path .. "files/scripts/toxic_effect_entities.lua" )
	for _, effect_path in ipairs( toxic_effect_entities ) do
		local effect = ModTextFileGetContent( effect_path )
		if ModDoesFileExist( effect_path ) and effect then
			local parsed = nxml.parse( effect )
			table.insert( parsed.children, 1, nxml.new_element( "LuaComponent", {
				script_source_file = mod_path .. "files/scripts/remove_toxic_effect.lua",
				execute_on_added = true,
				execute_every_n_frame = 1,
			} ) )
			ModTextFileSetContent( effect_path, tostring( parsed ) )
		end
	end
end

local mod_setting_prefix = "spell_lab_shugged."

local default_settings = {
	["quick_spell_picker"] = true,
	["spell_replacement"] = true,
	["show_toggle_options"] = true,
	["show_locked_spells"] = true,
}

if ModSettingGet( mod_setting_prefix .. "no_weather" ) then
	local init_lua_path = "data/scripts/init.lua"
	ModLuaFileAppend( init_lua_path, mod_path .. "files/append/init.lua" )
	ModTextFileSetContent( init_lua_path, ModTextFileGetContent( init_lua_path ) ) -- refresh it
end

for key, value in pairs( default_settings ) do
	if ModSettingGet( mod_setting_prefix .. key ) == nil then
		ModSettingSet( mod_setting_prefix .. key, value )
	end
end

function OnPlayerSpawned( player_id )
	dofile_once( mod_path .. "files/lib/controls_freezer.lua" ).unfreeze()
	GlobalsSetValue( "mod_button_tr_width", "0" )
	if not GameHasFlagRun( "spell_lab_shugged_init" ) then
		EntityLoad( mod_path .. "files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
		GameAddFlagRun( "spell_lab_shugged_init" )
	end
	local not_inited = true
	for _, lua_comp in ipairs( EntityGetComponentIncludingDisabled( player_id, "LuaComponent" ) or {} ) do
		if ComponentGetValue2( lua_comp, "script_source_file" ) == mod_path .. "files/scripts/player_update.lua" then
			not_inited = false
			break
		end
	end
	if not_inited then
		GlobalsSetValue( "spell_lab_shugged.refresh_player_state", "1" )
		EntityAddComponent2( player_id, "LuaComponent", {
			script_source_file = mod_path .. "files/scripts/player_update.lua",
			execute_on_added = true,
			execute_every_n_frame = 1,
		} )
		EntityAddComponent2( player_id, "LuaComponent", { script_shot = mod_path .. "files/scripts/player_shot.lua" })
	end
end

local modules = {
	"gui_main",
	"no_annoying_effects",
	"teleport",
}

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

for _, module in ipairs( modules ) do
	local module_path = _module_path:format( module )

	local init_lua = module_path .. "init.lua"
	if not ModDoesFileExist( init_lua ) then goto continue end

	local module_callbacks = dofile( init_lua ) or {}

	for name, funcs in pairs( callbacks ) do
		funcs[ #funcs + 1 ] = module_callbacks[ name ]
	end

	::continue::
end

for name, funcs in pairs( callbacks ) do
	if #funcs > 0 then
		_G[ name ] = function( ... )
			for _, f in ipairs( funcs ) do f( ... ) end
		end
	end
end
