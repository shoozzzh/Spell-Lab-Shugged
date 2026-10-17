local editable_text = {}
editable_text.text = ""
editable_text.input_anchor = 1

function editable_text:try_on_changed()
	if self.on_changed then
		self.on_changed()
	end
end

local function insert_character( str, char, index )
	return string.sub( str, 1, index - 1 ) .. char .. string.sub( str, index, -1 )
end

function editable_text:insert_character( char )
	self.text = insert_character( self.text, char, self.input_anchor )
	self.input_anchor = self.input_anchor + 1
	self:try_on_changed()
end

function editable_text:input_anchor_move_left()
	if self.input_anchor > 1 then
		self.input_anchor = self.input_anchor - 1
	end
end

function editable_text:input_anchor_move_right()
	if self.input_anchor <= #self.text then
		self.input_anchor = self.input_anchor + 1
	end
end

function editable_text:input_anchor_move_to_last_word()
	local str_left = string.sub( self.text, 1, self.input_anchor - 1 )
	local last_word_idx, _, _ = string.find( str_left, "[^ ]* *$" )
	if last_word_idx then
		self.input_anchor = last_word_idx
	end
end

function editable_text:input_anchor_move_to_next_word()
	local str_right = string.sub( self.text, self.input_anchor, -1 )
	local _, next_word_idx, _ = string.find( str_right, "^ *[^ ]*" )
	if next_word_idx then
		self.input_anchor = self.input_anchor + next_word_idx
	end
end

function editable_text:left_delete()
	if self.input_anchor >= 2 then
		self.text =
			string.sub( self.text, 1, self.input_anchor - 2 )
			.. string.sub( self.text, self.input_anchor, -1 )
		self.input_anchor = self.input_anchor - 1
		self:try_on_changed()
	end
end

function editable_text:right_delete()
	if self.input_anchor <= #self.text then
		self.text =
			string.sub( self.text, 1, self.input_anchor - 1 )
			.. string.sub( self.text, self.input_anchor + 1, -1 )
		self:try_on_changed()
	end
end

function editable_text:input_anchor_move_to_beginning()
	self.input_anchor = 1
end

function editable_text:input_anchor_move_to_end()
	self.input_anchor = #self.text + 1
end

function editable_text:clear()
	self.text = ""
	self.input_anchor = 1
	self:try_on_changed()
end

return editable_text