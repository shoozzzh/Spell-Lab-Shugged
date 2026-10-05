local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
    return dofile_once(path .. module_name:sub(9) .. ".lua")
end

local npair = require "tinklin.npair"

local nquadra = {}

---@class nquadra
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number
local nquadra_mt = {}
nquadra_mt.__index = nquadra_mt

local function new(value_1, value_2, value_3, value_4)
    return setmetatable({ value_1, value_2, value_3, value_4 }, nquadra_mt)
end

---@param value_1 number
---@param value_2 number
---@param value_3 number
---@param value_4 number
---@nodiscard
function nquadra.new(value_1, value_2, value_3, value_4)
    return new(value_1, value_2, value_3, value_4)
end

---@param interval_x any
---@param interval_y any
---@return aabb
---@nodiscard
function nquadra.aabb_from_intervals(interval_x, interval_y)
    return new(interval_x[1], interval_x[2], interval_y[1], interval_y[2]) --[[@as aabb]]
end

---@param vector_min vector
---@param vector_max vector
---@return aabb
---@nodiscard
function nquadra.aabb_from_vecs(vector_min, vector_max)
    return new(vector_min[1], vector_max[1], vector_min[2], vector_max[2]) --[[@as aabb]]
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return rgba_percent
---@nodiscard
function nquadra.color(r, g, b, a)
    return new(r, g, b, a) --[[@as rgba_percent]]
end

---@param hexcode string
---@return rgba_percent
---@nodiscard
function nquadra.color_from_hex(hexcode)
    hexcode = hexcode:gsub("#", "")
    local r = tonumber("0x" .. hexcode:sub(1, 2))
    local g = tonumber("0x" .. hexcode:sub(3, 4))
    local b = tonumber("0x" .. hexcode:sub(5, 6))
    local a = tonumber("0x" .. hexcode:sub(7, 8))
    return new(r, g, b, a) --[[@as rgba_percent]]
end

---@param abgr integer
---@return rgba_percent
---@nodiscard
function nquadra.color_from_0xABGR(abgr)
    local a = bit.rshift(abgr, 24) / 255
    local b = bit.band(bit.rshift(abgr, 16), 255) / 255
    local g = bit.band(bit.rshift(abgr, 8), 255) / 255
    local r = bit.band(abgr, 255) / 255
    return new(r, g, b, a) --[[@as rgba_percent]]
end

---@class aabb: nquadra
---@field [1] number min_x
---@field [2] number max_x
---@field [3] number min_y
---@field [4] number max_y
local aabb_mt = {}
aabb_mt.__index = aabb_mt

---@return interval
---@return interval
---@nodiscard
function aabb_mt:split_range()
    ---@diagnostic disable-next-line: return-type-mismatch
    return npair.new(self[1], self[2]), npair.new(self[3], self[4])
end

---@return vector
---@return vector
---@nodiscard
function aabb_mt:split_vector()
    ---@diagnostic disable-next-line: return-type-mismatch
    return npair.new(self[1], self[3]), npair.new(self[2], self[4])
end

---@class rgba_percent: nquadra
---@field [1] number r
---@field [2] number g
---@field [3] number b
---@field [4] number a
local color_mt = {}
color_mt.__index = color_mt

local function percent2hex(frac)
    return math.floor(frac * 255 + 0.5)
end

---@return integer
---@nodiscard
function color_mt:to_0xABGR()
    local r, g, b, a = unpack(self)
    return bit.bor(
        bit.lshift(percent2hex(a), 24),
        bit.lshift(percent2hex(b), 16),
        bit.lshift(percent2hex(g), 8),
        percent2hex(r)
    )
end

for k, v in pairs(aabb_mt) do
    nquadra_mt[k] = v
end
for k, v in pairs(color_mt) do
    nquadra_mt[k] = v
end

return nquadra
