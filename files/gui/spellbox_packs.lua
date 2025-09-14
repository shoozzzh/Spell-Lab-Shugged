local gokis = function( gui, id, x, y, action_type, selected, hovered, alpha, scale, scale_y, rotation )
	local spell_box = { "mods/spell_lab_shugged/files/gui/buttons/spell_box" }
	if action_type then
		spell_box[ #spell_box + 1 ] = "_"
		spell_box[ #spell_box + 1 ] = tostring( action_type )
	end
	if selected then
		spell_box[ #spell_box + 1 ] = "_"
		spell_box[ #spell_box + 1 ] = "active"
	elseif hover then
		spell_box[ #spell_box + 1 ] = "_"
		spell_box[ #spell_box + 1 ] = "hover"
	end
	spell_box[ #spell_box + 1 ] = ".png"
	spell_box = table.concat( spell_box )

	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiImage( gui, id, x, y, spell_box, alpha, scale, scale_y, rotation )
end

local vanilla_bgs = {
	[0]        = "data/ui_gfx/inventory/item_bg_projectile.png",
	[1] = "data/ui_gfx/inventory/item_bg_static_projectile.png",
	[2]          = "data/ui_gfx/inventory/item_bg_modifier.png",
	[3]         = "data/ui_gfx/inventory/item_bg_draw_many.png",
	[4]          = "data/ui_gfx/inventory/item_bg_material.png",
	[5]             = "data/ui_gfx/inventory/item_bg_other.png",
	[6]           = "data/ui_gfx/inventory/item_bg_utility.png",
	[7]           = "data/ui_gfx/inventory/item_bg_passive.png",
}

local vanilla = function( gui, id, x, y, action_type, selected, hovered, alpha, scale, scale_y, rotation )
	local box = selected
		and "data/ui_gfx/inventory/full_inventory_box_highlight.png"
		or "data/ui_gfx/inventory/full_inventory_box.png"

	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiImage( gui, id, x, y, box, alpha, scale, scale_y, rotation )

	if action_type == nil then return end

	local bg = vanilla_bgs[ action_type ]
	GuiIdPushString( gui, "VANIILA_SPELLBOX" )

	GuiZSetForNextWidget( gui, -0.5 )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.Layout_NoLayouting )
	GuiImage( gui, id, x, y, bg, alpha, scale, scale_y, rotation )

	GuiIdPop( gui )
end

spellbox_packs = {
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

if not mod_setting_get then return end -- if being loaded from settings.lua

local current_spellbox_pack = spellbox_packs[ mod_setting_get( "spellbox_pack" ) ].func

function change_spellbox_pack_if_needed()
	if not mod_setting_get( "spellbox_pack_changed" ) then return end
	mod_setting_set( "spellbox_pack_changed", false )

	local new_key = mod_setting_get( "spellbox_pack" )
	current_spellbox_pack = spellbox_packs[ new_key ]
end

function show_spellbox( ... )
	current_spellbox_pack( ... )
end