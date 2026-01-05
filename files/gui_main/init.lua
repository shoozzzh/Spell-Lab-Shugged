local callbacks = {}

function callbacks.OnWorldPreUpdate()
	dofile( mod_path .. "files/gui/update.lua" )
end

return callbacks
