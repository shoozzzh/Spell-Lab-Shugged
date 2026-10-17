local stored_path = "%MODULE_PATH%/stored/"

local set_content = ModTextFileSetContent
local get_content = ModTextFileGetContent

local twitchy_effect_path = "data/entities/misc/effect_twitchy.xml"
local twitchy_effect = get_content(twitchy_effect_path)
if ModDoesFileExist(twitchy_effect_path) and twitchy_effect then
    local twitchy_lua_path = "data/scripts/status_effects/twitchy.lua"
    if ModDoesFileExist(twitchy_lua_path) then
        local twitchy_lua = get_content(twitchy_lua_path)
        set_content(stored_path .. "twitchy.lua",
            [[if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
				if EntityGetParent( GetUpdatedEntityID() ) ~= 0 then
					EntityKill( GetUpdatedEntityID() )
				else
					EntityRemoveComponent( GetUpdatedEntityID(), GetUpdatedComponentID() )
				end
				return
			end
			]] .. twitchy_lua)
        twitchy_effect = twitchy_effect:gsub(twitchy_lua_path:gsub("%.", "%."), stored_path .. "twitchy.lua")
    end

    local twitchy_lua2_path = "data/scripts/status_effects/twitchy_shot.lua"
    if ModDoesFileExist(twitchy_lua2_path) then
        local twitchy_lua2 = get_content(twitchy_lua2_path)
        set_content(stored_path .. "twitchy_shot.lua",
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
			end]])
        twitchy_effect = twitchy_effect:gsub(twitchy_lua_path:gsub("%.", "%."),
            stored_path .. "twitchy_shot.lua")
    end

    set_content(twitchy_effect_path, twitchy_effect)
end

local neutralized_effect_path = "data/entities/misc/neutralized.xml"
local neutralized_effect = get_content(neutralized_effect_path)
if ModDoesFileExist(neutralized_effect_path) and neutralized_effect then
    local neutralized_lua_path = "data/scripts/projectiles/neutralized.lua"
    if ModDoesFileExist(neutralized_lua_path) then
        local neutralized_lua = get_content(neutralized_lua_path)
        set_content(stored_path .. "neutralized.lua",
            neutralized_lua .. [[
			local old_shot = shot
			function shot( projectile_id )
				if EntityHasTag( EntityGetRootEntity( GetUpdatedEntityID() ), "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
					EntityKill( GetUpdatedEntityID() )
					return
				end
				old_shot( projectile_id )
			end]])
        neutralized_effect = neutralized_effect:gsub(neutralized_lua_path:gsub("%.", "%."),
            stored_path .. "neutralized.lua")
    end

    set_content(neutralized_effect_path, neutralized_effect)
end

local glue_lua_path = "data/scripts/projectiles/glue_init.lua"
local glue_lua = get_content(glue_lua_path)
if ModDoesFileExist(glue_lua_path) and glue_lua then
    set_content(glue_lua_path, glue_lua:gsub("if target2 ~= target then",
        [[if EntityHasTag( target2, "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then return end
		if target2 ~= target then]]))
end
