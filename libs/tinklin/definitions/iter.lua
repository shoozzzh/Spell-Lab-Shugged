---@meta

---@class iterator<T>
local iterator = {}

---@generic T
---@param self iterator<T>
---@param fun fun(t: T)
function iterator:each(fun) end

iterator.for_each = iterator.each
iterator.foreach = iterator.each

---@generic T
---@param self iterator<T>
---@param n integer
---@return T?
function iterator:nth(n) end

---@generic T
---@param self iterator<T>
---@return T
function iterator:head() end

iterator.car = iterator.head

---@generic T
---@param self iterator<T>
---@return T
function iterator:tail() end

iterator.cdr = iterator.tail

---@generic T
---@param self iterator<T>
---@param n integer
---@return iterator<T>
function iterator:take_n(n) end

---@generic T
---@param self iterator<T>
---@param predicate fun(t: T): boolean
---@return iterator<T>
function iterator:take_while(predicate) end

---@generic T
---@param self iterator<T>
---@param n_or_predicate integer|fun(t: T): boolean
---@return iterator<T>
function iterator:take(n_or_predicate) end

---@generic T
---@param self iterator<T>
---@param n integer
---@return iterator<T>
function iterator:drop_n(n) end

---@generic T
---@param self iterator<T>
---@param predicate fun(t: T): boolean
---@return iterator<T>
function iterator:drop_while(predicate) end

---@generic T
---@param self iterator<T>
---@param n_or_predicate integer|fun(t: T): boolean
---@return iterator<T>
function iterator:drop(n_or_predicate) end

---@generic T
---@param self iterator<T>
---@param n_or_predicate integer|fun(t: T): boolean
---@return iterator<T>
---@return iterator<T>
function iterator:span(n_or_predicate) end

iterator.split = iterator.span

---@generic T
---@param self iterator<T>
---@param n integer
---@return iterator<T>
---@return iterator<T>
function iterator:split_at(n) end

---@generic T
---@param self iterator<T>
---@param t T
---@return integer?
function iterator:index(t) end

iterator.index_of = iterator.index
iterator.elem_index = iterator.index

---@generic T
---@param self iterator<T>
---@param t T
---@return integer[]
function iterator:indexes(t) end

iterator.indices = iterator.indexes
iterator.elem_indexes = iterator.indexes
iterator.elem_indices = iterator.indexes

---@generic T
---@param self iterator<T>
---@param predicate fun(t: T): boolean
---@return iterator<T>
function iterator:filter(predicate) end

iterator.remove_if = iterator.filter

---@generic T
---@param self iterator<T>
---@param regexp_or_predicate string|fun(t: T): boolean
---@return iterator<T>
function iterator:grep(regexp_or_predicate) end

---@generic T
---@param self iterator<T>
---@param predicate string|fun(t: T): boolean
---@return iterator<T>
---@return iterator<T>
function iterator:partition(predicate) end

---@generic T, R
---@param self iterator<T>
---@param accfun fun(t1: R, t2: T): R
---@param initval R
---@return R
function iterator:reduce(accfun, initval) end

iterator.foldl = iterator.reduce

---@return integer
function iterator:length() end

---@generic T
---@param self iterator<T>
---@param iterator2 iterator<T>
---@return boolean
function iterator:is_prefix_of(iterator2) end

---@generic T
---@param self iterator<T>
---@return boolean
function iterator:is_null() end

---@generic T
---@param self iterator<T>
---@param predicate fun(t: T): boolean
---@return boolean
function iterator:all(predicate) end

iterator.every = iterator.all

---@generic T
---@param self iterator<T>
---@param predicate fun(t: T): boolean
---@return boolean
function iterator:any(predicate) end

iterator.some = iterator.any

---@generic T
---@param self iterator<T>
---@return T
function iterator:sum() end

---@generic T
---@param self iterator<T>
---@return T
function iterator:product() end

---@generic T
---@param self iterator<T>
---@return T
function iterator:min() end

iterator.minimum = iterator.min

---@generic T
---@param self iterator<T>
---@param cmp fun(t1: T, t2: T): T
---@return T
function iterator:min_by(cmp) end

iterator.minimum_by = iterator.min_by

---@generic T
---@param self iterator<T>
---@return T
function iterator:max() end

iterator.maximum = iterator.max

---@generic T
---@param self iterator<T>
---@param cmp fun(t1: T, t2: T): T
---@return T
function iterator:max_by(cmp) end

iterator.maximum_by = iterator.max_by

---@generic T,T2
---@param self iterator<T>
---@param fun fun(t: T): T2
---@return iterator<T2>
function iterator:map(fun) end

---@generic T
---@param self iterator<T>
---@param fun fun(t: T): any, any, any, any, any, any, any, any
---@return multi_iterator
function iterator:map_multi(fun) end

---@generic T
---@param self iterator<T>
---@return iterator<[integer,T]>
function iterator:enumerate() end

---@generic T
---@param self iterator<T>
---@param x T
---@return iterator<T>
function iterator:intersperse(x) end

---@param self iterator
---@vararg iterator
---@return multi_iterator
function iterator:zip(...) end

---@generic T
---@param self iterator<T>
---@return iterator<T>
function iterator:cycle() end

---@generic T,T2
---@param self iterator<T>
---@vararg iterator<T2>
---@return iterator<T|T2>
function iterator:chain(...) end
