---@class pop.keyboard_focus
local keyboard_focus = {}

local tag_freeze_effect = "pop.keyboard_focus.player_controls_freezer"

local function freeze_entity(entity_id)
    local freeze_effect = EntityCreateNew()
    EntityAddTag(freeze_effect, tag_freeze_effect)
    EntityAddTag(freeze_effect, "spell_lab_shugged.no_annoying_effects.bypass")
    EntityAddComponent2(freeze_effect, "InheritTransformComponent")
    EntityAddComponent2(freeze_effect, "GameEffectComponent", {
        frames = -1,
        disable_movement = true,
        effect = "FROZEN",
    })
    EntityAddChild(entity_id, freeze_effect)
end

local function freeze_player_controls()
    for _, player_id in ipairs(EntityGetWithTag "player_unit" or {}) do
        freeze_entity(player_id)
    end
end

local function unfreeze_player_controls()
    for _, effect in ipairs(EntityGetWithTag(tag_freeze_effect)) do
        local effect_comp = EntityGetFirstComponentIncludingDisabled(effect, "GameEffectComponent")
        ComponentSetValue2(effect_comp, "frames", 1)
    end
end

-- expose this, to make hooks possible
keyboard_focus.default_focusee = {
    on_gain_focus = function()
        freeze_player_controls()
    end,
    on_lose_focus = function()
        unfreeze_player_controls()
    end,
}

---@type pop.keyboard_focus.focusee
local cur_focus = keyboard_focus.default_focusee

---@class pop.keyboard_focus.focusee
---@field on_gain_focus fun()?
---@field on_lose_focus fun()?
---@field focused_update fun()?


---@param f fun()?
local function call_if_present(f)
    if f then return f() end
end

---@param from pop.keyboard_focus.focusee
---@param to pop.keyboard_focus.focusee
local function change_focus(from, to)
    call_if_present(from.on_lose_focus)
    call_if_present(to.on_gain_focus)

    cur_focus = from
end

---@param focusee pop.keyboard_focus.focusee
---@param focused boolean
---@return boolean changed
function keyboard_focus.set(focusee, focused)
    if focused then
        if cur_focus == focusee then return false end

        change_focus(cur_focus, focusee)
        return true
    else
        if cur_focus ~= focusee then return false end

        change_focus(cur_focus, keyboard_focus.default_focusee)
        return true
    end
end

function keyboard_focus.is_on(focusable)
    return cur_focus == focusable
end

function keyboard_focus.update()
    call_if_present(cur_focus.focused_update)
end

return keyboard_focus
