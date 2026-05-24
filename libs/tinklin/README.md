## 听灵 Tinklin
简体中文 | [English](README-EN.md)

新一代 Noita 实体组件封装。提供完整的 LSP 支持，注重人体工学设计，通过尽可能从游戏文件中收集数据来保证数据完备。

内置了 [LuaFun](https://github.com/luafun/luafun) 和简单的向量运算封装等。
## 安装
[下载最新发行版](https://github.com/shoozzzh/tinklin/releases/latest)并解压到`mods/你的模组文件夹/libs/tinklin`或你模组文件夹下的任意位置。
## 使用
### 引入
```lua
local tinklin = dofile_once("path/to/tinklin/main.lua")
```
### 封装
```lua
local entity = tinklin.entity_wrap(GetUpdatedEntityID())
local comp = tinklin.comp_wrap(GetUpdatedComponentID()) --[[@as LuaComponent]]
```
这个例子里也可以使用方便函数：
```lua
local entity = tinklin.entity_cur()
local comp = tinklin.comp_cur() --[[@as LuaComponent]]
```
### 组件读写
```lua
local proj_comp = entity.comp_first "ProjectileComponent"
if not proj_comp then return end

-- 读写字段
proj_comp.lifetime = proj_comp.lifetime + 60
proj_comp.damage = proj_comp.damage - 0.4

-- 设置多个字段
proj_comp.set{
    lifetime = 100,
    damage = 4,
}

local vel_comp = entity.comp_first "VelocityComponent"
if vel_comp then
    -- 读写向量
    if vel_comp.mVelocity:norm() > 400 then
        vel_comp.mVelocity = { 0, 0 }
    end
    -- 拆开向量（不推荐）
    local vel_x, vel_y = unpack(vel_comp.mVelocity)
end

-- 获取对象
local cfg_exp = proj_comp:object "config_explosion"

-- 读写对象字段
cfg_exp.explosion_radius = cfg_exp.explosion_radius + 20
```
### 从实体获取组件
```lua
-- 获取第一个指定类型组件
local first_lua_comp = entity:comp_first "LuaComponent"

-- 获取第一个启用的指定类型组件
local first_enabled_lua_comp = entity:comp_first_enabled "LuaComponent"

-- 可选的tag参数
local first_lua_comp_with_tag = entity:comp_first("LuaComponent", "enabled_in_world")

-- 返回所有符合条件组件的迭代器
entity:comps "LuaComponent".each( function(comp) comp:remove() end )

-- 组件类型为nil时返回所有类型的组件
entity:comps_enabled(nil, "enabled_in_hand").each( function(comp) comp.enabled = false end )
```
### 组件操作
```lua
-- 新建组件
local comp = entity:comp_new "LifetimeComponent" { lifetime = 1 }

-- 启用/禁用组件
comp.enabled = false

-- 移除组件
comp:remove()
```
### Tag 相关
```lua
-- 读写组件tag
comp.tag.enabled_in_world = true
comp.tag.enabled_in_inventory = true

if comp.tag.enabled_in_hand then
    -- ...
end

-- 读写实体tag
entity.tag.invincible = true

if entity.tag.invincible then
    -- ...
end

-- 获得所有tag连成的字符串，形如 "enabled_in_world,enabled_in_inventory"
local comp_tags = comp.tags
local entity_tags = entity.tags
```