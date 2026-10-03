local gui_elem = {}

local pop = require "pop"
local mod_setting = require "mod_setting"
local spell_box = require "spell_box"
local utils = require "misc_utils"
local format = require "format"

local color_dim = { r = 127, g = 127, b = 127, a = 255 }
local color_soft = { r = 207, g = 207, b = 207, a = 255 }
local color_lavender = { r = 127, g = 127, b = 255, a = 255 }

function gui_elem.text_dim(text)
    pop.text(text, { color = color_dim })
end

function gui_elem.text_soft(text)
    pop.text(text, { color = color_soft })
end

function gui_elem.text_lavender(text)
    pop.text(text, { color = color_lavender })
end

---@generic C
---@param cells C[]
---@param cell_gui_fn fun(cell: C)
---@param cell_width number
---@param cell_height number
---@param row_size integer
---@return unknown
---@return unknown
function gui_elem.scroll_table(cells, cell_gui_fn, cell_width, cell_height, row_size)
    local width = cell_width * row_size - 2
    local height = math.min(math.floor(#cells / row_size) * cell_height)

    pop.scroll_box_begin(width, height)

    local layout = pop.layout_hwrap(cell_width, cell_height, row_size)
    for _, cell in ipairs(cells) do
        layout:next(function()
            cell_gui_fn(cell)
        end)
    end

    pop.scroll_box_end()

    return width, height
end

---@param sprite_filename string
---@param key string
---@param name string?
---@param description string?
---@return boolean left_click
---@return boolean right_click
function gui_elem.button_setting_toggle(sprite_filename, key, name, description)
    local value = mod_setting.get(key) == true
    if not value then
        pop.option_next "DrawSemiTransparent"
    end

    local left_click, right_click = pop.button(sprite_filename)
    if left_click then
        gui_elem.sound_button_clicked()
        value = not value
        mod_setting.set(key, value)
    end
    pop.tooltip(utils.tr_text(value and "enable" or "disable") .. GameTextGetTranslatedOrNot(name or utils.tr_key(key)),
        description)
    return left_click, right_click
end

function gui_elem.button_action(selected, action_type, sprite_file)
    pop.pos.push(2, 2)
    local hovered = pop.hoverable_space(16, 16)
    pop.pos.pop()

    spell_box.show(action_type, selected, hovered)

    local width, height = utils.get_image_size(sprite_file)
    pop.pos.next(20 / 2 - width / 2, 20 / 2 - height / 2)
    pop.image(sprite_file)

    pop.pos.push(2, 2)
    local left_click, right_click = pop.button "%MODULE_PATH%/transparent_16x16.png"
    pop.pos.pop()

    if left_click or right_click then
        gui_elem.sound_action_button_clicked()
    end

    return left_click, right_click
end

---@class fake_action_data
---@field sprite string
---@field name string
---@field fake_id string
---@field desc string
---@field type_text string
---@field type_spellbox integer
---@field uses_remaining integer
---@field properties table

-- function gui_elem.button_fake_action(action_type, action_sprite, name, id, desc, type, semi_transparent, uses_remaining,
--                                      properties)

---@param data fake_action_data
---@param semi_transparent boolean
---@return boolean
---@return boolean
function gui_elem.button_fake_action(data, semi_transparent)
    pop.pos.push(2, 2)
    local hovered = pop.hoverable_space(16, 16)
    pop.pos.pop()

    if semi_transparent then
        pop.option_next "DrawSemiTransparent"
    end
    spell_box.show(data.type_spellbox, false, hovered)

    pop.pos.push(2, 2)
    local left_click, right_click = pop.button "%MODULE_PATH%/transparent_16x16.png"
    pop.pos.pop()

    pop.tooltip_custom(2, -2)(function()
        local layout = pop.layout_stack(0, pop.text_line_height)

        layout:next(function() pop.text(data.name) end)

        if data.fake_id then
            layout:next(function() gui_elem.text_dim(data.fake_id) end)
        end

        if data.type_text then
            layout:next(function()
                gui_elem.text_lavender(data.type_text)
            end)
        end

        layout:next(function() pop.text(data.desc) end)

        if data.properties and #data.properties > 0 then
            layout:shift(0, 5)
            gui_elem.metadata_lines(layout, data.properties)
        end
    end)

    if semi_transparent then
        pop.option_next "DrawSemiTransparent"
    end
    local sprite_width, sprite_height = utils.get_image_size(data.sprite)
    pop.pos.push((20 - sprite_width) / 2, (20 - sprite_height) / 2)
    pop.image(data.sprite)
    pop.pos.pop()

    if data.uses_remaining then
        gui_elem.text_uses(data.uses_remaining)
    end

    return left_click, right_click
end

function gui_elem.icon_ac()
    pop.image "data/ui_gfx/inventory/icon_gun_permanent_actions.png"
end

--TODO: take the pos shifting outta this
---@param flag string?
function gui_elem.icon_unlock_status(x, y, flag)
    pop.pos.push(14, -2)
    if not flag then
        return
    elseif HasFlagPersistent(flag) then
        if mod_setting.get "show_icon_unlocked" then
            pop.image("%MODULE_PATH%/unlocked.png", { alpha = 0.3 })
        end
    else
        pop.image "%MODULE_PATH%/locked.png"
    end
    pop.pos.pop()
end

---@param uses integer
---@param scale number?
function gui_elem.text_uses(uses, scale)
    if tonumber(uses) < 0 then return end

    scale = scale or 1
    pop.text_pixel(tostring(uses), { font = "data/fonts/font_pixel_noshadow.xml", scale = scale })
end

---@param name string
---@param value any
function gui_elem.attr_line(name, value)
    pop.text(name, { color = { r = 0.811 * 256 - 1, g = 0.811 * 256 - 1, b = 0.811 * 256 - 1, a = 255 } })
    pop.pos.push(72, 0)
    pop.text(tostring(value), { color = { r = 255, g = 191, b = 127, a = 255 } })
    pop.pos.pop()
end

---@param layout pop.layout
---@param lines string[]
function gui_elem.metadata_lines(layout, lines)
    for _, p in ipairs(lines) do
        layout:next(function() gui_elem.attr_line(p[1], p[2]) end)
    end
end

---@param layout pop.layout
---@param this_action_data any
---@param this_action_metadata any
function gui_elem.action_info_least(layout, this_action_data, this_action_metadata)
    layout:next(function() gui_elem.text_dim(this_action_data.id) end)
    layout:next(function()
        gui_elem.text_lavender(GameTextGetTranslatedOrNot(type_text[this_action_data.type]))
    end)
end

---@param layout pop.layout
---@param this_action_data any
---@param this_action_metadata any
function gui_elem.action_info_verbose(layout, this_action_data, this_action_metadata)
    local c_lines = c_metadata_to_lines(this_action_metadata.c)
    local projectiles_lines, num_proj_lines = proj_metadata_to_lines(this_action_metadata.projectiles)

    local title = GameTextGetTranslatedOrNot(this_action_data.name)
    if this_action_data.max_uses then
        title = title .. ("(" .. tostring(this_action_data.max_uses) .. ")")
    end
    layout:next(function() pop.text(title) end)
    layout:next(function() gui_elem.text_dim(title) end)

    layout:next(function()
        gui_elem.text_lavender(GameTextGetTranslatedOrNot(type_text[this_action_data.type]))
    end)
    layout:next(function()
        pop.text(format.word_wrap(GameTextGetTranslatedOrNot(this_action_data.description)))
    end)

    if not this_action_metadata then return end

    layout:shift(5, 0)

    if this_action_metadata.projectiles then
        layout:next(function() pop.text(utils.tr_key "spell_data") end)
    end

    gui_elem.metadata_lines(layout, c_lines)

    local only_one_proj = #projectiles_lines == 1
    for proj_index, proj_lines in ipairs(projectiles_lines) do
        layout:next(function()
            if only_one_proj then
                pop.text(utils.tr_key "projectile_data")
            else
                pop.text(GameTextGet(utils.tr_key "projectile_nth_data", tostring(proj_index)))
            end
        end)
        gui_elem.metadata_lines(layout, proj_lines)
    end
end

local function image_small_action(action_id, uses_remaining)
    pop.pos.push(-1, -1)
    pop.image("mods/spell_lab_shugged/files/spell_box/goki/spell_box_0.png", { scale = 0.5 })
    pop.pos.pop()

    if action_id and action_id ~= "" then
        local this_action_data = action_data[action_id]
        local sprite = (this_action_data and this_action_data.sprite) and this_action_data.sprite or
            "data/ui_gfx/gun_actions/_unidentified.png"
        pop.image(sprite, { scale = 0.5 })
    end

    pop.pos.push(-1, -1)
    gui_elem.text_uses(uses_remaining, 0.5)
    pop.pos.pop()
end

function gui_elem.wand_all_actions_preview(layout, all_actions)
    local common_actions = {}
    local permanent_actions = {}
    local max_x = 0
    for _, a in ipairs(all_actions) do
        if a.permanent then
            table.insert(permanent_actions, a.action_id)
        else
            if a.x ~= 0 then
                common_actions[a.x + 1] = { a.action_id, a.uses_remaining }
                max_x = math.max(max_x, a.x + 1)
            else
                common_actions[max_x + 1] = { a.action_id, a.uses_remaining }
                max_x = max_x + 1
            end
        end
    end
    if #permanent_actions ~= 0 then
        layout:next(function()
            local layout = pop.layout_stack(0, 12)
            for _, permanent_action in pairs(permanent_actions) do
                layout:next(function() image_small_action(permanent_action) end)
            end
        end)
        layout:shift(0, 1)
    end
    if max_x > 0 then
        layout:next(function()
            local actions_per_row = 26
            local layout = pop.layout_hwrap(12, 12, actions_per_row)
            for i = 1, max_x do
                layout:next(function()
                    image_small_action(unpack(common_actions[i] or {}))
                end)
            end
        end)
    end
end

function gui_elem.sound_button_clicked()
    if mod_setting.get "button_click_sound" then
        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
    end
end

function gui_elem.sound_action_button_clicked()
    if mod_setting.get "action_button_click_sound" then
        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
    end
end

return gui_elem
