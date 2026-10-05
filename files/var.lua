local var = {}

---@alias vsc_field
---| "value_bool"
---| "value_int"
---| "value_float"
---| "value_string"
---| "name"

local function find_var_comp(entity_id, var_name)
    local var_comps = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    if not var_comps or #var_comps == 0 then
        return
    end
    for _, var_comp in ipairs(var_comps) do
        if ComponentGetValue2(var_comp, "name") == var_name then
            return var_comp
        end
    end
end

---@param entity_id entity_id
---@param var_name vsc_field
---@return component_id
---@return boolean found
function var.comp(entity_id, var_name)
    local result = find_var_comp(entity_id, var_name)
    if result then
        return result, true
    end
    return EntityAddComponent2(entity_id, "VariableStorageComponent", { name = var_name }), false
end

---@param entity_id entity_id
---@param var_name string
---@param var_type vsc_field
---@param value_default any
---@overload fun(entity_id: entity_id, var_name: string, var_type: "name", value_default: string): string
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_string", value_default: string): string
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_int", value_default: integer): integer
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_float", value_default: number): number
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_bool", value_default: boolean): boolean
function var.get(entity_id, var_name, var_type, value_default)
    local comp, found = var.comp(entity_id, var_name)
    if found then
        return ComponentGetValue2(comp, var_type)
    end
    return value_default
end

---@param entity_id entity_id
---@param var_name string
---@param var_type vsc_field
---@param value any
---@overload fun(entity_id: entity_id, var_name: string, var_type: "name", value: string)
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_string", value: string)
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_int", value: integer)
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_float", value: number)
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_bool", value: boolean)
function var.write(entity_id, var_name, var_type, value)
    ComponentSetValue2(var.comp(entity_id, var_name), var_type, value)
end

---@param entity_id entity_id
---@param var_name string
---@param var_type vsc_field
---@param new_value any
---@overload fun(entity_id: entity_id, var_name: string, var_type: "name", new_value: string): string
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_string", new_value: string): string
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_int", new_value: integer): integer
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_float", new_value: number): number
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_bool", new_value: boolean): boolean
function var.replace(entity_id, var_name, var_type, new_value)
    local var_comp = var.comp(entity_id, var_name)
    local old_value = ComponentGetValue2(var_comp, var_type)
    ComponentSetValue2(var_comp, var_type, new_value)
    return old_value
end

---@generic T
---@param entity_id entity_id
---@param var_name string
---@param var_type vsc_field
---@param update_fn fun(old_value: T): T
---@param init_value T
---@return T old_value
---@overload fun(entity_id: entity_id, var_name: string, var_type: "name", update_fn: fun(old_value: string): string, init_value: string): old_value: string
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_string", update_fn: fun(old_value: string): string, init_value: string): old_value: string
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_int", update_fn: fun(old_value: integer): integer, init_value: integer): old_value: integer
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_float", update_fn: fun(old_value: number): number, init_value: number): old_value: number
---@overload fun(entity_id: entity_id, var_name: string, var_type: "value_bool", update_fn: fun(old_value: boolean): boolean, init_value: boolean): old_value: boolean
function var.update(entity_id, var_name, var_type, update_fn, init_value)
    local var_comp, exists = var.comp(entity_id, var_name)
    local old_value = exists and ComponentGetValue2(var_comp, var_type) or init_value
    ComponentSetValue2(var_comp, var_type, update_fn(old_value))
    return old_value
end

local vars_access_mt = {
    __index = function(t, k)
        local comp, type = unpack(rawget(t, 1)[k])
        return ComponentGetValue2(comp, type)
    end,
    __newindex = function(t, k, v)
        local comp, type = unpack(rawget(t, 1)[k])
        ComponentSetValue2(comp, type, v)
    end,
}

---@param entity_id entity_id
---@param var_map table<string, vsc_field>
---@param var_name_prefix string
---@return table<string, any>
function var.access(entity_id, var_map, var_name_prefix)
    local var_comps = {}
    for var_name, var_type in pairs(var_map) do
        var_comps[var_name] = { var.comp(entity_id, var_name_prefix .. var_name), var_type }
    end
    return setmetatable({ var_comps }, vars_access_mt)
end

return var
