--[[
 * The following is a Lua port of the NXML parser:
 * https://github.com/xwitchproject/nxml
 *
 * The NXML Parser is heavily based on code from poro
 * https://github.com/gummikana/poro
 *
 * The poro project is licensed under the Zlib license:
 *
 * --------------------------------------------------------------------------
 * Copyright (c) 2010-2019 Petri Purho, Dennis Belfrage
 * Contributors: Martin Jonasson, Olli Harjola
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 * --------------------------------------------------------------------------
]]

---@alias int integer
---@alias bool boolean
---@alias str string
---@alias token_type "string" | "<" | ">" | "/" | "="
---@alias error_type "missing_attribute_value" | "missing_element_close" | "missing_equals_sign" | "missing_element_name" | "missing_tag_open" | "mismatched_closing_tag" | "missing_token" | "missing_element" | "duplicate_attribute"
---@alias error_fn fun(type: error_type, msg: str)

---@class (exact) token
---@field value string?
---@field type token_type

---@class (exact) error
---@field type error_type
---@field msg str
---@field row int
---@field col int

---@class (exact) tokenizer: tokenizer_funcs
---@field data str
---@field cur_idx int
---@field prev_idx int byte index where the current token started (used for error positions)
---@field len int
---@field string_token token reused table for string tokens, to avoid a per-token allocation

---@class (exact) parser: parser_funcs
---@field tok tokenizer
---@field errors error[]
---@field error_reporter error_fn

---@class (exact) element: element_funcs
---@field content str[]?
---@field children element[]
---@field attr table<string, string>
---@field name str
---@field errors error[]

local s_byte = string.byte
local s_sub = string.sub

---@param str str
---@param start_idx int
---@param len int
---@return str
local function str_sub(str, start_idx, len)
	return s_sub(str, start_idx + 1, start_idx + len)
end

---@param str str
---@param idx int
---@return integer
local function str_index(str, idx)
	return s_byte(str, idx + 1)
end

---@class nxml
local nxml = {}
---@type fun(type: error_type, msg: str)?
nxml.error_handler = nil

---@class tokenizer_funcs
local TOKENIZER_FUNCS = {}
local TOKENIZER_MT = {
	__index = TOKENIZER_FUNCS,
	__tostring = function(_)
		return "nxml::tokenizer"
	end,
}

---@param cstring str
---@return tokenizer
local function new_tokenizer(cstring)
	---@type tokenizer
	local tokenizer = {
		data = cstring,
		cur_idx = 0,
		prev_idx = 0,
		len = #cstring,
		string_token = { type = "string", value = nil },
	}
	-- idk why luals doesn't like this
	---@diagnostic disable-next-line: return-type-mismatch
	return setmetatable(tokenizer, TOKENIZER_MT)
end

local C_NULL = 0
local C_LT = string.byte("<")
local C_GT = string.byte(">")
local C_SLASH = string.byte("/")
local C_EQ = string.byte("=")
local C_QUOTE = string.byte('"')
local C_BANG = string.byte("!")
local C_DASH = string.byte("-")
local C_QMARK = string.byte("?")
local C_NL = string.byte("\n")

-- Same table can be returned for every "<", ">", "/", "=" instead of allocating a fresh one per token.
local TOK_LT = { type = "<" }
local TOK_GT = { type = ">" }
local TOK_SLASH = { type = "/" }
local TOK_EQ = { type = "=" }

---@type table<int, bool>
local ws = {
	[string.byte(" ")] = true,
	[string.byte("\t")] = true,
	[C_NL] = true,
	[string.byte("\r")] = true,
}

---@type table<int, bool>
local punct = {
	[C_LT] = true,
	[C_GT] = true,
	[C_EQ] = true,
	[C_SLASH] = true,
}

---Byte-indexed delimiter table (whitespace + punctuation).
---@type table<int, bool>
local delim = {}
for i = 0, 255 do
	delim[i] = false
end
for k in pairs(ws) do
	delim[k] = true
end
for k in pairs(punct) do
	delim[k] = true
end

---Advance a single character.
---@param self tokenizer
local function tokenizer_move(self)
	self.cur_idx = self.cur_idx + 1
end

---@param self tokenizer
---@return int
local function tokenizer_cur_char(self)
	local i = self.cur_idx
	if i >= self.len then
		return 0
	end
	return str_index(self.data, i)
end

---Compute the 1-based row and column of the current token's start.
---@return int row
---@return int col
function TOKENIZER_FUNCS:prev_position()
	---@cast self tokenizer
	local data = self.data
	local target = self.prev_idx
	local row = 1
	local last_newline = -1
	for i = 0, target - 1 do
		if str_index(data, i) == C_NL then
			row = row + 1
			last_newline = i
		end
	end
	return row, target - last_newline
end

---Advance until the next semantically relevant token
---@param self tokenizer
local function tokenizer_skip_whitespace(self)
	local data = self.data
	local len = self.len
	local i = self.cur_idx
	while i < len do
		local c = str_index(data, i)
		if ws[c] then
			i = i + 1
		elseif c == C_LT then
			local c1 = str_index(data, i + 1)
			if c1 == C_BANG then
				if str_index(data, i + 2) == C_DASH and str_index(data, i + 3) == C_DASH then
					-- <!-- comment -->
					i = i + 4
					while
						i < len
						and not (
							str_index(data, i) == C_DASH
							and str_index(data, i + 1) == C_DASH
							and str_index(data, i + 2) == C_GT
						)
					do
						i = i + 1
					end
					i = i + 3
				else
					-- <!DOCTYPE ...> or similar
					i = i + 2
					while i < len and str_index(data, i) ~= C_GT do
						i = i + 1
					end
					i = i + 1
				end
			elseif c1 == C_QMARK then
				-- <?xml ... ?>
				i = i + 2
				while i < len and not (str_index(data, i) == C_QMARK and str_index(data, i + 1) == C_GT) do
					i = i + 1
				end
				i = i + 2
			else
				break
			end
		else
			break
		end
	end
	self.cur_idx = i
end

---Read a double-quoted string, starting just after the opening quote.
---@param self tokenizer
---@return str
local function tokenizer_read_quoted_string(self)
	local data = self.data
	local len = self.len
	local start_idx = self.cur_idx
	local i = start_idx
	while i < len and str_index(data, i) ~= C_QUOTE do
		i = i + 1
	end
	self.cur_idx = i + 1 -- skip closing quote
	return str_sub(data, start_idx, i - start_idx)
end

---Read a bare token up to the next whitespace or punctuation byte.
---@param self tokenizer
---@return str
local function tokenizer_read_unquoted_string(self)
	local data = self.data
	local len = self.len
	local start_idx = self.cur_idx - 1 -- first char already consumed by next_token
	local i = self.cur_idx
	while i < len do
		if delim[str_index(data, i)] then
			break
		end
		i = i + 1
	end
	self.cur_idx = i
	return str_sub(data, start_idx, i - start_idx)
end

---@param self tokenizer
---@return token?
local function tokenizer_next_token(self)
	tokenizer_skip_whitespace(self)
	self.prev_idx = self.cur_idx
	if self.cur_idx >= self.len then
		return nil
	end

	local c = str_index(self.data, self.cur_idx)
	self.cur_idx = self.cur_idx + 1

	if c == C_NULL then
		return nil
	elseif c == C_LT then
		return TOK_LT
	elseif c == C_GT then
		return TOK_GT
	elseif c == C_SLASH then
		return TOK_SLASH
	elseif c == C_EQ then
		return TOK_EQ
	elseif c == C_QUOTE then
		local v = self.string_token
		v.value = tokenizer_read_quoted_string(self)
		return v
	else
		local v = self.string_token
		v.value = tokenizer_read_unquoted_string(self)
		return v
	end
end

---@class parser_funcs
local PARSER_FUNCS = {}
local PARSER_MT = {
	__index = PARSER_FUNCS,
	__tostring = function(_)
		return "nxml::parser"
	end,
}

---@param type error_type
---@param msg string
local function default_error_reporter(type, msg)
	print("parser error: [" .. type .. "] " .. msg)
end

---@param tokenizer tokenizer
---@param error_reporter fun(type: error_type, msg: str)?
---@return parser | parser_funcs parser
local function new_parser(tokenizer, error_reporter)
	---@type parser
	local parser = {
		tok = tokenizer,
		errors = {},
		error_reporter = error_reporter or default_error_reporter,
	}
	-- why does luals not care about here?
	return setmetatable(parser, PARSER_MT)
end

---@class element_funcs
local XML_ELEMENT_FUNCS = {}
local XML_ELEMENT_MT = {
	__index = XML_ELEMENT_FUNCS,
	__tostring = function(self)
		return nxml.tostring(self, false)
	end,
}

---@param type error_type
---@param msg str
function PARSER_FUNCS:report_error(type, msg)
	---@cast self parser
	self.error_reporter(type, msg)
	local row, col = self.tok:prev_position()
	---@type error
	local error = { type = type, msg = msg, row = row, col = col }
	table.insert(self.errors, error)
end

---@param attr_table table<str, str>
---@param name str
function PARSER_FUNCS:parse_attr(attr_table, name)
	---@cast self parser
	local tok = tokenizer_next_token(self.tok)
	if not tok then
		self:report_error("missing_token", string.format("parsing attribute '%s' - did not find a token", name))
		return
	end
	if tok.type == "=" then
		tok = tokenizer_next_token(self.tok)

		if not tok then
			self:report_error("missing_token", string.format("parsing attribute '%s' - did not find a token", name))
			return
		end

		if tok.type == "string" then
			if attr_table[name] ~= nil then
				self:report_error(
					"duplicate_attribute",
					string.format("parsing attribute '%s' - attribute already exists", name)
				)
				return
			end
			attr_table[name] = tok.value
		else
			self:report_error(
				"missing_attribute_value",
				string.format("parsing attribute '%s' - expected a string after =, but did not find one", name)
			)
		end
	else
		self:report_error(
			"missing_equals_sign",
			string.format("parsing attribute '%s' - did not find equals sign after attribute name", name)
		)
	end
end

---@param skip_opening_tag bool
---@return element?
function PARSER_FUNCS:parse_element(skip_opening_tag)
	---@cast self parser

	---@type token?
	local tok
	if not skip_opening_tag then
		tok = tokenizer_next_token(self.tok)
		if not tok then
			self:report_error("missing_token", "parsing element - did not find a token")
			return
		end
		if tok.type ~= "<" then
			self:report_error("missing_tag_open", "couldn't find a '<' to start parsing with")
		end
	end

	tok = tokenizer_next_token(self.tok)
	if not tok then
		self:report_error("missing_token", "parsing element - did not find a token")
		return
	end
	if tok.type ~= "string" then
		self:report_error("missing_element_name", "expected an element name after '<'")
	end

	local elem_name = tok.value
	if not elem_name then
		self:report_error("missing_attribute_value", "parse element element missing name")
		return
	end
	local elem = nxml.new_element(elem_name)
	local content_idx = 0

	local self_closing = false

	while true do
		tok = tokenizer_next_token(self.tok)

		if tok == nil then
			return elem
		elseif tok.type == "/" then
			if tokenizer_cur_char(self.tok) == C_GT then
				tokenizer_move(self.tok)
				self_closing = true
			end
			break
		elseif tok.type == ">" then
			break
		elseif tok.type == "string" then
			self:parse_attr(elem.attr, tok.value)
		end
	end

	if self_closing then
		return elem
	end

	while true do
		tok = tokenizer_next_token(self.tok)

		if tok == nil then
			return elem
		elseif tok.type == "<" then
			if tokenizer_cur_char(self.tok) == C_SLASH then
				tokenizer_move(self.tok)

				local end_name = tokenizer_next_token(self.tok)
				if not end_name then
					self:report_error(
						"missing_token",
						string.format("parsing element '%s' - did not find a token", elem_name)
					)
					return
				end
				if end_name.type == "string" and end_name.value == elem_name then
					local close_greater = tokenizer_next_token(self.tok)
					if not close_greater then
						self:report_error(
							"missing_token",
							string.format("parsing element '%s' - did not find a token", elem_name)
						)
						return
					end

					if close_greater.type == ">" then
						return elem
					else
						self:report_error(
							"missing_element_close",
							string.format("no closing '>' found for element '%s'", elem_name)
						)
					end
				else
					self:report_error(
						"mismatched_closing_tag",
						string.format(
							"closing element is in wrong order - expected '</%s>', but instead got '%s'",
							elem_name,
							tostring(end_name.value)
						)
					)
				end
				return elem
			else
				local child = self:parse_element(true)
				table.insert(elem.children, child)
			end
		else
			if not elem.content then
				elem.content = {}
			end

			content_idx = content_idx + 1
			elem.content[content_idx] = tok.value or tok.type
		end
	end
end

---@return element[]
function PARSER_FUNCS:parse_elements()
	---@cast self parser
	local tok = tokenizer_next_token(self.tok)
	---@type element[]
	local elems = {}
	local elems_i = 1

	while tok and tok.type == "<" do
		local next_element = self:parse_element(true)
		if not next_element then
			self:report_error("missing_element", "parse_element returned nil while parsing elements")
			return elems
		end
		elems[elems_i] = next_element
		elems_i = elems_i + 1

		tok = tokenizer_next_token(self.tok)
	end

	return elems
end

---@param str str
---@return bool
local function is_punctuation(str)
	return str == "/" or str == "<" or str == ">" or str == "="
end

---Copies attributes from `source` to `dest` if dest doesn't have a value
---@param dest element
---@param source element
local function merge_element(dest, source)
	for attr_name, attr_value in pairs(source.attr) do
		if dest:get(attr_name) == nil then
			dest:set(attr_name, attr_value)
		end
	end
end

---Merge the content of the base file into the child tree
---@param root element
---@param base_element element
---@param base_file element
local function merge_xml(root, base_element, base_file)
	local index = 1
	---@type table<string, integer>
	local counts = {}
	for elem in base_file:each_child() do
		if not counts[elem.name] then
			counts[elem.name] = 0
		end
		counts[elem.name] = counts[elem.name] + 1
		local modifications = base_element:nth_of(elem.name, counts[elem.name])
		if modifications then
			merge_element(modifications, elem)
			--[[if #elem.children > 0 then
				merge_xml(root, base, elem)
			end]]
		else
			table.insert(base_element.children, index, elem)
			index = index + 1
		end
	end

	for attr_name, attr_value in pairs(base_file.attr) do
		if not root:get(attr_name) then
			root:set(attr_name, attr_value)
		elseif attr_name == "tags" then
			local tags = root:get("tags") .. "," .. attr_value
			local tag_list = {}
			---@type table<string, boolean>
			local tag_table = {}
			for tag in tags:gmatch("([^,]+)") do
				if tag ~= "" and not tag_table[tag] then
					table.insert(tag_list, tag)
					tag_table[tag] = true
				end
			end
			tags = table.concat(tag_list, ",")
			root:set(attr_name, tags)
		end
	end

	--[[
	TODO:
	local to_remove = {}
	for idx, elem in ipairs(parent.children) do
		if elem.attr._remove_from_base == "1" then
			table.insert(to_remove, 1, idx)
		end
	end
	for _, idx in ipairs(to_remove) do
		table.remove(parent.children, idx)
	end
]]
end

---Expands the Base files for an entity xml
---Returns `self` for chaining purposes.
---**WARN: This is not 100% identical to Nollas implementation, _remove_from_base does not work**
---
---@param read (fun(path: str): str)? `ModTextFileGetContent`
---@param exists (fun(path: str): bool)? `ModDoesFileExist`
---@return element self
function XML_ELEMENT_FUNCS:expand_base(read, exists)
	---@cast self element
	if self.name ~= "Entity" then
		return self
	end
	---@cast self element
	-- thanks Kaedenn for writing this!
	read = read or ModTextFileGetContent
	exists = exists or ModDoesFileExist
	---@type element?
	local base_tag
	while true do
		base_tag = self:first_of("Base")
		if not base_tag then
			break
		end
		local file = base_tag:get("file")
		if file and exists(file) then
			local root_xml = nxml.parse_file(file, read)

			root_xml:expand_base(read, exists)

			merge_xml(self, base_tag, root_xml)
			self:lift_child(base_tag)
		else
			self:remove_child(base_tag)
		end
	end
	for elem in self:each_child() do
		elem:expand_base(read, exists)
	end
	return self
end

---Returns `self` for chaining purposes.
---@param defaults table<string, table<string, any>>
---@return element
function XML_ELEMENT_FUNCS:apply_defaults(defaults)
	---@cast self element
	local apply = defaults[self.name]
	for child in self:each_child() do
		child:apply_defaults(defaults)
	end
	if not apply then
		return self
	end
	for k, v in pairs(apply) do
		if self:get(k) == nil then
			self:set(k, v)
		end
	end
	return self
end

---Append an element's content pieces into a string buffer, inserting a space between two pieces unless either is punctuation
---@param content str[]
---@param buffer str[]
---@param n int current buffer length
---@return int n new buffer length
local function append_text(content, buffer, n)
	local count = #content
	if count == 0 then
		return n
	end
	n = n + 1
	buffer[n] = content[1]
	for i = 2, count do
		local cur = content[i]
		if not (is_punctuation(cur) or is_punctuation(content[i - 1])) then
			n = n + 1
			buffer[n] = " "
		end
		n = n + 1
		buffer[n] = cur
	end
	return n
end

---If you want to construct a new element and immediately add it use `:create_child`.
---This is useful for moving children around in the tree.
---Returns `self` for chaining purposes.
---@param child element
---@return element self
function XML_ELEMENT_FUNCS:add_child(child)
	---@cast self element
	self.children[#self.children + 1] = child
	return self
end

---Returns `self` for chaining purposes.
---@param children element[]
---@return element self
function XML_ELEMENT_FUNCS:add_children(children)
	---@cast self element
	for _, child in ipairs(children) do
		self:add_child(child)
	end
	return self
end

---Creates a new element and adds it as a child to this element.
---Convenience function that combines `xml:add_child` with `nxml.new_element`.
---
---Example usage:
---```lua
--- elem:create_child("LifetimeComponent", { lifetime = 30 })
---```
---@param name str
---@param attrs table<str, any>? description of child element
---@param children element[]? child elements
---@return element new the element that was created
function XML_ELEMENT_FUNCS:create_child(name, attrs, children)
	local elem = nxml.new_element(name, attrs, children)
	self:add_child(elem)
	return elem
end

---Creates several new elements and inserts them as children to this element.
---Convenience function that combines xml:add_children with nxml.new_element.
---
---Example usage:
---```lua
---	elem:create_children(
---		{ AbilityComponent = {
---			ui_name = "$item_jar_with_mat"
---		}},
---		{ DamageModelComponent = {
---			hp = 2
---		}}
---	)
---```
---@param ... table<str, table<str,any>> descriptions of child elements
---@return element self for chaining purposes
function XML_ELEMENT_FUNCS:create_children(...)
	local elems = {}
	for _, elem_desc in ipairs({ ... }) do
		for name, attrs in pairs(elem_desc) do
			table.insert(elems, nxml.new_element(name, attrs))
		end
	end
	return self:add_children(elems)
end

---Removes the given child, note that this is exact equality not structural equality so copies will not be considered equal. Returns `self` for chaining purposes.
---@param child element
---@return element self
function XML_ELEMENT_FUNCS:remove_child(child)
	---@cast self element
	for i = 1, #self.children do
		if self.children[i] == child then
			table.remove(self.children, i)
			break
		end
	end
	return self
end

---Removes the given child, but adds its children to this element. Returns `self` for chaining purposes
---@param child element
---@return element
function XML_ELEMENT_FUNCS:lift_child(child)
	---@cast self element
	for k, v in ipairs(self.children) do
		if v == child then
			local dst_index = k + 1
			for elem in child:each_child() do
				table.insert(self.children, dst_index, elem)
				dst_index = dst_index + 1
			end
			table.remove(self.children, k)
			break
		end
	end
	return self
end

---Returns `self` for chaining purposes
---@param index int
---@return element
function XML_ELEMENT_FUNCS:remove_child_at(index)
	---@cast self element
	table.remove(self.children, index)
	return self
end

---Returns `self` for chaining purposes
---@return element
function XML_ELEMENT_FUNCS:clear_children()
	---@cast self element
	self.children = {}
	return self
end

---Returns `self` for chaining purposes
---@return element
function XML_ELEMENT_FUNCS:clear_attrs()
	---@cast self element
	self.attr = {}
	return self
end

---Returns the first child element with the given name and its index.
---@param element_name str
---@return element?, int?
function XML_ELEMENT_FUNCS:first_of(element_name)
	---@cast self element
	for k, v in ipairs(self.children) do
		if v.name == element_name then
			return v, k
		end
	end
end

---Returns the nth child element with the given name and its index.
---@param element_name str
---@param n int
---@return element?, int?
function XML_ELEMENT_FUNCS:nth_of(element_name, n)
	---@cast self element
	for k, v in ipairs(self.children) do
		if v.name == element_name then
			n = n - 1
			if n == 0 then
				return v, k
			end
		end
	end
end

---Iterate over each child with the given name, effectively a filter.
---Note that this function will behave strangely if you mutate children while iterating.
---Use like:
---```lua
---for dmc in entity:each_of("DamageModelComponent") do
---	dmc:set("hp", 5)
---end
---```
---@param element_name str
---@return fun(): element?
function XML_ELEMENT_FUNCS:each_of(element_name)
	---@cast self element
	local i = 1
	local n = #self.children

	return function()
		while i <= n do
			local child = self.children[i]
			i = i + 1
			if child.name == element_name then
				return child
			end
		end
	end
end

---Collects all children with the given name into a table.
---@param element_name str
---@return element[]
function XML_ELEMENT_FUNCS:all_of(element_name)
	---@cast self element
	---@type element[]
	local all = {}
	local i = 1
	for elem in self:each_of(element_name) do
		all[i] = elem
		i = i + 1
	end
	return all
end

---Iterate over each child of the xml element, use like:
---```lua
---for child in elem:each_child() do
---	print(child.name)
---end
---```
---@return fun(): element?
function XML_ELEMENT_FUNCS:each_child()
	---@cast self element
	local i = 0
	local n = #self.children

	return function()
		while i < n do
			i = i + 1
			return self.children[i]
		end
	end
end

---@param value str | bool
---@return str
local function attr_value_to_str(value)
	local t = type(value)
	if t == "string" then
		return value
	end
	if t == "boolean" then
		return value and "1" or "0"
	end

	return tostring(value)
end

---Gets the given attribute, note get's value is probably stringified and not the true value.
---@param attr str
---@return str?
function XML_ELEMENT_FUNCS:get(attr)
	---@cast self element
	return self.attr[attr]
end

---Sets the given attribute, make sure your type can be stringified. Returns `self` for chaining purposes.
---@param attr str
---@param value any
---@return element
function XML_ELEMENT_FUNCS:set(attr, value)
	---@cast self element
	self.attr[attr] = attr_value_to_str(value)
	return self
end

---Unsets the given attribute. Returns `self` for chaining purposes.
---@param attr str
---@return element
function XML_ELEMENT_FUNCS:unset(attr)
	---@cast self element
	self.attr[attr] = nil
	return self
end

---@return element
function XML_ELEMENT_FUNCS:clone()
	---@cast self element
	local children = {}
	for e in self:each_child() do
		table.insert(children, e:clone())
	end
	---@type table<string, string>
	local attr = {}
	for k, v in pairs(self.attr) do
		attr[k] = v
	end
	return nxml.new_element(self.name, attr, children)
end

---Allows you to have an xml element which represents a file, with changes made in the xml element reflecting in the file when you exit the `edit_file()` scope.
---Use like:
---```lua
---for content in nxml.edit_file("data/entities/animals/boss_centipede/boss_centipede.xml") do
---	content:first_of("DamageModelComponent"):set("hp", 2)
---end
----- Kolmis file is edited once we exit the for loop.
---```
---@param file str
---@param read (fun(filename: str): str)? `ModTextFileGetContent`
---@param write fun(filename: str, content: str)? `ModTextFileSetContent`
---@return fun(): element?
function nxml.edit_file(file, read, write)
	read = read or ModTextFileGetContent
	write = write or ModTextFileSetContent
	local first_time = true
	local tree = nxml.parse_file(file, read)
	return function()
		if not first_time then
			write(file, nxml.tostring(tree))
			return
		end
		first_time = false
		return tree
	end
end

---Parses a file. This is noita specific as it uses `ModTextFileGetContent`, but if you pass your own read function you can use it in a standalone context.
---@param file str
---@param read (fun(filename: str): str)? `ModTextFileGetContent`
---@return element
function nxml.parse_file(file, read)
	read = read or ModTextFileGetContent
	local content = read(file)
	local tok = new_tokenizer(content)
	local parser = new_parser(tok, nxml.error_handler)

	local elem = parser:parse_element(false)

	if not elem or (elem.errors and #elem.errors > 0) then
		error("parser encountered errors")
	end

	return elem
end

---The primary nxml function, converts nxml source into an element.
---Note it is the content not the filename, use `nxml.parse_file()` to parse by filename.
---@param data str
---@return element
function nxml.parse(data)
	local tok = new_tokenizer(data)
	local parser = new_parser(tok, nxml.error_handler)

	local elem = parser:parse_element(false)

	if not elem or (elem.errors and #elem.errors > 0) then
		error("parser encountered errors")
	end

	return elem
end

---This parses xml files with multiple base nodes, useful for biome xmls.
---Exaample file:
---```xml
---<A />
---<B />
---<C />
---```
---@param data str
---@return element[]
function nxml.parse_many(data)
	local tok = new_tokenizer(data)
	local parser = new_parser(tok, nxml.error_handler)

	local elems = parser:parse_elements()

	for i = 1, #elems do
		local elem = elems[i]

		if elem.errors and #elem.errors > 0 then
			error("parser encountered errors")
		end
	end

	return elems
end

-- All new elements share one empty errors table. Must not be mutated.
local EMPTY_ERRORS = {}

---Constructs an element with the given values, just a wrapper to set the metatable really.
---@param name str
---@param attrs table<str, any>? {}
---@param children element[]? {}
---@return element
function nxml.new_element(name, attrs, children)
	---@type table<string, string>
	local attr = {}
	attrs = attrs or {}
	for k, v in pairs(attrs) do
		attr[k] = attr_value_to_str(v)
	end
	---@type element
	local element = {
		name = name,
		attr = attr,
		children = children or {},
		errors = EMPTY_ERRORS,
		content = nil,
	}
	---@diagnostic disable-next-line: return-type-mismatch
	return setmetatable(element, XML_ELEMENT_MT)
end

---@param elem element
---@param packed boolean
---@param indent_char string
---@param indents string[] indent string per depth, built lazily and reused
---@param depth integer
---@param buffer string[]
---@param n integer current number of entries in `buffer`
---@return integer n new number of entries in `buffer`
local function to_string_internal_impl(elem, packed, indent_char, indents, depth, buffer, n)
	local cur_indent = indents[depth]
	n = n + 1
	buffer[n] = "<"
	n = n + 1
	buffer[n] = elem.name
	local self_closing = #elem.children == 0 and (not elem.content or #elem.content == 0)

	local first = true
	for k, v in pairs(elem.attr) do
		if not packed or first then
			n = n + 1
			buffer[n] = " "
			first = false
		end
		n = n + 1
		buffer[n] = k
		n = n + 1
		buffer[n] = '="'
		n = n + 1
		buffer[n] = attr_value_to_str(v)
		n = n + 1
		buffer[n] = '"'
	end

	if self_closing then
		n = n + 1
		buffer[n] = packed and "/>" or " />"
		return n
	end

	n = n + 1
	buffer[n] = ">"

	-- indent cache: build each depth's indent string once, reuse for all siblings
	local deeper_indent = indents[depth + 1]
	if not deeper_indent then
		deeper_indent = cur_indent .. indent_char
		indents[depth + 1] = deeper_indent
	end

	if elem.content and #elem.content ~= 0 then
		if not packed then
			n = n + 1
			buffer[n] = "\n"
			n = n + 1
			buffer[n] = deeper_indent
		end
		n = append_text(elem.content, buffer, n)
	end

	if not packed then
		n = n + 1
		buffer[n] = "\n"
	end

	for _, v in ipairs(elem.children) do
		if not packed then
			n = n + 1
			buffer[n] = deeper_indent
		end
		n = to_string_internal_impl(v, packed, indent_char, indents, depth + 1, buffer, n)
		if not packed then
			n = n + 1
			buffer[n] = "\n"
		end
	end

	n = n + 1
	buffer[n] = cur_indent
	n = n + 1
	buffer[n] = "</"
	n = n + 1
	buffer[n] = elem.name
	n = n + 1
	buffer[n] = ">"
	return n
end

---@param elem element
---@param packed bool
---@param indent_char string
---@param cur_indent string
---@return string
local function to_string_internal(elem, packed, indent_char, cur_indent)
	local buffer = {}
	local indents = { [0] = cur_indent }
	to_string_internal_impl(elem, packed, indent_char, indents, 0, buffer, 0)
	return table.concat(buffer)
end

---Generally you should do tostring(elem) instead of calling this function.
---This function is just how it's implemented and is exposed for more customisation.
---@param elem element
---@param packed? bool `false` the string representation of the xml will be minimal if true
---@param indent_char str? `"\t"`
---@param cur_indent str? `""` the current level of indentation, you probably don't want to change this
---@return str
function nxml.tostring(elem, packed, indent_char, cur_indent)
	indent_char = indent_char or "\t"
	cur_indent = cur_indent or ""
	return to_string_internal(elem, packed or false, indent_char, cur_indent)
end

return nxml
