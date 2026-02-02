local module_path = module_path()

if ModSettingGet( mod_setting_prefix .. "no_weather" ) then
	local init_lua_path = "data/scripts/init.lua"
	ModLuaFileAppend( init_lua_path, module_path .. "+init.lua" )
	ModTextFileSetContent( init_lua_path, ModTextFileGetContent( init_lua_path ) ) -- refresh it
end
