local format = {}

local function digit3_sep( value_text )
	local formatted = value_text
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function digit4_sep( value_text )
	local formatted = value_text
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function separator( text )
	return ( is_cur_lang_cn() and digit4_sep or digit3_sep )( text )
end

FORMAT = {
	Floor = 0,
	Round = 1,
	Ceiling = 2
}

local inf = 1 / 0
local threshold = 10 ^ 10
function format.damage( damage, never_use_scientific_notation, result_inf )
	if damage == inf then
		return result_inf or "∞"
	end
	damage = damage * 25
	if not never_use_scientific_notation and ( damage > threshold or -damage > threshold ) then
		return string.format( "%.10e", damage )
	end
	return separator( string.format( "%.2f", damage ) )
end

function format.value( value, decimals, show_sign, format )
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

function format.time( time, digits )
	digits = digits or 2
	return format.value( time / 60, digits, true, FORMAT.Round ) .. " s (" .. GameTextGet( wrap_key( "frames" ), format.value( time, 0 ) ) .. ")"
end

function format.range( min, max )
	if not min or not max then return nil end
	if min ~= max then
		return min .. " - " .. max
	else
		return tostring( min )
	end
end

function format.word_wrap( str, wrap_size )
	if GameTextGetTranslatedOrNot( "$current_language" ) ~= "English" then
		return str
	end
	if wrap_size == nil then wrap_size = 60 end
	local last_space_index = 1
	local last_wrap_index = 0
	for i=1,#str do
		if str:sub(i,i) == " " then
			last_space_index = i
		end
		if str:sub(i,i) == "\n" then
			last_space_index = i
			last_wrap_index = i
		end
		if i - last_wrap_index > wrap_size then
			str = str:sub(1,last_space_index-1) .. "\n" .. str:sub(last_space_index + 1)
			last_wrap_index = i
		end
	end
	return str
end

return format
