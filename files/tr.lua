if false then
    ---@class tr.key
    local key = {}
    ---@vararg any
    function key:text(...)
        return "" .. ""
    end

    function key:key()
        return "" .. ""
    end
end

local concat = table.concat

local tr_methods = {
    text = function(self, param1, ...)
        if param1 then
            return GameTextGet(concat(self, ".")):format(param1, ...)
        end
        return GameTextGet(concat(self, "."))
    end,
    key = function(self)
        return concat(self, ".")
    end,
}

local tr_mt = {
    __index = function(t, k)
        local m = tr_methods[k]
        if m then return m end

        t[#t + 1] = k
        return t
    end,
}

---@class tr: tr.keys
local tr = setmetatable({ "$%MOD_ID%" }, tr_mt)

---@generic T: tr.key_prefix
---@param prefix T
---@return T
function tr.as_prefix(prefix)
    return setmetatable({ concat(prefix, ".") }, tr_mt)
end

return tr
