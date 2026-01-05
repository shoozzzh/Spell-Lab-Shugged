local module_path = this_folder()

local spell_box = dofile_once( module_path .. "main.lua" )

---@type callbacks
local callbacks = {}

show_spell_box = spell_box.show

function callbacks.OnWorldPreUpdate()
	if GameGetFrameNum() % 60 == 0 then
		spell_box.update()
	end
end

return callbacks
