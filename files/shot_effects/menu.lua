local tl = require "tinklin"
local pop = require "pop"
local gui_elems = require "gui.elems"
local mutils = require "misc_utils"
local get_player = require "get_player"
local settings = require "mod_settings"
local parse_entity_xml = require "parse_entity_xml"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local tr_utils = require "tr_utils"
local spell_data = require "spell_data"

---@type shot_effect[]
local shot_effect_entries = mutils.get_globals "%MODULE_PATH%/entries.lua".shot_effect_entries

local perk_list, STACKABLE_YES = (function()
    local globals = mutils.get_globals "data/scripts/perks/perk_list.lua"
    return globals.perk_list, globals.STACKABLE_YES
end)()
local status_effects = mutils.get_globals "data/scripts/status_effects/status_list.lua".status_effects

local function into_map_from_id(list)
    local map = {}
    for _, v in ipairs(list) do
        map[v.id] = v
    end
    return map
end

---@type table<string, table>
perk_list = into_map_from_id(perk_list)
---@type table<string, table>
status_effects = into_map_from_id(status_effects)

local SHOT_EFFECT_TYPE = {
    extra_modifier = module_tr.type.extra_modifier:key(),
    shot_script    = module_tr.type.shot_script:key(),
    game_effect    = module_tr.type.game_effect:key(),
}
local SHOT_EFFECT_SOURCE_TYPE = {
    Perk         = module_tr.source_type.perk,
    Status       = module_tr.source_type.status,
    CustomEffect = module_tr.source_type.custom_effect,
}

---@class shot_effect
---@field related_perk string?
---@field related_custom_effect string?
---@field related_status string?
---@field id string?
---@field icon string?
---@field name string?
---@field desc string?
---@field type string?
---@field source_type string?
---@field properties {[1]: string, [2]:string}[]?
---@field max_count integer?
---@field no_unsafe boolean?
---@field extra_modifier string[]|string|nil
---@field shot_script string[]|string|nil
---@field game_effect string[]|string|nil
---@field custom_child_entity string[]|string|nil
---@field dont_use_fetched_metadata boolean?
---@field equivalent_action_type integer?

---@class shot_effect_data
---@field id string
---@field icon string
---@field name string
---@field desc string
---@field type string
---@field source_type string
---@field properties {[1]: string, [2]:string}[]
---@field max_count integer
---@field never_unsafe boolean
---@field extra_modifier string[]
---@field shot_script string[]
---@field game_effect string[]
---@field custom_child_entity string[]
---@field equivalent_action_type integer

---@type shot_effect_data[]
local shot_effect_data = {}
for _, shot_effect in ipairs(shot_effect_entries) do
    local data = {}

    data.id = shot_effect.id
    data.name = shot_effect.name
    data.desc = shot_effect.desc
    data.icon = shot_effect.icon
    data.source_type = shot_effect.source_type
    data.max_count = shot_effect.max_count

    do
        local related_status = shot_effect.related_status
        if not related_status then goto related_status_skip end

        local related_status = status_effects[related_status]
        if not related_status then goto related_status_skip end

        data.id = data.id or ("STATUS_" .. related_status.id)
        data.name = data.name or related_status.ui_name
        data.desc = data.desc or related_status.ui_description
        data.icon = data.icon or related_status.ui_icon
        data.source_type = data.source_type or SHOT_EFFECT_SOURCE_TYPE.Status
        data.max_count = data.max_count or 1
    end
    ::related_status_skip::

    do
        local related_custom_effect = shot_effect.related_custom_effect
        if not related_custom_effect then goto related_custom_effect_skip end
        local effect_xml_content = parse_entity_xml(related_custom_effect)
        if not effect_xml_content then goto related_custom_effect_skip end
        local icon_comp = effect_xml_content:first_of "UIIconComponent"
        if not icon_comp then goto related_custom_effect_skip end
        data.id = data.id or string.upper(related_custom_effect:match "([^/]+)%.xml$")
        data.name = data.name or icon_comp.attr.name
        data.desc = data.desc or icon_comp.attr.description
        data.icon = data.icon or icon_comp.attr.icon_sprite_file
        data.source_type = data.source_type or SHOT_EFFECT_SOURCE_TYPE.CustomEffect
    end
    ::related_custom_effect_skip::

    do
        local related_perk = shot_effect.related_perk
        if not related_perk then goto related_perk_skip end

        local related_perk = perk_list[related_perk]
        if not related_perk then goto related_perk_skip end

        data.id = data.id or ("PERK_" .. related_perk.id)
        data.name = data.name or related_perk.ui_name
        data.desc = data.desc or related_perk.ui_description
        data.icon = data.icon or related_perk.perk_icon
        data.source_type = data.source_type or SHOT_EFFECT_SOURCE_TYPE.Perk
        if related_perk.stackable == STACKABLE_YES then
            if related_perk.stackable_maximum then
                data.max_count = data.max_count or related_perk.stackable_maximum
            else
                data.max_count = data.max_count or -1
            end
        else
            data.max_count = data.max_count or 1
        end
    end
    ::related_perk_skip::

    if not data.id or not data.icon or not data.name or not data.desc or not data.source_type then
        goto continue
    end

    local keys = { "extra_modifier", "shot_script", "game_effect", "custom_child_entity" }
    for _, key in ipairs(keys) do
        local value = shot_effect[key]
        if value ~= nil then
            if type(value) ~= "table" then
                data[key] = { value }
            else
                data[key] = value
            end
            if SHOT_EFFECT_TYPE[key] then
                data.type = data.type or SHOT_EFFECT_TYPE[key]
            end
        end
    end

    data.properties = shot_effect.properties or {}
    if data.extra_modifier and #data.extra_modifier > 0 and not shot_effect.dont_use_fetched_metadata then
        local metadata = spell_data.metadata.extra_mod[data.extra_modifier[1]]
        if not metadata then
            print("Invalid extra modifier id:", tostring(data.extra_modifier[1]))
        else
            for _, v in ipairs(spell_data.metadata.shot_state_lines(metadata)) do
                data.properties[#data.properties + 1] = v
            end
        end
    end
    if data.max_count and data.max_count ~= -1 then
        data.properties[#data.properties + 1] = { module_tr.max_count:key(), tostring(data.max_count) }
    else
        data.properties[#data.properties + 1] = { module_tr.max_count:key(), module_tr.max_count.infinite:key() }
    end

    data.equivalent_action_type = shot_effect.equivalent_action_type or ACTION_TYPE_MODIFIER
    data.no_unsafe = shot_effect.no_unsafe == true

    --[[@cast data shot_effect_data]]
    shot_effect_data[#shot_effect_data + 1] = data

    ::continue::
end

local tag_created = "%MODULE_FULL_ID%.created_effect"

---@param player entity
---@param shot_effect shot_effect_data
local function add_shot_effect(player, shot_effect)
    local entity = tl.entity_new()
    player:add_child(entity)

    entity:comp_new "InheritTransformComponent" {}
    entity.tag[tag_created] = true

    entity:comp_new "VariableStorageComponent" { value_string = shot_effect.id }

    tl.fun.iter(shot_effect.extra_modifier or {}):each(function(extra_modifier)
        entity:comp_new "ShotEffectComponent" { extra_modifier = extra_modifier }
    end)
    tl.fun.iter(shot_effect.shot_script or {}):each(function(shot_script)
        entity:comp_new "LuaComponent" { script_shot = shot_script }
    end)
    tl.fun.iter(shot_effect.game_effect or {}):each(function(game_effect)
        entity:comp_new "GameEffectComponent" { effect = game_effect }
    end)
    tl.fun.iter(shot_effect.custom_child_entity or {}):each(function(custom_child_entity)
        tl.entity_load_child(custom_child_entity, player)
    end)
end

---@param player entity
---@param shot_effect shot_effect_data
local function remove_shot_effect(player, shot_effect)
    local id = shot_effect.id
    player:get_children(tag_created):any(function(shot_effect_entity)
        local id_comp = shot_effect_entity:comp_first "VariableStorageComponent"
        if not id_comp then return false end

        if id == id_comp.value_string then
            shot_effect_entity:set_parent(nil)
            shot_effect_entity:kill()
            return true
        end
        return false
    end)
end

local picker = {}
picker.menu = function()
    local player = tl.entity_wrap(get_player())

    local count_table = {}
    player:get_children(tag_created):each(function(shot_effect_entity)
        local id_comp = shot_effect_entity:comp_first "VariableStorageComponent"
        if not id_comp then return end
        local id = id_comp.value_string
        count_table[id] = (count_table[id] or 0) + 1
    end)

    pop.pos.push(640 * 0.05, 360 * 0.16)
    gui_elems.lhs_table(shot_effect_data, function(shot_effect)
        local count = count_table[shot_effect.id] or 0
        local max_count = shot_effect.max_count
        local unsafe_count_allowed = settings.get "%MODULE_ID%.unsafe_count_allowed" and not shot_effect.never_unsafe
        local max_count_valid = max_count and max_count ~= -1
        local count_shown
        if count == 0 then
            count_shown = nil
        elseif not unsafe_count_allowed and max_count == 1 and count <= 1 then
            count_shown = nil
        else
            count_shown = count
        end

        local left_click, right_click = gui_elems.button_fake_action(
            {
                id = tr_utils.get(shot_effect.source_type),
                sprite = shot_effect.icon,
                name = shot_effect.name,
                desc = shot_effect.desc,
                type_spellbox = shot_effect.equivalent_action_type,
                type_text = shot_effect.type,
                uses_remaining = count_shown,
                properties = shot_effect.properties,
            }, count == 0)

        if left_click then
            if not max_count_valid or count < max_count or unsafe_count_allowed then
                gui_elems.sound_button_clicked()
                add_shot_effect(player, shot_effect)
            elseif max_count == 1 and count == 1 then
                gui_elems.sound_button_clicked()
                remove_shot_effect(player, shot_effect)
            end
        elseif right_click then
            if count > 0 then
                gui_elems.sound_button_clicked()
                remove_shot_effect(player, shot_effect)
            end
        end
    end)
    pop.pos.push()
end

picker.buttons = function()
    gui_elems.line_of_buttons { function()
        gui_elems.flag_toggle_button("%MODULE_PATH%/unsafe_values.png", "%MODULE_ID%.unsafe_count_allowed")
    end }
end

return picker
