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

local chinese_languages = {
	["简体中文"] = true,
	["喵体中文"] = true,
	["汪体中文"] = true,
	["完全汉化"] = true,
}

local inf = 1 / 0
local threshold = 10 ^ 10
function format_damage( damage )
	if damage == inf then
		return "i"
	end
	damage = damage * 25
	if not ModSettingGet( "spell_lab_shugged.dummy_target_show_full_damage_number" )
		and ( damage > threshold or -damage > threshold ) then
		return string.format( "%.10e", damage )
	end
	local separator_func = chinese_languages[ GameTextGetTranslatedOrNot( "$current_language" ) ]
	and ten_thousands_separator or thousands_separator
	return separator_func( string.format( "%.2f", damage ) )
end

