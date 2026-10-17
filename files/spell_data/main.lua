local mutils = require "misc_utils"

---@class spell_data
local spell_data = {}

local gun_global = mutils.get_globals "data/scripts/gun/gun.lua"
local actions = gun_global.actions

spell_data.type_text = {
    [gun_global.ACTION_TYPE_MODIFIER]          = "$inventory_actiontype_modifier",
    [gun_global.ACTION_TYPE_PROJECTILE]        = "$inventory_actiontype_projectile",
    [gun_global.ACTION_TYPE_STATIC_PROJECTILE] = "$inventory_actiontype_staticprojectile",
    [gun_global.ACTION_TYPE_OTHER]             = "$inventory_actiontype_other",
    [gun_global.ACTION_TYPE_MATERIAL]          = "$inventory_actiontype_material",
    [gun_global.ACTION_TYPE_DRAW_MANY]         = "$inventory_actiontype_drawmany",
    [gun_global.ACTION_TYPE_UTILITY]           = "$inventory_actiontype_utility",
    [gun_global.ACTION_TYPE_PASSIVE]           = "$inventory_actiontype_passive",
}

spell_data.actions_by_type = {}
spell_data.action_data = {}
for k, _ in pairs(spell_data.type_text) do
    spell_data.actions_by_type[k] = {}
end
for _, action in ipairs(actions) do
    local typed = spell_data.actions_by_type[action.type]
    typed[#typed + 1] = action
    spell_data.action_data[action.id] = action
end

spell_data.metadata = require "spell_data.action_metadata"

spell_data.action_id_to_idx = {}

for i, a in ipairs(actions) do
    if a.id and a.id ~= "" then
        spell_data.action_id_to_idx[a.id] = i
    end
    if a.max_uses ~= nil then
        local hell_no = type(a.max_uses)
        if hell_no == "string" then
            a.max_uses = tonumber(a.max_uses) or 0
        elseif hell_no ~= "number" then
            a.max_uses = 0
        end
        if a.max_uses < 0 then
            a.max_uses = nil
        end
    end
end

return spell_data
