local injected_lua_folder = mod_path .. "files/scripts/saved/"

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
