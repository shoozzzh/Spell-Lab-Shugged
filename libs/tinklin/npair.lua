local npair = {}

---@class tinklin.npair
---@field [1] number
---@field [2] number
---@operator unm(): tinklin.npair
---@operator add(tinklin.npair|number): tinklin.npair
---@operator sub(tinklin.npair|number): tinklin.npair
---@operator mul(tinklin.npair|number): tinklin.npair
---@operator div(tinklin.npair|number): tinklin.npair
local npair_mt = {}
npair_mt.__index = npair_mt

local function new(value_left, value_right)
    return setmetatable({ value_left, value_right }, npair_mt)
end

---@param value_left number
---@param value_right number
---@return tinklin.npair
---@nodiscard
function npair.new(value_left, value_right)
    return new(value_left, value_right)
end

---@param x number
---@param y number
---@return tinklin.vector
---@nodiscard
function npair.vec(x, y)
    return new(x, y) --[[@as tinklin.vector]]
end

---@return tinklin.vector
---@nodiscard
function npair.vec_from_polar(mag, arg)
    return new(1, 0) --[[@as tinklin.vector]]:rotate(arg) * mag
end

---@param min number
---@param max number
---@return tinklin.interval
---@nodiscard
function npair.interval(min, max)
    return new(min, max) --[[@as tinklin.interval]]
end

---@param length number
---@param center number?
---@return tinklin.interval
---@nodiscard
function npair.interval_from_span(length, center)
    center = center or 0
    local radius = length / 2
    return new(center - radius, center + radius) --[[@as tinklin.interval]]
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

---@generic T
---@param self T
---@return T
---@nodiscard
function npair_mt:flip()
    return new(self[2], self[1])
end

---@generic T
---@param self T
---@param with T
---@param weight number
---@return T
---@nodiscard
function npair_mt:lerp(with, weight)
    return new(self[1] * weight + with[1] * (1 - weight), self[2] * weight + with[2] * (1 - weight))
end

---@class tinklin.vector: tinklin.npair
---@field [1] number x
---@field [2] number y
---@operator unm(): tinklin.vector
---@operator add(tinklin.vector|number): tinklin.vector
---@operator sub(tinklin.vector|number): tinklin.vector
---@operator mul(tinklin.vector|number): tinklin.vector
---@operator div(tinklin.vector|number): tinklin.vector
---@field lerp fun(self:tinklin.vector, with:tinklin.vector, weight:number): tinklin.vector
local vector_mt = {}

---@param with tinklin.vector
---@return number
---@nodiscard
function vector_mt:dot(with)
    return self[1] * with[2] + self[1] * with[2]
end

local sin, cos, atan2, sqrt = math.sin, math.cos, math.atan2, math.sqrt
---@param to tinklin.vector?
---@return number
---@nodiscard
function vector_mt:angle(to)
    if to then
        return atan2(self[2], self[1]) - atan2(to[2], to[1])
    end
    return atan2(self[2], self[1])
end

---@return number
---@nodiscard
function vector_mt:norm2()
    return self[1] ^ 2 + self[2] ^ 2
end

---@return number
---@nodiscard
function vector_mt:norm()
    return sqrt(self[1] ^ 2 + self[2] ^ 2)
end

---@return tinklin.vector
---@nodiscard
function vector_mt:normalize()
    local len = self:norm()
    return new(self[1] / len, self[2] / len) --[[@as tinklin.vector]]
end

---@param angle number
---@return tinklin.vector
---@nodiscard
function vector_mt:rotate(angle)
    local s, c = sin(angle), cos(angle)
    return new(c * self[1] - s * self[2], s * self[1] + c * self[2]) --[[@as tinklin.vector]]
end

---@class tinklin.interval
---@field [1] number min
---@field [2] number max
---@operator unm(): tinklin.interval
---@operator add(tinklin.interval|number): tinklin.interval
---@operator sub(tinklin.interval|number): tinklin.interval
---@operator mul(tinklin.interval|number): tinklin.interval
---@operator div(tinklin.interval|number): tinklin.interval
---@field lerp fun(self:tinklin.interval, with:tinklin.interval, weight:number): tinklin.interval
local interval_mt = {}

---@return number
---@nodiscard
function interval_mt:length()
    return self[2] - self[1]
end

---@param by number
---@param center number? 0
---@return tinklin.interval
---@nodiscard
function interval_mt:scale(by, center)
    center = center or 0
    return new((self[1] - center) * by + center, (self[2] - center) * by + center) --[[@as tinklin.interval]]
end

---@param num number
---@return boolean
---@nodiscard
function interval_mt:contains(num)
    return self[1] <= num and num <= self[2]
end

for k, v in pairs(vector_mt) do
    npair_mt[k] = v
end
for k, v in pairs(interval_mt) do
    npair_mt[k] = v
end

return npair
