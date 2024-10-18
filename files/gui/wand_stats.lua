return {
	{
		stat = "shuffle_deck_when_empty",
		label = "$inventory_shuffle",
		default = 0, current = 0,
		min = 0, max = 1,
		formatter = " ",
		value_callback = function( value )
			if type( value ) == "boolean" then
				if value then
					value = 1
				else
					value = 0
				end
			end
			return math.floor( value + 0.5 )
		end,
		text_callback = function( value )
			return GameTextGetTranslatedOrNot( "$menu_" .. ( value == 0 and "no" or "yes" ) ) end,
		buttons_precise_mode = {
			{
				text = function( value )
					return "[" .. GameTextGetTranslatedOrNot( "$menu_yes" ) .. "]"
				end,
				value = 1,
			},
			{
				text = function( value )
					return "[" .. GameTextGetTranslatedOrNot( "$menu_no" ) .. "]"
				end,
				value = -1,
			},
		},
	},
	{
		stat = "actions_per_round",
		label = "$inventory_actionspercast",
		default = 1, current = 1,
		min = 1, max = 26,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return tostring( value ) end,
		buttons_precise_mode = {
			{
				text = "[1]",
				value = 1,
			},
			{
				text = "[5]",
				value = 5,
			},
			{
				text = "[25]",
				value = 25,
			},
		},
	},   
	{
		stat = "fire_rate_wait",
		label = "$inventory_castdelay",
		default = 10, current = 10,
		min = -21, max = 240,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return ( math.floor( value / 60 * 100 + 0.5 ) / 100 ) .. " s ("..math.floor(value + 0.5).."f)" end,
		buttons_precise_mode = {
			{
				text = "[1f]",
				value = 1,
			},
			{
				text = "[5f]",
				value = 5,
			},
			{
				text = "[30f]",
				value = 30,
			},
		},
	},
	{
		stat = "reload_time",
		label = "$inventory_rechargetime",
		default = 20, current = 20,
		min = -21, max = 240,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return ( math.floor( value / 60 * 100 + 0.5 ) / 100 ) .. " s ("..math.floor(value + 0.5).."f)" end,
		buttons_precise_mode = {
			{
				text = "[1f]",
				value = 1,
			},
			{
				text = "[5f]",
				value = 5,
			},
			{
				text = "[30f]",
				value = 30,
			},
		},
	},
	{
		stat = "mana_max",
		label = "$inventory_manamax",
		default = 100, current = 100,
		min = 0, max = 5000,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return tostring( value ) end,
		buttons_precise_mode = {
			{
				text = "[1]",
				value = 1,
			},
			{
				text = "[10]",
				value = 10,
			},
			{
				text = "[100]",
				value = 100,
			},
			{
				text = "[1000]",
				value = 1000,
			},
		},
	},
	{
		stat = "mana_charge_speed",
		label = "$inventory_manachargespeed",
		default = 30, current = 30,
		min = 0, max = 5000,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return tostring( value ) end,
		buttons_precise_mode = {
			{
				text = "[1]",
				value = 1,
			},
			{
				text = "[10]",
				value = 10,
			},
			{
				text = "[100]",
				value = 100,
			},
			{
				text = "[1000]",
				value = 1000,
			},
		},
	},
	{
		stat = "capacity",
		label = "$inventory_capacity",
		default = 3, current = 3,
		min = 1, max = 26,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return tostring( value ) end,
		buttons_precise_mode = {
			{
				text = "[1]",
				value = 1,
			},
			{
				text = "[5]",
				value = 5,
			},
			{
				text = "[25]",
				value = 25,
			},
		},
	},
	{
		stat = "spread_degrees",
		label = "$inventory_spread",
		default = 0, current = 0,
		min = -30, max = 30,
		formatter = " ",
		value_callback = function( value ) return math.floor( value + 0.5 ) end,
		text_callback = function( value ) return GameTextGet( "$inventory_degrees", math.floor( value * 10 ) / 10 ) end,
		buttons_precise_mode = {
			{
				text = function() return "[" .. GameTextGet( "$inventory_degrees", 1 ) .. "]" end,
				value = 1,
			},
			{
				text = function() return "[" .. GameTextGet( "$inventory_degrees", 5 ) .. "]" end,
				value = 5,
			},
			{
				text = function() return "[" .. GameTextGet( "$inventory_degrees", 30 ) .. "]" end,
				value = 30,
			},
		},
	},
	{
		stat = "speed_multiplier",
		label = "$spell_lab_shugged_speed_multiplier",
		default = 1.0, current = 1.0,
		min = 0.0, max = 2.0,
		formatter = " ",
		value_callback = function( value ) return math.floor( value * 1000 ) / 1000 end,
		text_callback = function( value ) return ( math.floor( value * 1000 ) / 1000 .. " x" ) end,
		buttons_precise_mode = {
			{
				text = "[0.001 x]",
				value = 0.001,
			},
			{
				text = "[0.01 x]",
				value = 0.01,
			},
			{
				text = "[0.1 x]",
				value = 0.1,
			},
		},
	}
}