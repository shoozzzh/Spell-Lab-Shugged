local id_allocator = {}

local call_map = {}
local id_map = {}
local id_next = 2 -- skip 0 and 1
local id_used = { false, false }

function id_allocator.new_frame()
	for loc, _ in pairs( call_map ) do
		call_map[ loc ] = 0
	end
end

function id_allocator.get_id()
	local loc = jit.util.funcinfo( setfenv( 2, getfenv(2) ) ).loc

	local call_num = call_map[ loc ]
	if not call_num then
		call_num = 1
		call_map[ loc ] = call_num
	end
	call_map[ loc ] = call_num + 1
	
	local loc_ids = id_map[ loc ]
	if not loc_ids then
		loc_ids = {}
		id_map[ loc ] = loc_ids
	end

	local id = loc_ids[ call_num ]
	if not id then
		id = id_next
		id_next = id_next + 1
		loc_ids[ call_num ] = id
	end

	id_used[ id ] = true

	return id
end

return id_allocator