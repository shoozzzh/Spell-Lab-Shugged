dofile_once( "mods/spell_lab_shugged/files/lib/wands.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/spell_lab_shugged/files/append/gun.lua" )

local translations = ModTextFileGetContent("mods/spell_lab_shugged/files/translations.csv")
local main = "data/translations/common.csv"
local main_content = ModTextFileGetContent(main)
if main_content:sub( #main_content, #main_content ) ~= "\n" then
	main_content = main_content .. "\n"
end
ModTextFileSetContent(main, main_content .. translations:gsub("^[^\n]*\n", "", 1))

local twitchy_effect = ModTextFileGetContent( "data/scripts/status_effects/twitchy.lua" )
ModTextFileSetContent( "data/scripts/status_effects/twitchy.lua",
	'if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then EntityKill( GetUpdatedEntityID() ) return end\n'
	.. twitchy_effect )
local twitchy_effect2 = ModTextFileGetContent( "data/scripts/status_effects/twitchy_shot.lua" )
ModTextFileSetContent( "data/scripts/status_effects/twitchy_shot.lua",
	'if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then shot = function() EntityKill( GetUpdatedEntityID() ) end return end\n'
	.. twitchy_effect2 )
local neutralized_effect = ModTextFileGetContent( "data/scripts/projectiles/neutralized.lua" )
ModTextFileSetContent( "data/scripts/projectiles/neutralized.lua",
	'if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then shot = function() EntityKill( GetUpdatedEntityID() ) end return end\n'
	.. neutralized_effect )

local mod_setting_prefix = "spell_lab_shugged."

local default_settings = {
	["quick_spell_picker"] = true,
	["spell_replacement"] = true,
	["show_toggle_options"] = true,
	["show_locked_spells"] = true,
}

if ModSettingGet( mod_setting_prefix .. "no_weather" ) then
	ModLuaFileAppend( "data/scripts/init.lua", "mods/spell_lab_shugged/files/append/init.lua" )
end

ModTextFileSetContent_Saved = ModTextFileSetContent

for key, value in pairs( default_settings ) do
	if ModSettingGet( mod_setting_prefix .. key ) == nil then
		ModSettingSet( mod_setting_prefix .. key, value )
	end
end

function OnPlayerSpawned( player_id )
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
		EntityAddComponent2( player_id, "LuaComponent", { script_source_file="mods/spell_lab_shugged/files/scripts/player_update.lua", execute_every_n_frame=1 })
		EntityAddComponent2( player_id, "LuaComponent", { script_shot="mods/spell_lab_shugged/files/scripts/player_shot.lua" })
	end
end

function OnPausedChanged( is_paused )
	local entities_to_hide = EntityGetWithTag("hide_on_pause")
	for _,v in pairs( entities_to_hide or {} ) do
		local sprites = EntityGetComponentIncludingDisabled( v, "SpriteComponent" )
		for _,sprite in pairs( sprites or {} ) do
			EntitySetComponentIsEnabled( v, sprite, not is_paused )
			EntityRefreshSprite( v, sprite )
		end
	end
end

function OnWorldInitialized()
	local mod_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_width", "0" ) )
	GlobalsSetValue( "spell_lab_shugged_mod_button_reservation", tostring( mod_button_reservation ) )
	GlobalsSetValue( "mod_button_tr_width", tostring( mod_button_reservation + 15 ) )
end

-- local gui_ = GuiCreate()
function OnWorldPreUpdate()
	-- full_screen_width, full_screen_height = GuiGetScreenDimensions( gui_ )
	dofile( "mods/spell_lab_shugged/files/gui/update.lua" )
end

function OnWorldPostUpdate()
	GlobalsSetValue( "mod_button_tr_current", "0" )
end