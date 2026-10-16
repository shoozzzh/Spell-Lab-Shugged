---@class tr_utils
local tr_utils = {}

local key_prefix = "$%MOD_ID%"

---@param key string
---@return string
---@nodiscard
function tr_utils.key(key)
    if key:sub(1, 1) == "$" then return key end
    return key_prefix .. key
end

---@param maybe_key string
---@return string
---@nodiscard
function tr_utils.maybe(maybe_key)
    local _maybe_key = tr_utils.key(maybe_key)
    local res = GameTextGetTranslatedOrNot(_maybe_key)
    return res == _maybe_key and maybe_key or res
end

---@param maybe_key string
---@return string?
---@nodiscard
function tr_utils.try(maybe_key)
    maybe_key = tr_utils.key(maybe_key)
    local res = GameTextGetTranslatedOrNot(maybe_key)
    if res == maybe_key then
        return nil
    end
    return res
end

---@param key string
---@return string
---@nodiscard
function tr_utils.get(key)
    return GameTextGet(tr_utils.key(key))
end

return tr_utils
