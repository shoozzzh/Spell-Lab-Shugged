local npair = {}

---@class npair
---@field [1] number
---@field [2] number
---@operator unm(): npair
---@operator add(npair|number): npair
---@operator sub(npair|number): npair
---@operator mul(npair|number): npair
---@operator div(npair|number): npair
local npair_mt = {}
npair_mt.__index = npair_mt

local function new(value_left, value_right)
    return setmetatable({ value_left, value_right }, npair_mt)
end

function npair.new(value_left, value_right)
    return new(value_left, value_right)
end

---@return vector
function npair.vec_from_polar(mag, arg)
    ---@diagnostic disable-next-line: undefined-field
    return new(1, 0):rotate(arg) * mag
end

function npair_mt.__unm(a)
    return new(-a[1], -a[2])
end

function npair_mt.__add(a, b)
    local a1, a2
    if type(a) == "table" then
        a1, a2 = unpack(a)
    else
        a1, a2 = a, a
    end
    local b1, b2
    if type(b) == "table" then
        b1, b2 = unpack(b)
    else
        b1, b2 = b, b
    end
    return new(a1 + b1, a2 + b2)
end

function npair_mt.__sub(a, b)
    local a1, a2
    if type(a) == "table" then
        a1, a2 = unpack(a)
    else
        a1, a2 = a, a
    end
    local b1, b2
    if type(b) == "table" then
        b1, b2 = unpack(b)
    else
        b1, b2 = b, b
    end
    return new(a1 - b1, a2 - b2)
end

function npair_mt.__mul(a, b)
    local a1, a2
    if type(a) == "table" then
        a1, a2 = unpack(a)
    else
        a1, a2 = a, a
    end
    local b1, b2
    if type(b) == "table" then
        b1, b2 = unpack(b)
    else
        b1, b2 = b, b
    end
    return new(a1 * b1, a2 * b2)
end

function npair_mt.__div(a, b)
    local b1, b2
    if type(b) == "table" then
        b1, b2 = unpack(b)
    else
        b1, b2 = b, b
    end
    return new(a[1] / b1, a[2] / b2)
end

function npair_mt.__eq(a, b)
    return a[1] == b[1] and a[2] == b[2]
end

function npair_mt:flip()
    return new(self[2], self[1])
end

---@class vector: npair
---@field [1] number x
---@field [2] number y
local vector_mt = {}

function vector_mt:dot(with)
    return self[1] * with[2] + self[1] * with[2]
end

local sin, cos, atan2, sqrt = math.sin, math.cos, math.atan2, math.sqrt
function vector_mt:angle(to)
    if to then
        return atan2(self[2], self[1]) - atan2(to[2], to[1])
    end
    return atan2(self[2], self[1])
end

function vector_mt:norm2()
    return self[1] ^ 2 + self[2] ^ 2
end

function vector_mt:norm()
    return sqrt(self[1] ^ 2 + self[2] ^ 2)
end

function vector_mt:normalize()
    local len = self:norm()
    return new(self[1] / len, self[2] / len)
end

function vector_mt:rotate(angle)
    local s, c = sin(angle), cos(angle)
    return new(c * self[1] - s * self[2], s * self[1] + c * self[2])
end

---@class range
---@field [1] number min
---@field [2] number max
local range_mt = {}

function range_mt:length()
    return self[2] - self[1]
end

function range_mt:scale(by, center)
    return new((self[1] - center) * by + center, (self[2] - center) * by + center)
end

function range_mt:contains(num)
    return self[1] <= num and num <= self[2]
end

for k, v in pairs(vector_mt) do
    npair_mt[k] = v
end
for k, v in pairs(range_mt) do
    npair_mt[k] = v
end

return npair
