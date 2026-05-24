## Tinklin
[简体中文](README.md) | English

The new generation of Noita entity and component wrappers. It offers full LSP support，features an ergonomic design，and ensures data integrity by extracting as much information as possible from game files.

It also includes [LuaFun](https://github.com/luafun/luafun), simple vector operations and some more.
## Install
[Download the newest release](https://github.com/shoozzzh/tinklin/releases/latest) and unzip it to `mods/YOUR_MOD/libs/tinklin` or anywhere in your mod folder.
## Usage
### Introduce
```lua
local tinklin = dofile_once("path/to/tinklin/main.lua")
```
### Wrap
```lua
local entity = tinklin.entity_wrap(GetUpdatedEntityID())
local comp = tinklin.comp_wrap(GetUpdatedComponentID()) --[[@as LuaComponent]]
```
In the above case you can also use convenient functions：
```lua
local entity = tinklin.entity_cur()
local comp = tinklin.comp_cur() --[[@as LuaComponent]]
```
### Get/Set component fields
```lua
local proj_comp = entity.comp_first "ProjectileComponent"
if not proj_comp then return end

-- get/set component fields
proj_comp.lifetime = proj_comp.lifetime + 60
proj_comp.damage = proj_comp.damage - 0.4

-- set multiple fields
proj_comp.set{
    lifetime = 100,
    damage = 4,
}

local vel_comp = entity.comp_first "VelocityComponent"
if vel_comp then
    -- get/set vector
    if vel_comp.mVelocity:norm() > 400 then
        vel_comp.mVelocity = { 0, 0 }
    end
    -- unpack a vector(not recommended)
    local vel_x, vel_y = unpack(vel_comp.mVelocity)
end

-- get an component object
local cfg_exp = proj_comp:object "config_explosion"

-- get/set component object fields
cfg_exp.explosion_radius = cfg_exp.explosion_radius + 20
```
### Get component(s) from an entity
```lua
-- get the first component with a certain type
local first_lua_comp = entity:comp_first "LuaComponent"

-- get the first enabled component with a certain type
local first_enabled_lua_comp = entity:comp_first_enabled "LuaComponent"

-- optional tag param
local first_lua_comp_with_tag = entity:comp_first("LuaComponent", "enabled_in_world")

-- an iterator of all components that meet the requirement(s)
entity:comps "LuaComponent".each( function(comp) comp:remove() end )

-- if the given component type is nil, return components of any type
entity:comps_enabled(nil, "enabled_in_hand").each( function(comp) comp.enabled = false end )
```
### Component operations
```lua
-- create a new component
local comp = entity:comp_new "LifetimeComponent" { lifetime = 1 }

-- enable/disable component
comp.enabled = false

-- remove a component
comp:remove()
```
### Tags
```lua
-- toggle a tag from component
comp.tag.enabled_in_world = true
comp.tag.enabled_in_inventory = true

-- check a tag from component
if comp.tag.enabled_in_hand then
    -- ...
end

-- same for entity tags
entity.tag.invincible = true

if entity.tag.invincible then
    -- ...
end

-- get a string formed by concatnating all tags on an entity or component, like "enabled_in_world,enabled_in_inventory"
local comp_tags = comp.tags
local entity_tags = entity.tags
```