---@type callbacks
local callbacks = {}

function OnPlayerSpawned( player_id )
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
