---@class tr_utils
local tr_utils = {}

local key_prefix = "$%MOD_ID%."

---@param key string
---@return string
---@nodiscard
function tr_utils.key(key)
    if key:sub(1, 1) == "$" then return key end
    return key_prefix .. key
end

---@param key_or_text string
---@return string
---@nodiscard
function tr_utils.maybe(key_or_text)
    return GameTextGetTranslatedOrNot(key_or_text)
end

---@param key string
---@return string
---@nodiscard
function tr_utils.get(key)
    return GameTextGet(tr_utils.key(key))
end

return tr_utils
