---@meta

---@class multi_iterator
local multi_iterator = {}

---@param fun fun(...: any)
function multi_iterator:each(fun) end

multi_iterator.for_each = multi_iterator.each
multi_iterator.foreach = multi_iterator.each

---@param n integer
---@return any ...
function multi_iterator:nth(n) end

---@return any ...
function multi_iterator:head() end

multi_iterator.car = multi_iterator.head

---@return any ...
function multi_iterator:tail() end

multi_iterator.cdr = multi_iterator.tail

---@param n integer
---@return multi_iterator
function multi_iterator:take_n(n) end

---@param predicate fun(...: any): boolean
---@return multi_iterator
function multi_iterator:take_while(predicate) end

---@param n_or_predicate integer|fun(...: any): boolean
---@return multi_iterator
function multi_iterator:take(n_or_predicate) end

---@param n integer
---@return multi_iterator
function multi_iterator:drop_n(n) end

---@param predicate fun(...: any): boolean
---@return multi_iterator
function multi_iterator:drop_while(predicate) end

---@param n_or_predicate integer|fun(...: any): boolean
---@return multi_iterator
function multi_iterator:drop(n_or_predicate) end

---@param n_or_predicate integer|fun(...: any): boolean
---@return multi_iterator
---@return multi_iterator
function multi_iterator:span(n_or_predicate) end

multi_iterator.split = multi_iterator.span

---@param n integer
---@return multi_iterator
---@return multi_iterator
function multi_iterator:split_at(n) end

-- make no sense
--[[ ---@param self multi_iterator
---@param t T
---@return integer?
function multi_iterator:index(t) end

multi_iterator.index_of = multi_iterator.index
multi_iterator.elem_index = multi_iterator.index

---@param t T
---@return integer[]
function multi_iterator:indexes(t) end

multi_iterator.indices = multi_iterator.indexes
multi_iterator.elem_indexes = multi_iterator.indexes
multi_iterator.elem_indices = multi_iterator.indexes ]]

---@param predicate fun(...: any): boolean
---@return multi_iterator
function multi_iterator:filter(predicate) end

multi_iterator.remove_if = multi_iterator.filter

---@param regexp_or_predicate string|fun(...: any): boolean
---@return multi_iterator
function multi_iterator:grep(regexp_or_predicate) end

---@param predicate string|fun(...: any): boolean
---@return multi_iterator
---@return multi_iterator
function multi_iterator:partition(predicate) end

---@generic R
---@param accfun fun(t1: R, ...: any): R
---@param initval R
---@return R
function multi_iterator:reduce(accfun, initval) end

multi_iterator.foldl = multi_iterator.reduce

---@return integer
function multi_iterator:length() end

-- make no sense
--[[ ---@param iterator2 multi_iterator
---@return boolean
function multi_iterator:is_prefix_of(iterator2) end ]]

---@return boolean
function multi_iterator:is_null() end

---@param predicate fun(...: any): boolean
---@return boolean
function multi_iterator:all(predicate) end

multi_iterator.every = multi_iterator.all

---@param predicate fun(...: any): boolean
---@return boolean
function multi_iterator:any(predicate) end

multi_iterator.some = multi_iterator.any

---@generic T
---@param fun fun(...: any): T
---@return iterator<T>
function multi_iterator:map(fun) end

---@generic T
---@param fun fun(...: any): any, any, any, any, any, any, any, any
---@return multi_iterator
function multi_iterator:map_multi(fun) end

---@return multi_iterator
function multi_iterator:enumerate() end

---@param x any
---@return multi_iterator
function multi_iterator:intersperse(x) end

---@vararg iterator|multi_iterator
---@return multi_iterator
function multi_iterator:zip(...) end

---@return multi_iterator
function multi_iterator:cycle() end

---@vararg iterator|multi_iterator\
---@return multi_iterator
function multi_iterator:chain(...) end
