local settings = require "mod_settings"

if settings.get "no_weather" then
    local init_lua_path = "data/scripts/init.lua"
    ModLuaFileAppend(init_lua_path, "%MODULE_PATH%/+init.lua")
    ModTextFileSetContent(init_lua_path, ModTextFileGetContent(init_lua_path))  -- refresh it
end
