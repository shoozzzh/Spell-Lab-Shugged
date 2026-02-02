local menus = {
	active = "",
}

function menus:is_active( picker )
	return picker == self.active
end

function menus:set_active( picker )
	local result = picker == self.active
	if result then picker = "" end
	self.current = picker
	return result
end

local menu_path = mod_path .. "files/%s/menu.lua"
function menus:menu()
	dofile_once( menu_path:format( self.active ) )()
end

local buttons_path = mod_path .. "files/%s/buttons.lua"
function menus:buttons()
	dofile_once( buttons_path:format( self.active ) )()
end

---@param module_name string
---@param filepath string
---@param option_text string?
---@return boolean
---@return boolean
function menus:toggle_button( module_name, filepath, option_text )
	if module_name ~= self.active then
		pop.option_next "DrawSemiTransparent"
	end
	option_text = get_text( option_text or module_name )
	local changed = false
	if module_name == self.active then
		if pop.button( filepath ) then
			sound_button_clicked()
			self:set_active ""
			changed = true
		end
		pop.tooltip( get_text "disable" .. option_text )
	else
		if pop.button( filepath ) then
			sound_button_clicked()
			self:set_active( module_name )
			changed = true
		end
		pop.tooltip( get_text "enable" .. option_text )
	end
	return changed, module_name == self.active
end

return menus
