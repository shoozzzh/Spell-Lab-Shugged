-- vesion 1.0.0

local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
    return dofile_once(path .. module_name .. ".lua")
end

local fun = require "fun"
local npair = require "npair"
local nquadra = require "nquadra"

local tinklin = {}

---@class entity: entity_methods
---@field id entity_id
---@field name string
---@field pos vector
---@field rot vector
---@field scale vector
---@field tag table<string,boolean>

local entity_fields = {}

entity_fields.name = {}
function entity_fields.name:get()
    return EntityGetName(self.id)
end

function entity_fields.name:set(value)
    EntitySetName(self.id, value)
end

entity_fields.pos = {}
function entity_fields.pos:get()
    local x, y, _, _, _ = EntityGetTransform(self.id)
    return npair.new { x, y }
end

function entity_fields.pos:set(value)
    local _, _, rot, scale_x, scale_y = EntityGetTransform(self.id)
    EntitySetTransform(self.id, value[1], value[2], rot, scale_x, scale_y)
end

entity_fields.rot = {}
function entity_fields.rot:get()
    local _, _, rot, _, _ = EntityGetTransform(self.id)
    return rot
end

function entity_fields.rot:set(value)
    local x, y, _, scale_x, scale_y = EntityGetTransform(self.id)
    EntitySetTransform(self.id, x, y, value, scale_x, scale_y)
end

entity_fields.scale = {}
function entity_fields.scale:get()
    local _, _, _, scale_x, scale_y = EntityGetTransform(self.id)
    return npair.new { scale_x, scale_y }
end

function entity_fields.scale:set(value)
    local x, y, rot, _, _ = EntityGetTransform(self.id)
    EntitySetTransform(self.id, nil, nil, nil, value.x, value.y)
end

local entity_tag_mt = {}
entity_tag_mt.__index = function(t, k)
    return EntityHasTag(rawget(t, 1), k)
end
entity_tag_mt.__newindex = function(t, k, v)
    if v then
        EntityAddTag(rawget(t, 1), k)
    else
        EntityRemoveTag(rawget(t, 1), k)
    end
end

function entity_fields.tag:get()
    self.tag = setmetatable({ self.id }, entity_tag_mt)
    return self.tag
end

---@class entity_methods
---@field id entity_id
local entity_methods = {}

---Loads components from `filename` to `entity`. Does not load tags and other stuff.
---@param filename string
function entity_methods:load_extra_entity(filename)
    EntityLoadToEntity(filename, self.id)
end

function entity_methods:kill()
    EntityKill(self.id)
end

function entity_methods:is_alive()
    return EntityGetIsAlive(self.id)
end

---@param child_entity entity
function entity_methods:add_child(child_entity)
    EntityAddChild(self.id, child_entity.id)
end

---@param parent_entity entity?
function entity_methods:set_parent(parent_entity)
    if not parent_entity then
        EntityRemoveFromParent(self.id)
        return
    end
    EntityAddChild(parent_entity.id, self.id)
end

---@return entity? parent_entity
---@nodiscard
function entity_methods:get_parent()
    return tinklin.entity_wrap(EntityGetParent(self.id))
end

---@param tag string?
---@return iterator<entity> iter_child_entity
---@nodiscard
function entity_methods:get_children(tag)
    return fun.iter(EntityGetAllChildren(self.id, tag)):map(tinklin.entity_wrap)
end

---Returns the given entity if it has no parent, otherwise walks up the parent hierarchy to the topmost parent and returns it.
---@return entity root_entity
---@nodiscard
function entity_methods:get_root()
    return tinklin.entity_wrap(EntityGetRootEntity(self.id))
end

---@param comp_type component_type
---@param tag string
---@return component?
---@nodiscard
function entity_methods:comp_first(comp_type, tag)
    return tinklin.comp_wrap(EntityGetFirstComponentIncludingDisabled(self.id, comp_type, tag))
end

---@param comp_type component_type
---@param tag string
---@return component?
---@nodiscard
function entity_methods:comp_first_enabled(comp_type, tag)
    return tinklin.comp_wrap(EntityGetFirstComponent(self.id, comp_type, tag))
end

---@nodiscard
function entity_methods:comps(comp_type, tag)
    if comp_type == nil then
        return fun.iter(EntityGetAllComponents(self.id))
    end
    return fun.iter(EntityGetComponent(self.id, comp_type, tag) or {}):map(tinklin.comp_wrap)
end

---@nodiscard
function entity_methods:comps_enabled(comp_type, tag)
    if comp_type == nil then
        return fun.iter(EntityGetAllComponents(self.id)):filter(function(c) return ComponentGetIsEnabled(c) end)
    end
    return fun.iter(EntityGetComponentIncludingDisabled(self.id, comp_type, tag) or {}):map(tinklin.comp_wrap)
end

function entity_methods:comp_new(comp_type)
    return function(fields)
        tinklin.comp_wrap(EntityAddComponent2(self.id, comp_type, fields))
    end
end

---Return value example: 'data/entities/items/flute.xml'. Incorrect value is returned if the entity has passed through the world streaming system.
---@return string full_path
---@nodiscard
function entity_methods:get_filename()
    return EntityGetFilename(self.id)
end

local entity_mt = {
    __index = function(t, k)
        local field = entity_fields[k]
        if field then
            local getter = field.get
            if getter then
                return getter(t)
            end
        end
        return entity_methods(k)
    end,
    __newindex = function(t, k, v)
        local field = entity_fields[k]
        if field then
            local setter = field.set
            if setter then
                return setter(t, v)
            end
        end
    end,
}

---@class component
---@field id comp_id
---@field type string
---@field enabled boolean
---@field tag table<string,boolean>
---@field tags string a string where the tags are comma-separated
---@field remove fun(self)

local comp_methods = {}

function comp_methods:remove()
    EntityRemoveComponent(ComponentGetEntity(self.id), self.id)
end

local comp_fields = {}

function comp_fields.enabled:get()
    return ComponentGetIsEnabled(self.id)
end

function comp_fields.enabled:set(value)
    return EntitySetComponentIsEnabled(ComponentGetEntity(self.id), self.id, value)
end

local comp_xform_fields = {}

function comp_xform_fields.pos:get()
    local x, y, _, _, _ = ComponentGetValue2(self.comp_id, "Transform")
    return npair.new { x, y }
end

function comp_xform_fields.pos:set(value)
    local _, _, scale_x, scale_y, rot = ComponentGetValue2(self.comp_id, "Transform")
    ComponentSetValue2(self.comp_id, "Transform", value[1], value[2], scale_x, scale_y, rot)
end

function comp_xform_fields.rot:get()
    local _, _, _, _, rot = ComponentGetValue2(self.comp_id, "Transform")
    return rot
end

function comp_xform_fields.rot:set(value)
    local x, y, scale_x, scale_y, _ = ComponentGetValue2(self.comp_id, "Transform")
    ComponentSetValue2(self.comp_id, "Transform", x, y, scale_x, scale_y, value)
end

function comp_xform_fields.scale:get()
    local _, _, scale_x, scale_y, _ = ComponentGetValue2(self.comp_id, "Transform")
    return npair.new { scale_x, scale_y }
end

function comp_xform_fields.scale:set(value)
    local x, y, _, _, rot = ComponentGetValue2(self.comp_id, "Transform")
    ComponentSetValue2(self.comp_id, "Transform", nil, nil, value.x, value.y, nil)
end

---@class comp_xform
---@field entity_id entity_id
local comp_xform_mt = {
    __index = function(t, k)
        local field = comp_xform_fields[k]
        if field then
            local getter = field.get
            if getter then
                return getter(t)
            end
        end
    end,
    __newindex = function(t, k, v)
        local field = comp_xform_fields[k]
        if field then
            local setter = field.set
            if setter then
                return setter(t, v)
            end
        end
    end,
}

function comp_fields.Transform:get()
    return setmetatable({ comp_id = self.id }, comp_xform_mt)
end

local comp_tag_mt = {}
comp_tag_mt.__index = function(t, k)
    return EntityHasTag(rawget(t, 1), k)
end
comp_tag_mt.__newindex = function(t, k, v)
    if v then
        EntityAddTag(rawget(t, 1), k)
    else
        EntityRemoveTag(rawget(t, 1), k)
    end
end

---@return table<string,boolean>
---@nodiscard
function comp_fields.tag:get()
    self.tag = setmetatable({ self.id }, comp_tag_mt)
    return self.tag
end

function comp_fields.tags:get()
    return ComponentGetTags(self.id)
end

function comp_fields.type:get()
    return ComponentGetTypeName(self.id)
end

local function wrap_field(...)
    local size = select("#", ...)
    if size == 1 then
        return ...
    elseif size == 2 then
        return npair.new(...)
    elseif size == 4 then
        return nquadra.new(...)
    end
end

local object_mt = {}
object_mt.__index = function(t, k)
    return wrap_field(ComponentObjectGetValue2(t.comp_id, t.name, k))
end
object_mt.__newindex = function(t, k, v)
    if type(v) == "table" then
        ComponentObjectSetValue2(t.comp_id, t.name, k, unpack(v))
    else
        ComponentObjectSetValue2(t.comp_id, t.name, k, v)
    end
end
object_mt.__call = function(t, fields)
    for k, v in pairs(fields) do
        if type(v) == "table" then
            ComponentObjectSetValue2(t.comp_id, t.name, k, unpack(v))
        else
            ComponentObjectSetValue2(t.comp_id, t.name, k, v)
        end
    end
end

function comp_methods:object(name)
    return setmetatable({ comp_id = self.id, name = name }, object_mt)
end

local comp_mt = {
    __index = function(t, k)
        local field = entity_fields[k]
        if field then
            local getter = field.get
            if getter then
                return getter(t)
            end
        end
        local method = comp_methods(k)
        if method then
            return method
        end
        return wrap_field(ComponentGetValue2(t.id, k))
    end,
    __newindex = function(t, k, v)
        local field = entity_fields[k]
        if field then
            local setter = field.set
            if setter then
                return setter(t, v)
            end
        end
        if type(v) == "table" then
            ComponentSetValue2(t.id, k, unpack(v))
        else
            ComponentSetValue2(t.id, k, v)
        end
    end,
}

---@param id entity_id
---@return entity entity
---@nodiscard
function tinklin.entity_wrap(id)
    ---@type entity
    return setmetatable({ id = id }, entity_mt)
end

---@return entity entity
---@nodiscard
function tinklin.entity_cur()
    return tinklin.entity_wrap(GetUpdatedEntityID())
end

---@param filename string
---@param x number? '0'
---@param y number? '0'
---@return entity entity
---@nodiscard
function tinklin.entity_load(filename, x, y)
    return tinklin.entity_wrap(EntityLoad(filename, x, y))
end

---@param filename string
---@param parent entity
---@return entity entity
function tinklin.entity_load_child(filename, parent)
    local entity_id = EntityLoad(filename, unpack(parent.pos))
    EntityAddChild(parent.id, entity_id)
    return tinklin.entity_wrap(entity_id)
end

---@param name string? '""'
---@return entity entity
---@nodiscard
function tinklin.entity_new(name)
    return tinklin.entity_wrap(EntityCreateNew(name))
end

---@param x number
---@param y number
---@param radius number
---@param tag string?
---@return iterator<entity> entities
---@nodiscard
function tinklin.entity_in_radius(x, y, radius, tag)
    local entity_ids
    if tag then
        entity_ids = EntityGetInRadiusWithTag(x, y, radius, tag)
    else
        entity_ids = EntityGetInRadius(x, y, radius)
    end
    return fun.iter(entity_ids):map(tinklin.entity_wrap)
end

---@param x number
---@param y number
---@param tag string?
---@return entity? entity
---@nodiscard
function tinklin.entity_closest(x, y, tag)
    local entity_id
    if tag then
        entity_id = EntityGetClosestWithTag(x, y, tag)
    else
        entity_id = EntityGetClosest(x, y)
    end
    if entity_id then
        return tinklin.entity_wrap(entity_id)
    end
end

---@param name string
---@return entity? entity
---@nodiscard
function tinklin.entity_with_name(name)
    local entity = EntityGetWithName(name)
    if entity ~= 0 then
        return tinklin.entity_wrap(entity)
    end
end

---@param id comp_id
---@return component
---@nodiscard
function tinklin.comp_wrap(id)
    ---@type component
    return setmetatable({ id = id }, comp_mt)
end

---@return component
---@nodiscard
function tinklin.comp_cur()
    return tinklin.comp_wrap(GetUpdatedComponentID())
end

return tinklin
