spell_api = {}

local gun_global = get_globals( "data/scripts/gun/gun.lua" )
local actions = gun_global.actions

sorted_actions = {}
action_data = {}
for k, _ in pairs( type_text ) do
	sorted_actions[ k ] = {}
end
for _, action in ipairs( actions ) do
	local typed = sorted_actions[ action.type ]
	typed[ #typed + 1 ] = action
	action_data[ action.id ] = action
end

action_metadata, extra_modifier_metadata, metadata_to_show =
	unpack( dofile( "mods/spell_lab_shugged/files/gui/action_metadata.lua" ) )

action_id_to_idx = {}

type_text = {
	[ACTION_TYPE_MODIFIER]          = "$inventory_actiontype_modifier",
	[ACTION_TYPE_PROJECTILE]        = "$inventory_actiontype_projectile",
	[ACTION_TYPE_STATIC_PROJECTILE] = "$inventory_actiontype_staticprojectile",
	[ACTION_TYPE_OTHER]             = "$inventory_actiontype_other",
	[ACTION_TYPE_MATERIAL]          = "$inventory_actiontype_material",
	[ACTION_TYPE_DRAW_MANY]         = "$inventory_actiontype_drawmany",
	[ACTION_TYPE_UTILITY]           = "$inventory_actiontype_utility",
	[ACTION_TYPE_PASSIVE]           = "$inventory_actiontype_passive",
}

for i, a in ipairs( actions ) do
	if a.id and a.id ~= "" then
		action_id_to_idx[ a.id ] = i
	end
	if a.max_uses ~= nil then
		local hell_no = type( a.max_uses )
		if hell_no == "string" then
			a.max_uses = tonumber( a.max_uses ) or 0
		elseif hell_no ~= "number" then
			a.max_uses = 0
		end
		if a.max_uses < 0 then
			a.max_uses = nil
		end
	end
end

---@type callbacks
local callbacks = {}

function callbacks.OnWorldPreUpdate()
	
end

return callbacks
