---@generic T
---@param fields table<string,{["get"]: fun(self: T): any; ["set"]: fun(self: T, value: any)?}>
---@return (fun(self: T): any)[], (fun(self: T, value: any))[]
local function transpose_fields(fields)
    local getters, setters = {}, {}
    for name, access in pairs(fields) do
        getters[name] = access.get
        setters[name] = access.set
    end
    return getters, setters
end

---@generic T
---@param fields table<string,{["get"]: fun(self: T): any; ["set"]: fun(self: T, value: any)?}>
---@param methods table<string,fun(self: T, ...): ...>?
---@param extra {["__index"]: (fun(t: T, k: string): any)?; ["__newindex"]: (fun(t: T, k: string, v: any))?}?
return function(fields, methods, extra)
    local getters, setters = transpose_fields(fields)

    local extra_index, extra_newindex = nil, nil
    if extra then
        extra_index, extra_newindex = extra.__index, extra.__newindex
    end

    local __index
    if methods then
        if extra_index then
            __index = function(t, k)
                local getter = getters[k]
                if getter then
                    return getter(t)
                end
                local method = methods[k]
                if method then
                    return method
                end
                return extra_index(t, k)
            end
        else
            __index = function(t, k)
                local getter = getters[k]
                if getter then
                    return getter(t)
                end
                local method = methods[k]
                if method then
                    return method
                end
            end
        end
    else
        if extra_index then
            __index = function(t, k)
                local getter = getters[k]
                if getter then
                    return getter(t)
                end
                return extra_index(t, k)
            end
        else
            __index = function(t, k)
                local getter = getters[k]
                if getter then
                    return getter(t)
                end
            end
        end
    end

    local __newindex
    if extra_newindex then
        __newindex = function(t, k, v)
            local setter = setters[k]
            if setter then
                return setter(t, v)
            end
            return extra_newindex(t, k, v)
        end
    else
        __newindex = function(t, k, v)
            local setter = setters[k]
            if setter then
                return setter(t, v)
            end
        end
    end

    return {
        __index = __index,
        __newindex = __newindex,
    }
end
