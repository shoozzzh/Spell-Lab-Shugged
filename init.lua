ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/spell_lab_shugged/files/append/gun/no_recoil.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/spell_lab_shugged/files/append/gun/cast_delay_fixer.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/spell_lab_shugged/files/append/gun/disable_casting.lua" )

dofile( "mods/spell_lab_shugged/files/lib/polytools/polytools_init.lua" ).init( "mods/spell_lab_shugged/files/lib/polytools/" )

local translations = ModTextFileGetContent( "mods/spell_lab_shugged/files/translations.csv" )
local main = "data/translations/common.csv"
local main_content = ModTextFileGetContent( main )
if main_content:sub( #main_content, #main_content ) ~= "\n" then
	main_content = main_content .. "\n"
end
ModTextFileSetContent( main, main_content .. translations:gsub( "^[^\n]*\n", "", 1 ) )

local injected_lua_folder = "mods/spell_lab_shugged/files/scripts/saved/"

local twitchy_effect_path = "data/entities/misc/effect_twitchy.xml"
local twitchy_effect = ModTextFileGetContent( twitchy_effect_path )
if ModDoesFileExist( twitchy_effect_path ) and twitchy_effect then
	local twitchy_lua_path = "data/scripts/status_effects/twitchy.lua"
	if ModDoesFileExist( twitchy_lua_path ) then
		local twitchy_lua = ModTextFileGetContent( twitchy_lua_path )
		ModTextFileSetContent( injected_lua_folder .. "twitchy.lua",
			[[if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
				if EntityGetParent( GetUpdatedEntityID() ) ~= 0 then
					EntityKill( GetUpdatedEntityID() )
				else
					EntityRemoveComponent( GetUpdatedEntityID(), GetUpdatedComponentID() )
				end
				return
			end
			]] .. twitchy_lua )
		twitchy_effect = twitchy_effect:gsub( twitchy_lua_path:gsub( "%.", "%." ), injected_lua_folder .. "twitchy.lua" )
	end

	local twitchy_lua2_path = "data/scripts/status_effects/twitchy_shot.lua"
	if ModDoesFileExist( twitchy_lua2_path ) then
		local twitchy_lua2 = ModTextFileGetContent( twitchy_lua2_path )
		ModTextFileSetContent( injected_lua_folder .. "twitchy_shot.lua",
			twitchy_lua2 .. [[
			local old_shot = shot
			function shot( projectile_id )
				if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
					if EntityGetParent( GetUpdatedEntityID() ) ~= 0 then
						EntityKill( GetUpdatedEntityID() )
					else
						EntityRemoveComponent( GetUpdatedEntityID(), GetUpdatedComponentID() )
					end
					return
				end
				old_shot( projectile_id )
			end]] )
		twitchy_effect = twitchy_effect:gsub( twitchy_lua_path:gsub( "%.", "%." ), injected_lua_folder .. "twitchy_shot.lua" )
	end

	ModTextFileSetContent( twitchy_effect_path, twitchy_effect )
end

local neutralized_effect_path = "data/entities/misc/neutralized.xml"
local neutralized_effect = ModTextFileGetContent( neutralized_effect_path )
if ModDoesFileExist( neutralized_effect_path ) and neutralized_effect then
	local neutralized_lua_path = "data/scripts/projectiles/neutralized.lua"
	if ModDoesFileExist( neutralized_lua_path ) then
		local neutralized_lua = ModTextFileGetContent( neutralized_lua_path )
		ModTextFileSetContent( injected_lua_folder .. "neutralized.lua",
			neutralized_lua .. [[
			local old_shot = shot
			function shot( projectile_id )
				if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
					EntityKill( GetUpdatedEntityID() )
					return
				end
				old_shot( projectile_id )
			end]] )
		neutralized_effect = neutralized_effect:gsub( neutralized_lua_path:gsub( "%.", "%." ), injected_lua_folder .. "neutralized.lua" )
	end

	ModTextFileSetContent( neutralized_effect_path, neutralized_effect )
end

local glue_lua_path = "data/scripts/projectiles/glue_init.lua"
local glue_lua = ModTextFileGetContent( glue_lua_path )
if ModDoesFileExist( glue_lua_path ) and glue_lua then
	ModTextFileSetContent( glue_lua_path, glue_lua:gsub( "if target2 ~= target then",
		[[if EntityHasTag( target2, "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then return end
		if target2 ~= target then]] ) )
end

function OnModPostInit()
	local nxml = dofile_once( "mods/spell_lab_shugged/files/lib/nxml.lua" )
	dofile_once( "mods/spell_lab_shugged/files/scripts/toxic_effect_entities.lua" )
	for _, effect_path in ipairs( toxic_effect_entities ) do
		local effect = ModTextFileGetContent( effect_path )
		if ModDoesFileExist( effect_path ) and effect then
			local parsed = nxml.parse( effect )
			table.insert( parsed.children, 1, nxml.new_element( "LuaComponent", {
				script_source_file = "mods/spell_lab_shugged/files/scripts/remove_toxic_effect.lua",
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
	ModLuaFileAppend( init_lua_path, "mods/spell_lab_shugged/files/append/init.lua" )
	ModTextFileSetContent( init_lua_path, ModTextFileGetContent( init_lua_path ) ) -- refresh it
end

ModTextFileSetContent_Saved = ModTextFileSetContent

for key, value in pairs( default_settings ) do
	if ModSettingGet( mod_setting_prefix .. key ) == nil then
		ModSettingSet( mod_setting_prefix .. key, value )
	end
end

dofile_once( "mods/spell_lab_shugged/files/lib/controls_freezing_utils.lua" )
function OnPlayerSpawned( player_id )
	unfreeze_controls()
	GlobalsSetValue( "mod_button_tr_width", "0" )
	if not GameHasFlagRun( "spell_lab_shugged_init" ) then
		EntityLoad( "mods/spell_lab_shugged/files/biome_impl/wand_lab/wand_lab.xml", 14600, -6000 )
		GameAddFlagRun( "spell_lab_shugged_init" )
	end
	local not_inited = true
	for _, lua_comp in ipairs( EntityGetComponentIncludingDisabled( player_id, "LuaComponent" ) or {} ) do
		if ComponentGetValue2( lua_comp, "script_source_file" ) == "mods/spell_lab_shugged/files/scripts/player_update.lua" then
			not_inited = false
			break
		end
	end
	if not_inited then
		GlobalsSetValue( "spell_lab_shugged.refresh_player_state", "1" )
		EntityAddComponent2( player_id, "LuaComponent", {
			script_source_file = "mods/spell_lab_shugged/files/scripts/player_update.lua",
			execute_on_added = true,
			execute_every_n_frame = 1,
		} )
		EntityAddComponent2( player_id, "LuaComponent", { script_shot = "mods/spell_lab_shugged/files/scripts/player_shot.lua" })
	end
end

function OnWorldInitialized()
	local mod_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_width", "0" ) )
	GlobalsSetValue( "spell_lab_shugged_mod_button_reservation", tostring( mod_button_reservation ) )
	GlobalsSetValue( "mod_button_tr_width", tostring( mod_button_reservation + 15 ) )
end

function OnWorldPreUpdate()
	dofile( "mods/spell_lab_shugged/files/gui/update.lua" )
end

function OnWorldPostUpdate()
	GlobalsSetValue( "mod_button_tr_current", "0" )
end