local mod_id = "spell_lab_shugged"
local mod_path = "mods/" .. mod_id .. "/"

pkgpath = {
    mod_path .. "files/?.lua",
    mod_path .. "libs/?.lua",
    mod_path .. "libs/?/main.lua",
    mod_path .. "libs/?/?.lua",
}

function require( name )
    for _, path in ipairs( pkgpath ) do
        path = path:gsub( "?", name )
        if ModDoesFileExist( path ) then
            return dofile_once( path )
        end
    end
    print_error( 'Required module/library with name "' .. name .. '" does not exist' )
end
