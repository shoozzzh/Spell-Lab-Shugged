---@module "spell_box"

local module_path = module_path()

local gokis = function( x, y, action_type, selected, hovered )
	local spell_box = { module_path, "goki/" }
	if action_type then
		spell_box[ #spell_box+1 ] = "_"
		spell_box[ #spell_box+1 ] = tostring( action_type )
	end
	if selected then
		spell_box[ #spell_box+1 ] = "_"
		spell_box[ #spell_box+1 ] = "active"
	elseif hovered then
		spell_box[ #spell_box+1 ] = "_"
		spell_box[ #spell_box+1 ] = "hover"
	end
	spell_box[ #spell_box+1 ] = ".png"

	pop.image( x, y, table.concat( spell_box ) )
end

local vanilla_bgs = {
	[ 0 ] = "data/ui_gfx/inventory/item_bg_projectile.png",
	[ 1 ] = "data/ui_gfx/inventory/item_bg_static_projectile.png",
	[ 2 ] = "data/ui_gfx/inventory/item_bg_modifier.png",
	[ 3 ] = "data/ui_gfx/inventory/item_bg_draw_many.png",
	[ 4 ] = "data/ui_gfx/inventory/item_bg_material.png",
	[ 5 ] = "data/ui_gfx/inventory/item_bg_other.png",
	[ 6 ] = "data/ui_gfx/inventory/item_bg_utility.png",
	[ 7 ] = "data/ui_gfx/inventory/item_bg_passive.png",
}

local vanilla = function( x, y, action_type, selected, hovered )
	local box = selected
		and "data/ui_gfx/inventory/full_inventory_box_highlight.png"
		or "data/ui_gfx/inventory/full_inventory_box.png"

	pop.image( x, y, box )

	if action_type == nil then return end

	pop.z_mod( -0.5 )
	pop.image( x, y, vanilla_bgs[ action_type ] )
end


---@type table<string,spellbox_pack>
local spellbox_packs = {
	---@class spellbox_pack
	GOKIS = {
		func = gokis,
		ui_name = {
			zh_cn = "Goki 经典方案",
			DEFAULT = "Goki's Classic Sprites",
		},
	},
	VANILLA = {
		func = vanilla,
		ui_name = {
			zh_cn = "Noita 原版方案",
			DEFAULT = "Vanilla Sprites",
		},
	},
}

local current_pack = spellbox_packs[ tostring( mod_setting_get  "spellbox_pack"  ) ].func

local function update()
	local new_key = mod_setting_get  "spellbox_pack"
	current_pack = spellbox_packs[ tostring( new_key ) ].func
end

update()

--- @class spell_box
local spell_box = {}

function spell_box.update()
	if not mod_setting_get  "spellbox_pack_changed"  then return end
	mod_setting_set( "spellbox_pack_changed", false )

	update()
end

function spell_box.show( ... )
	current_pack( ... )
end

return spell_box
