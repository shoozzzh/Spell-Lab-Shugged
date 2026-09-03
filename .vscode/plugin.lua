---@class diff
---@field start  integer # The number of bytes at the beginning of the replacement
---@field finish integer # The number of bytes at the end of the replacement
---@field text   string  # What to replace

---@class ph_def
---@field [1] string
---@field [2] integer
---@field [3] fun(input: string): string

---@type ph_def[]
local placeholders = {
    -- { "()%%MOD_ID%%", #("%MOD_ID%"), function(input)
    -- 	return input:match "mods/([^/]+)/"
    -- end },
    { "()%%MOD_PATH%%", #("%MOD_PATH%"), function(input)
        return input:match "(mods/[^/]+)/"
    end },
    -- { "()%%MODULE_ID%%", #("%MODULE_ID%"), function(input)
    -- 	return input:match "mods/[^/]+/files/([^/]+)/"
    -- end },
    { "()%%MODULE_PATH%%", #("%MODULE_PATH%"), function(input)
        return input:match "(mods/[^/]+/files/[^/]+)/"
    end },
    -- { "()%%MODULE_FULL_ID%%", #("%MODULE_FULL_ID%"), function(input)
    -- 	return table.concat({ input:match "mods/([^/]+)/files/([^/]+)/" }, ".")
    -- end },
    { "()%%THIS_PATH%%", #("%THIS_PATH%"), function(input)
        return input:match "(mods.*)/[^/]+%.[a-z]+$"
    end },
}

---@type ph_def[]
local placeholders_init_lua = {
    { '()mod_path %.%. "', #('mod_path .. "'), function(input)
        return '"' .. input:match "(mods/[^/]+/)"
    end },
}

local print = print
local debugging = false
if debugging then
    -- leave print() alone
else
    print = function(...) end
end

---@param  uri  string # The uri of file
---@param  text string # The content of file
---@return nil|diff[]
function OnSetText(uri, text)
    -- print("dealing with "..uri)
    local diffs = {}

    local phs
    if uri:match "mods/[a-z_]+/init%.lua$" then
        phs = placeholders_init_lua
    else
        phs = placeholders
    end

    for _, p in ipairs(phs) do
        local find, len, extract = p[1], p[2], p[3]
        local new_text = nil
        for pos_start in string.gmatch(text, find) do
            if new_text == nil then
                new_text = extract(uri)
            end
            diffs[#diffs + 1] = {
                start = pos_start,
                finish = pos_start + len - 1,
                text = new_text,
            }
        end
    end

    return diffs
end

---@param  uri  string # The URI of file
---@param  name string # Argument of require()
---@return string[]?
function ResolveRequire(uri, name)
    print(uri, name)

    local result = nil
    local start = name:sub(1, 4)

    if start == "mods" then
        local mods_path = uri:match "^(.*mods)"
        if not mods_path then return nil end
        result = mods_path .. name:sub(5, -1)
    elseif start == "data" then
        result = "file:///" .. os.getenv "localappdata" .. "Low/Nolla_Games_Noita/data" .. name:sub(5, -1)
    end

    if result ~= nil then
        print("resolved to " .. result)
        return { result }
    else
        print "skipped"
        return nil
    end
end
