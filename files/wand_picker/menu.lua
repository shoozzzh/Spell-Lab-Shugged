local pop = require "pop"
local gui_elems = require "gui.elems"
local text_input = require "pop.text_input"
local format = require "format"
local common_val = require "common_values"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local s2w = require "stat_to_wand"
local tl = require "tinklin"
local wand_utils = require "wand_utils"

---@type wand_utils.wand_stats
local wand_stats = {
    shuffle_deck_when_empty = false,
    actions_per_round = 1,
    capacity = 3,
    fire_rate_wait = 10,
    reload_time = 20,
    mana_max = 100,
    mana_charge_speed = 30,
    spread_degrees = 0,
    speed_multiplier = 1,
}

---@type s2w.wand_look[]
local wand_looks = {}
local wand_look_index_selected = 1
local need_refresh = true -- to init wand_looks with default values

local label_width = 75
local text_input_width = 30
local stat_width = label_width + text_input_width

local wand_sprite_x_offset = stat_width + 60 --[[ +60 is for "f (1.000s)" stuff]]
local wand_sprite_space_width = 60
local wand_sprite_max_scale = 8

local panel_width = wand_sprite_x_offset + wand_sprite_space_width
local space_above_buttons = 5

local button_width = (panel_width - 3) / 3
local button_look_width = wand_sprite_space_width / 2

local int2str = function(value)
    return ("%.0f"):format(value)
end

local tointeger = function(str)
    return math.floor(tonumber(str) or 0)
end

local tonumber_ = function(str)
    return tonumber(str) or 0
end

local allowed_chars = "0123456789.+-e" -- e for "1e10" stuff

---@generic V
---@param field string
---@param formatter (fun(value: V): string)?
---@param parser (fun(str: string): V)?
---@return fun()
local function stat_gui(field, formatter, parser)
    formatter = formatter or int2str
    parser = parser or tointeger

    local object = text_input.wrap(text_input.new(text_input_width, "", allowed_chars), formatter, parser)
    object.text = formatter(parser(object.text))
    return function()
        pop.call_depth_mod(1)

        local changed
        changed, wand_stats[field] = object:show(wand_stats[field])

        need_refresh = need_refresh or changed

        pop.call_depth_mod(-1)
    end
end

local stat_gui_fns = {
    actions_per_round = stat_gui "actions_per_round",
    capacity = stat_gui "capacity",

    fire_rate_wait = stat_gui "fire_rate_wait",
    reload_time = stat_gui "reload_time",

    mana_charge_speed = stat_gui "mana_charge_speed",
    mana_max = stat_gui "mana_max",

    spread_degrees = stat_gui(
        "spread_degrees",
        function(value) return format.decimal(value, 1) end,
        tonumber_
    ),
    speed_multiplier = stat_gui(
        "speed_multiplier",
        function(value) return format.decimal(value, 4) end,
        tonumber_
    ),
}

local picker = {}
picker.menu = function()
    if need_refresh then
        local stats = {
            fire_rate_wait = wand_stats.fire_rate_wait,
            actions_per_round = wand_stats.actions_per_round,
            deck_capacity = wand_stats.capacity,
            shuffle_deck_when_empty = wand_stats.shuffle_deck_when_empty,
            reload_time = wand_stats.reload_time,
            spread_degrees = wand_stats.spread_degrees,
        }
        if common_val.held_wand then
            stats.deck_capacity = stats.deck_capacity + wand_utils.get_ac_num(common_val.held_wand)
        end
        wand_looks = s2w(stats)
        need_refresh = false
    end

    local panel_height = pop.text_line_height * 9 + space_above_buttons + pop.text_line_height - 2

    local wand_look = wand_looks[wand_look_index_selected]
    local wand_sprite_space_height = panel_height - pop.text_line_height
    if #wand_looks > 1 then
        wand_sprite_space_height = wand_sprite_space_height - pop.text_line_height
    end
    local wand_sprite_scale
    do
        local wand_sprite_raw_width, wand_sprite_raw_height = pop.measure_image(wand_look.file)
        -- rotate by -pi/2, so width and height are transformed
        local width_limited = wand_sprite_space_width / wand_sprite_raw_height
        local height_limited = wand_sprite_space_height / wand_sprite_raw_width
        wand_sprite_scale = math.min(width_limited, height_limited, wand_sprite_max_scale)
    end
    local wand_sprite_width, wand_sprite_height = pop.measure_image(wand_look.file, wand_sprite_scale)

    pop.pos.push(640 * 0.05, 360 * 0.24)

    pop.image_9piece("data/ui_gfx/decorations/9piece0_gray.png", panel_width, panel_height, { margin = 2 })

    if pop.pos.push(0, 0) then
        local layout = pop.layout_stack(0, pop.text_line_height)

        layout:next(function()
            pop.text "$inventory_shuffle"
            pop.pos.push(label_width, 0)

            local value = wand_stats.shuffle_deck_when_empty

            local changed = gui_elems.better_button_text(value and "$menu_no" or "$menu_yes", text_input_width)
            wand_stats.shuffle_deck_when_empty = changed ~= value
            need_refresh = need_refresh or changed

            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_actionspercast"

            pop.pos.push(label_width, 0)
            stat_gui_fns.actions_per_round()
            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_capacity"

            pop.pos.push(label_width, 0)
            stat_gui_fns.capacity()
            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_castdelay"
            pop.pos.push(label_width, 0)

            stat_gui_fns.fire_rate_wait()

            pop.pos.push(text_input_width, 0)
            pop.text(tr.general.frames:text "" ..
                (" (%s s)"):format(format.decimal(wand_stats.fire_rate_wait / 60, 3)))
            pop.pos.pop()

            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_rechargetime"
            pop.pos.push(label_width, 0)

            stat_gui_fns.reload_time()

            pop.pos.push(text_input_width, 0)
            pop.text(tr.general.frames:text "" ..
                (" (%s s)"):format(format.decimal(wand_stats.reload_time / 60, 3)))
            pop.pos.pop()

            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_manachargespeed"

            pop.pos.push(label_width, 0)
            stat_gui_fns.mana_charge_speed()
            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_manamax"

            pop.pos.push(label_width, 0)
            stat_gui_fns.mana_max()
            pop.pos.pop()
        end)

        layout:next(function()
            pop.text "$inventory_spread"
            pop.pos.push(label_width, 0)

            stat_gui_fns.spread_degrees()

            pop.pos.push(text_input_width, 0)
            pop.text(tr.action_metadata.degrees:text "")
            pop.pos.pop()

            pop.pos.pop()
        end)

        layout:next(function()
            pop.text(tr.action_metadata.speed_multiplier:key())
            pop.pos.push(label_width, 0)

            stat_gui_fns.speed_multiplier()

            pop.pos.push(text_input_width, 0)
            pop.text " x"
            pop.pos.pop()

            pop.pos.pop()
        end)

        layout:shift(0, space_above_buttons)

        layout:next(function()
            local layout = pop.layout_stack(button_width, 0)

            layout:next(function()
                if common_val.held_wand then
                    if gui_elems.better_button_text(module_tr.copy_held_wand:key(), button_width, 1) then
                        wand_stats = wand_utils.get_owned_stats(wand_utils.wand_wrap(common_val.held_wand))
                        need_refresh = true
                    end
                end
            end)
            layout:next(function()
                if common_val.held_wand then
                    if gui_elems.better_button_text(module_tr.update_held_wand:key(), button_width, 1) then
                        wand_utils.apply_stats(wand_utils.wand_wrap(common_val.held_wand), wand_stats)
                    end
                end
            end)
            layout:next(function()
                if gui_elems.better_button_text(module_tr.spawn_wand:key(), button_width, 1) then
                    local wand = tl.entity_load("data/entities/items/wand_level_01.xml",
                        unpack(common_val.world_dest_pos))
                    wand_utils.clear(wand)
                    wand_utils.apply_stats(wand_utils.wand_wrap(wand), wand_stats)
                end
            end)
        end)

        pop.pos.pop()
    end

    if pop.pos.push(wand_sprite_x_offset, 0) then
        local layout = pop.layout_hwrap(button_look_width, pop.text_line_height, 2)
        if #wand_looks > 1 then
            layout:next(function()
                if wand_look_index_selected == 1 then
                    pop.option_next "DrawSemiTransparent" "NonInteractive"
                end
                if gui_elems.better_button_text("<", button_look_width, 1) then
                    wand_look_index_selected = wand_look_index_selected - 1
                end
            end)

            layout:next(function()
                if wand_look_index_selected == #wand_looks then
                    pop.option_next "DrawSemiTransparent" "NonInteractive"
                end
                if gui_elems.better_button_text(">", button_look_width, 1) then
                    wand_look_index_selected = wand_look_index_selected + 1
                end
            end)
        end
        -- rotate by -pi/2, so width and height are transformed
        local temp_x = wand_sprite_space_width / 2 - wand_sprite_height / 2
        local temp_y = wand_sprite_space_height / 2 + wand_sprite_width / 2
        if #wand_looks > 1 then
            temp_y = temp_y + pop.text_line_height
        end
        pop.pos.push(temp_x, temp_y)
        pop.image(wand_look.file, { scale = wand_sprite_scale, rotation = -math.pi / 2 })
        pop.pos.pop()

        pop.pos.pop()
    end

    pop.pos.pop()
end

picker.buttons = function() end

return picker
