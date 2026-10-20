---@class gui.elems
local gui_elems = {}

local pop = require "pop"
local settings = require "mod_settings"
local spell_box = require "spell_box"
local mutils = require "misc_utils"
local tr = require "tr"
local tr_utils = require "tr_utils"
local format = require "format"
local spell_data = require "spell_data"

local color_dim = { r = 127, g = 127, b = 127, a = 255 }
local color_soft = { r = 207, g = 207, b = 207, a = 255 }
local color_lav_blue = { r = 127, g = 127, b = 255, a = 255 }

function gui_elems.text_dim(text)
    pop.text(text, { color = color_dim })
end

function gui_elems.text_soft(text)
    pop.text(text, { color = color_soft })
end

function gui_elems.text_lav_blue(text)
    pop.text(text, { color = color_lav_blue })
end

gui_elems.lhs_table_width = 174
gui_elems.lhs_table_max_height = 160
gui_elems.lhs_table_min_height = 20
gui_elems.lhs_table_row_size = 8
gui_elems.lhs_table_cell_size = { 22, 22 }
gui_elems.lhs_table_pos = { 640 * 0.05, 360 * 0.16 }

---@generic C
---@param cells C[]
---@param cell_gui_fn fun(cell: C)
---@param height number?
---@return number
---@return number
function gui_elems.lhs_table(cells, cell_gui_fn, height)
    local row_size = gui_elems.lhs_table_row_size
    local cell_width, cell_height = unpack(gui_elems.lhs_table_cell_size)
    local width = gui_elems.lhs_table_width
    height = height or math.floor(#cells / row_size) * cell_height
    height = math.min(height, gui_elems.lhs_table_max_height)
    height = math.max(height, gui_elems.lhs_table_min_height)

    pop.pos.push(unpack(gui_elems.lhs_table_pos))
    pop.scroll_box_begin(width, height)
    if pop.prev_mouse_inside(2) then
        pop.block_mousewheel()
    end

    gui_elems.grid_cells(cells, cell_gui_fn, cell_width, cell_height, row_size)

    pop.scroll_box_end()
    pop.pos.pop()

    return width, height
end

---@generic C
---@param cells C[]
---@param cell_gui_fn fun(cell: C)
---@param cell_width number
---@param cell_height number
---@param row_size integer
function gui_elems.grid_cells(cells, cell_gui_fn, cell_width, cell_height, row_size)
    if #cells == 0 then
        pop.text(tr.general.scroll_table_nothing:key())
        return
    end

    local layout = pop.layout_hwrap(cell_width, cell_height, row_size)
    for _, cell in ipairs(cells) do
        layout:next(function() cell_gui_fn(cell) end)
    end
end

---@param sprite_filename string
---@param key string
---@param name string
---@vararg string desc_lines
---@return boolean left_click
---@return boolean right_click
function gui_elems.button_setting_toggle(sprite_filename, key, name, ...)
    name = tr_utils.maybe(name)
    local value = settings.get(key) == true
    if not value then
        pop.option_next "DrawSemiTransparent"
    end

    local left_click, right_click = pop.button(sprite_filename)
    if left_click then
        gui_elems.sound_button_clicked()
        value = not value
        settings.set(key, value)
    end

    pop.tooltip((value and tr.general.option_enable or tr.general.option_disable):text(name), ...)
    return left_click, right_click
end

---@param selected boolean
---@param action_type integer
---@param sprite_file string
---@return boolean left_click
---@return boolean right_click
function gui_elems.button_action(selected, action_type, sprite_file)
    pop.pos.push(2, 2)
    local hovered = pop.hoverable_space(16, 16)
    pop.pos.pop()

    spell_box.show(action_type, selected, hovered)

    local width, height = mutils.get_image_size(sprite_file)
    pop.pos.push(20 / 2 - width / 2, 20 / 2 - height / 2)
    pop.image(sprite_file)
    pop.pos.pop()

    pop.pos.push(2, 2)
    local left_click, right_click = pop.button "%MODULE_PATH%/transparent_16x16.png"
    pop.pos.pop()

    if left_click or right_click then
        gui_elems.sound_action_button_clicked()
    end

    return left_click, right_click
end

---@class fake_action_data
---@field id string
---@field sprite string
---@field name string
---@field desc string
---@field type_text string
---@field type_spellbox integer
---@field uses_remaining integer
---@field properties table

-- function gui_elem.button_fake_action(action_type, action_sprite, name, id, desc, type, semi_transparent, uses_remaining,
--                                      properties)

---@param data fake_action_data
---@param semi_transparent boolean?
---@return boolean
---@return boolean
function gui_elems.button_fake_action(data, semi_transparent)
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

        if data.id then
            layout:next(function() gui_elems.text_dim(data.id) end)
        end

        if data.type_text then
            layout:next(function()
                gui_elems.text_lav_blue(data.type_text)
            end)
        end

        layout:next(function() pop.text(data.desc) end)

        if data.properties and #data.properties > 0 then
            layout:shift(0, 5)
            gui_elems.metadata_lines(layout, data.properties)
        end
    end)

    if semi_transparent then
        pop.option_next "DrawSemiTransparent"
    end
    local sprite_width, sprite_height = mutils.get_image_size(data.sprite)
    pop.pos.push((20 - sprite_width) / 2, (20 - sprite_height) / 2)
    pop.image(data.sprite)
    pop.pos.pop()

    if data.uses_remaining then
        gui_elems.text_uses(data.uses_remaining)
    end

    return left_click, right_click
end

function gui_elems.icon_ac()
    pop.image "data/ui_gfx/inventory/icon_gun_permanent_actions.png"
end

--TODO: take the pos shifting outta this
---@param flag string?
function gui_elems.icon_unlock_status(x, y, flag)
    pop.pos.push(14, -2)
    if not flag then
        return
    elseif HasFlagPersistent(flag) then
        if settings.get "show_icon_unlocked" then
            pop.image("%MODULE_PATH%/unlocked.png", { alpha = 0.3 })
        end
    else
        pop.image "%MODULE_PATH%/locked.png"
    end
    pop.pos.pop()
end

---@param uses integer
---@param scale number?
function gui_elems.text_uses(uses, scale)
    if tonumber(uses) < 0 then return end

    scale = scale or 1
    pop.text_pixel(tostring(uses), { font = "data/fonts/font_pixel_noshadow.xml", scale = scale })
end

---@param name string
---@param value any
function gui_elems.attr_line(name, value)
    pop.text(name, { color = { r = 0.811 * 256 - 1, g = 0.811 * 256 - 1, b = 0.811 * 256 - 1, a = 255 } })
    pop.pos.push(72, 0)
    pop.text(tostring(value), { color = { r = 255, g = 191, b = 127, a = 255 } })
    pop.pos.pop()
end

---@param layout pop.layout
---@param lines string[]
function gui_elems.metadata_lines(layout, lines)
    for _, p in ipairs(lines) do
        layout:next(function() gui_elems.attr_line(p[1], p[2]) end)
    end
end

---@param layout pop.layout
---@param action action
---@param metadata action_metadata
function gui_elems.action_info_least(layout, action, metadata)
    layout:next(function() gui_elems.text_dim(action.id) end)
    layout:next(function()
        gui_elems.text_lav_blue(tr_utils.get(spell_data.type_text[action.type]))
    end)
end

---@param layout pop.layout
---@param action action
---@param metadata action_metadata
function gui_elems.action_info_verbose(layout, action, metadata)
    local c_lines = spell_data.metadata.shot_state_lines(metadata.c)
    local projectiles_lines, num_proj_lines = spell_data.metadata.proj_lines(metadata.projectiles)

    local title = tr_utils.maybe(action.name)
    if action.max_uses then
        title = title .. ("(" .. tostring(action.max_uses) .. ")")
    end
    layout:next(function() pop.text(title) end)
    layout:next(function() gui_elems.text_dim(title) end)

    layout:next(function()
        gui_elems.text_lav_blue(tr_utils.get(spell_data.type_text[action.type]))
    end)
    layout:next(function()
        pop.text(format.word_wrap(tr_utils.get(action.description)))
    end)

    if not metadata then return end

    layout:shift(5, 0)

    if metadata.projectiles then
        layout:next(function() pop.text(tr.action_metadata.spell_data:key()) end)
    end

    gui_elems.metadata_lines(layout, c_lines)

    local only_one_proj = #projectiles_lines == 1
    for proj_index, proj_lines in ipairs(projectiles_lines) do
        layout:next(function()
            if only_one_proj then
                pop.text(tr.action_metadata.proj_data:key())
            else
                pop.text(tr.action_metadata.proj_nth_data:text(proj_index))
            end
        end)
        gui_elems.metadata_lines(layout, proj_lines)
    end
end

local function image_small_action(id, uses_remaining)
    pop.pos.push(-1, -1)
    pop.image("mods/spell_lab_shugged/files/spell_box/goki/spell_box_0.png", { scale = 0.5 })
    pop.pos.pop()

    if id and id ~= "" then
        local this_action_data = spell_data.action_data[id]
        local sprite = (this_action_data and this_action_data.sprite) and this_action_data.sprite or
            "data/ui_gfx/gun_actions/_unidentified.png"
        pop.image(sprite, { scale = 0.5 })
    end

    pop.pos.push(-1, -1)
    gui_elems.text_uses(uses_remaining, 0.5)
    pop.pos.pop()
end

function gui_elems.wand_all_actions_preview(layout, all_actions)
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

function gui_elems.line_of_buttons(button_fns)
    pop.pos.push(-22 * #button_fns / 2 + 2, 0)
    local layout = pop.layout_stack(22, 0)
    for _, f in ipairs(button_fns) do
        layout:next(function() f() end)
    end
    pop.pos.pop()
end

function gui_elems.sound_button_clicked()
    if settings.get "general.button_click_sound" then
        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
    end
end

function gui_elems.sound_action_button_clicked()
    if settings.get "general.action_button_click_sound" then
        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
    end
end

return gui_elems
