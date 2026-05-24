local entfd = {}

local mark_init = "/initialized.txt"
local main_xml = "/entity.xml"
local file_list = "/file_list.lua"

local function apply_placeholders(path)
    if ModTextFileGetContent(path .. mark_init) == "1" then return end

    local file_list = path .. file_list
    if not ModDoesFileExist(file_list) then return end

    ---@type string[]
    local file_list = dofile_once(file_list)
    if not file_list then return end

    for _, file in ipairs(file_list) do
        ModTextFileSetContent(file, ModTextFileGetContent(file):gsub("%THIS_FOLDER%", path))
    end

    ModTextFileSetContent(path .. mark_init, "1")
end

function entfd.get_xml(path)
    apply_placeholders(path)

    return path .. main_xml
end

return entfd
