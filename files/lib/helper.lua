function thousands_separator( value_text )
	local formatted = value_text
	local num_separators = 0
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

function ten_thousands_separator( value_text )
	local formatted = value_text
	local num_separators = 0
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

function decimal_format( amount, decimals )
	if decimals == nil then decimals = 0; end
	return thousands_separator( string.format( "%."..decimals.."f", amount ) )
end

function string_split( s, splitter )
	local words = {}
	for word in string.gmatch( s, '([^'..splitter..']+)') do
		table.insert( words, word )
	end
	return words
end

function nexp( value, exponent ) return ( ( math.abs( value ^ 2 ) ) ^ exponent ) / value end

local not_a_gui = GuiCreate()
function center_text( text )
	return GuiGetTextDimensions( not_a_gui, text, 1, 0, "mods/spell_lab_shugged/files/font/font_small_numbers.xml", true ) / 2
end

local zh_cn_languages = {
	["简体中文"] = true,
	["喵体中文"] = true,
	["汪体中文"] = true,
	["完全汉化"] = true,
}

function separator( text )
	return ( zh_cn_languages[ GameTextGetTranslatedOrNot( "$current_language" ) ]
	and ten_thousands_separator or thousands_separator )( text )
end

FORMAT = {
	Floor = 0,
	Round = 1,
	Ceiling = 2
}

local inf = 1 / 0
local threshold = 10 ^ 10
function format_damage( damage, never_use_scientific_notation, result_inf )
	if damage == inf then
		return result_inf or "∞"
	end
	damage = damage * 25
	if not never_use_scientific_notation and ( damage > threshold or -damage > threshold ) then
		return string.format( "%.10e", damage )
	end
	return separator( string.format( "%.2f", damage ) )
end

function format_value( value, decimals, show_sign, format )
	local text = ""
	if value ~= nil then
		if show_sign and value > 0 then
			text = "+"
		end
		local rounder = math.floor
		local value_offset = 0
		if format == FORMAT.Ceiling then
			rounder = math.ceil
		elseif format == FORMAT.Round then
			value_offset = 0.5
		end
		local power = math.pow( 10, decimals )
		text = text .. tostring( rounder( value * power + value_offset ) / power )
	else
		return "missing"
	end
	return text
end

function format_time( time, digits )
	digits = digits or 2
	return format_value( time / 60, digits, true, FORMAT.Round ) .. " s (" .. GameTextGet( wrap_key( "frames" ), format_value( time, 0 ) ) .. ")"
end

function format_range( min, max )
	if not min or not max then return nil end
	if min ~= max then
		return min .. " - " .. max
	else
		return tostring( min )
	end
end