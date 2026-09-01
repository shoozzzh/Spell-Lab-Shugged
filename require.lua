local MOD_ID = "spell_lab_shugged"
local MOD_PATH = "mods/" .. MOD_ID .. "/"

local PKGPATH = {
    MOD_PATH .. "files/?.lua",
    MOD_PATH .. "libs/?.lua",
    MOD_PATH .. "libs/?/main.lua",
    MOD_PATH .. "libs/?/?.lua",
}

local cache = {}

function require(name)
    local cached = cache[name]
    if cached then return cached end

    name = name:gsub("%.", "/")
    for _, path in ipairs(PKGPATH) do
        path = path:gsub("?", name)
        if ModDoesFileExist(path) then
            return dofile_once(path)
        end
    end
    print_error('Required module/library "' .. name .. '" does not exist')
end
