local path = jit.util.funcinfo(setfenv(1, getfenv())).source:match "^.*/"
local function require(module_name)
    return dofile_once(path .. module_name .. ".lua")
end

local npair = require "npair"

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

function nquadra.new(value_1, value_2, value_3, value_4)
    return new(value_1, value_2, value_3, value_4)
end

---@return aabb
function nquadra.aabb_from_ranges(range_x, range_y)
    ---@diagnostic disable-next-line: return-type-mismatch
    return new(range_x[1], range_x[2], range_y[1], range_y[2])
end

---@return aabb
function nquadra.aabb_from_vectors(vector_min, vector_max)
    ---@diagnostic disable-next-line: return-type-mismatch
    return new(vector_min[1], vector_max[1], vector_min[2], vector_max[2])
end

---@return color
function nquadra.color_from_hex(vector_min, vector_max)
    ---@diagnostic disable-next-line: return-type-mismatch
    return new(vector_min[1], vector_max[1], vector_min[2], vector_max[2])
end

---@class aabb: nquadra
---@field [1] number min_x
---@field [2] number max_x
---@field [3] number min_y
---@field [4] number max_y
local aabb_mt = {}
aabb_mt.__index = aabb_mt

---@return range
---@return range
function aabb_mt:split_range()
    ---@diagnostic disable-next-line: return-type-mismatch
    return npair.new(self[1], self[2]), npair.new(self[3], self[4])
end

---@return vector
---@return vector
function aabb_mt:split_vector()
    ---@diagnostic disable-next-line: return-type-mismatch
    return npair.new(self[1], self[3]), npair.new(self[2], self[4])
end

---@class color: nquadra
---@field [1] number r
---@field [2] number g
---@field [3] number b
---@field [4] number a
local color_mt = {}
color_mt.__index = color_mt

for k, v in pairs(aabb_mt) do
    nquadra_mt[k] = v
end
for k, v in pairs(color_mt) do
    nquadra_mt[k] = v
end

return nquadra
