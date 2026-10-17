---@meta

---@class luafun
local luafun = {}

---@param stop number
---@return iterator<number>
---@overload fun(start: number, stop: number, step: number?): iterator<number>
function luafun.range(stop) end

---@generic T
---@vararg T
---@return iterator<T>
function luafun.duplicate(...) end

luafun.xrepeat = luafun.duplicate
luafun.replicate = luafun.duplicate

---@generic T
---@param fun fun(n: integer): T
---@return iterator<T>
function luafun.tabulate(fun) end

---@return iterator<number>
function luafun.zeros() end

---@return iterator<number>
function luafun.ones() end

---@param n number
---@param m number?
---@return iterator<number>
function luafun.rands(n, m) end

---@generic T
---@param array T[]
---@return iterator<T>
function luafun.iter(array) end

---@generic K, V
---@param map {[K]: V}
---@return multi_iterator
function luafun.entries(map) end

---@param str string
---@return iterator<string>
function luafun.chars(str) end
