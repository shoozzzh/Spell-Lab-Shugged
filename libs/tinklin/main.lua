local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
    return dofile_once(path .. module_name:sub(9) .. ".lua")
end

local fun = require "tinklin.fun"
local npair = require "tinklin.npair"
local nquadra = require "tinklin.nquadra"
local class_sim = require "tinklin.class_sim"

local tinklin = {}

tinklin.fun = fun
tinklin.npair = npair
tinklin.nquadra = nquadra

tinklin.vec = npair.vec
tinklin.vec_from_polar = npair.vec_from_polar
tinklin.interval = npair.interval
tinklin.interval_from_span = npair.interval_from_span
tinklin.aabb_from_intervals = tinklin.nquadra.aabb_from_intervals
tinklin.aabb_from_vecs = nquadra.aabb_from_vecs
tinklin.color = nquadra.color
tinklin.color_from_hex = nquadra.color_from_hex
tinklin.color_from_0xABGR = nquadra.color_from_0xABGR

local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget

---@class tinklin.entity.layout
---@field id entity_id

---@class entity: tinklin.entity.methods
---@field id entity_id
---@field name string
---@field pos vector
---@field rot vector
---@field scale vector
---@field tag table<string,boolean>

---@type table<string,{["get"]: fun(self: tinklin.entity.layout): any; ["set"]: fun(self: tinklin.entity.layout, value: any)?}>
local entity_fields = {
    name = {
        get = function(self)
            return EntityGetName(self.id)
        end,
        set = function(self, value)
            EntitySetName(self.id, value)
        end,
    },
    pos = {
        get = function(self)
            local x, y, _, _, _ = EntityGetTransform(self.id)
            return npair.new(x, y)
        end,
        set = function(self, value)
            local _, _, rot, scale_x, scale_y = EntityGetTransform(self.id)
            EntitySetTransform(self.id, value[1], value[2], rot, scale_x, scale_y)
        end,
    },
    rot = {
        get = function(self)
            local _, _, rot, _, _ = EntityGetTransform(self.id)
            return rot
        end,
        set = function(self, value)
            local x, y, _, scale_x, scale_y = EntityGetTransform(self.id)
            EntitySetTransform(self.id, x, y, value, scale_x, scale_y)
        end,
    },
    scale = {
        get = function(self)
            local _, _, _, scale_x, scale_y = EntityGetTransform(self.id)
            return npair.new(scale_x, scale_y)
        end,
        set = function(self, value)
            local x, y, rot, _, _ = EntityGetTransform(self.id)
            EntitySetTransform(self.id, nil, nil, nil, value.x, value.y)
        end,
    },
    tag = (function()
        local entity_tag_mt = {
            __index = function(t, k)
                return EntityHasTag(rawget(t, 1), k)
            end,
            __newindex = function(t, k, v)
                if v then
                    EntityAddTag(rawget(t, 1), k)
                else
                    EntityRemoveTag(rawget(t, 1), k)
                end
            end,
        }
        return {
            get = function(self)
                local result = setmetatable({ self.id }, entity_tag_mt)
                rawset(self, "tag", result)
                return result
            end,
        }
    end)(),
}

---@class tinklin.entity.methods: tinklin.entity.layout
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

function entity_methods:apply_xform()
    EntityApplyTransform(self.id, EntityGetTransform(self.id))
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
    local children_ids
    if tag == nil then
        children_ids = EntityGetAllChildren(self.id)
    else
        children_ids = EntityGetAllChildren(self.id, tag)
    end
    return fun.elems(children_ids):map(tinklin.entity_wrap)
end

---Returns the given entity if it has no parent, otherwise walks up the parent hierarchy to the topmost parent and returns it.
---@return entity root_entity
---@nodiscard
function entity_methods:get_root()
    return tinklin.entity_wrap(EntityGetRootEntity(self.id))
end

---@param comp_type component_type
---@param tag string?
---@return comp?
---@nodiscard
function entity_methods:comp_first(comp_type, tag)
    local comp_id
    if tag == nil then
        comp_id = EntityGetFirstComponentIncludingDisabled(self.id, comp_type)
    else
        comp_id = EntityGetFirstComponentIncludingDisabled(self.id, comp_type, tag)
    end
    return tinklin.comp_wrap(comp_id)
end

---@param comp_type component_type
---@param tag string?
---@return comp?
---@nodiscard
function entity_methods:comp_first_enabled(comp_type, tag)
    local comp_id
    if tag == nil then
        comp_id = EntityGetFirstComponent(self.id, comp_type)
    else
        comp_id = EntityGetFirstComponent(self.id, comp_type, tag)
    end
    return tinklin.comp_wrap(comp_id)
end

---@param comp_type component_type?
---@param tag string?
---@nodiscard
function entity_methods:comps(comp_type, tag)
    if comp_type == nil then
        return fun.elems(EntityGetAllComponents(self.id))
    end
    local comps
    if tag == nil then
        comps = EntityGetComponent(self.id, comp_type)
    else
        comps = EntityGetComponent(self.id, comp_type, tag)
    end
    return fun.elems(comps or {}):map(tinklin.comp_wrap)
end

---@nodiscard
function entity_methods:comps_enabled(comp_type, tag)
    if comp_type == nil then
        return fun.elems(EntityGetAllComponents(self.id)):filter(function(c) return ComponentGetIsEnabled(c) end)
    end
    local comps
    if tag == nil then
        comps = EntityGetComponentIncludingDisabled(self.id, comp_type)
    else
        comps = EntityGetComponentIncludingDisabled(self.id, comp_type, tag)
    end
    return fun.elems(comps or {}):map(tinklin.comp_wrap)
end

function entity_methods:comp_new(comp_type)
    return function(fields)
        return tinklin.comp_wrap(EntityAddComponent2(self.id, comp_type, fields))
    end
end

---Return value example: 'data/entities/items/flute.xml'. Incorrect value is returned if the entity has passed through the world streaming system.
---@return string full_path
---@nodiscard
function entity_methods:get_filename()
    return EntityGetFilename(self.id)
end

local entity_mt = class_sim(entity_fields, entity_methods)

---@class tinklin.comp.layout
---@field _id comp_id

---@class comp
---@field meta comp.meta

---@class comp.meta
---@field id comp_id
---@field type string
---@field enabled boolean
---@field tag table<string,boolean> alias for comp.meta.tag
---@field tags string a string where the tags are comma-separated
---@field remove fun(self)

---@type table<string,{["get"]: fun(self: tinklin.comp.layout): any; ["set"]: fun(self: tinklin.comp.layout, value: any)?}>
local comp_fields = {}

do
    ---@type table<string,{["get"]: fun(self: comp.meta): any; ["set"]: fun(self: comp.meta, value: any)?}>
    local comp_meta_fields = {
        enabled = {
            get = function(self)
                return ComponentGetIsEnabled(self.id)
            end,
            set = function(self, value)
                return EntitySetComponentIsEnabled(ComponentGetEntity(self.id), self.id, value)
            end,
        },
        tags = {
            get = function(self)
                return ComponentGetTags(self.id)
            end,
        },
        type = {
            get = function(self)
                return ComponentGetTypeName(self.id)
            end,
        },
    }
    do
        local comp_tag_mt = {
            __index = function(t, k)
                return EntityHasTag(rawget(t, 1), k)
            end,
            __newindex = function(t, k, v)
                if v then
                    EntityAddTag(rawget(t, 1), k)
                else
                    EntityRemoveTag(rawget(t, 1), k)
                end
            end,
        }

        comp_meta_fields.tag = {
            get = function(self)
                local result = setmetatable({ self.id }, comp_tag_mt)
                rawset(self, "tag", result)
                return result
            end,
        }
    end

    local comp_meta_methods = {
        remove = function(self)
            EntityRemoveComponent(ComponentGetEntity(self.id), self.id)
        end,
    }

    local comp_meta_mt = class_sim(comp_meta_fields, comp_meta_methods)

    comp_fields.meta = {
        get = function(self)
            local result = setmetatable({ id = self._id }, comp_meta_mt)
            rawset(self, "meta", result)
            return result
        end,
    }
end

do
    ---@class comp.xform
    ---@field pos vector
    ---@field rot number
    ---@field scale vector
    ---@field comp_id comp_id

    ---@type table<string,{["get"]: fun(self: comp.xform): any; ["set"]: fun(self: comp.xform, value: any)?}>
    local comp_xform_fields = {
        pos = {
            get = function(self)
                local x, y, _, _, _ = ComponentGetValue2(self.comp_id, "Transform")
                return npair.new(x, y)
            end,
            set = function(self, value)
                local _, _, scale_x, scale_y, rot = ComponentGetValue2(self.comp_id, "Transform")
                ComponentSetValue2(self.comp_id, "Transform", value[1], value[2], scale_x, scale_y, rot)
            end,
        },
        rot = {
            get = function(self)
                local _, _, _, _, rot = ComponentGetValue2(self.comp_id, "Transform")
                return rot
            end,
            set = function(self, value)
                local x, y, scale_x, scale_y, _ = ComponentGetValue2(self.comp_id, "Transform")
                ComponentSetValue2(self.comp_id, "Transform", x, y, scale_x, scale_y, value)
            end,
        },
        scale = {
            get = function(self)
                local _, _, scale_x, scale_y, _ = ComponentGetValue2(self.comp_id, "Transform")
                return npair.new(scale_x, scale_y)
            end,
            set = function(self, value)
                local x, y, _, _, rot = ComponentGetValue2(self.comp_id, "Transform")
                ComponentSetValue2(self.comp_id, "Transform", nil, nil, value.x, value.y, nil)
            end,
        },
    }

    local comp_xform_mt = class_sim(comp_xform_fields)

    comp_fields.Transform = {
        get = function(self)
            return setmetatable({ comp_id = self._id }, comp_xform_mt)
        end,
    }
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

local comp_methods = {}
do
    local object_mt = {
        __index = function(t, k)
            return wrap_field(ComponentObjectGetValue2(t.comp_id, t.name, k))
        end,
        __newindex = function(t, k, v)
            if type(v) == "table" then
                ComponentObjectSetValue2(t.comp_id, t.name, k, unpack(v))
            else
                ComponentObjectSetValue2(t.comp_id, t.name, k, v)
            end
        end,
        __call = function(t, fields)
            for k, v in pairs(fields) do
                if type(v) == "table" then
                    ComponentObjectSetValue2(t.comp_id, t.name, k, unpack(v))
                else
                    ComponentObjectSetValue2(t.comp_id, t.name, k, v)
                end
            end
        end,
    }

    function comp_methods:object(name)
        return setmetatable({ comp_id = self.id, name = name }, object_mt)
    end
end

local comp_mt = class_sim(comp_fields, comp_methods, {
    __index = function(t, k)
        return wrap_field(ComponentGetValue2(t._id, k))
    end,
    __newindex = function(t, k, v)
        if type(v) == "table" then
            ComponentSetValue2(t._id, k, unpack(v))
        else
            ComponentSetValue2(t._id, k, v)
        end
    end,
})

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
---@param x number? 0
---@param y number? 0
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

---@param name string? ""
---@return entity entity
---@nodiscard
function tinklin.entity_new(name)
    return tinklin.entity_wrap(EntityCreateNew(name))
end

---@param center {[1]: number, [2]: number}
---@param radius number
---@param tag string?
---@return iterator<entity> entities
---@nodiscard
function tinklin.entity_in_radius(center, radius, tag)
    local x, y = unpack(center)
    local entity_ids
    if tag then
        entity_ids = EntityGetInRadiusWithTag(x, y, radius, tag)
    else
        entity_ids = EntityGetInRadius(x, y, radius)
    end
    return fun.elems(entity_ids):map(tinklin.entity_wrap)
end

---@param tag string
---@return iterator<entity> entities
---@nodiscard
function tinklin.entity_tagged(tag)
    return fun.elems(EntityGetWithTag(tag)):map(tinklin.entity_wrap)
end

---@param to {[1]: number, [2]: number}
---@param tag string?
---@return entity? entity
---@nodiscard
function tinklin.entity_closest(to, tag)
    local x, y = unpack(to)
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
---@return comp
---@nodiscard
function tinklin.comp_wrap(id)
    ---@type comp
    return setmetatable({ _id = id }, comp_mt)
end

---@return comp
---@nodiscard
function tinklin.comp_cur()
    return tinklin.comp_wrap(GetUpdatedComponentID())
end

return tinklin
