function thousands_separator( value_text )
	local formatted = value_text
	local num_separators = 0
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
		num_separators = num_separators + 1
	end
	return formatted, num_separators
end

function ten_thousands_separator( value_text )
	local formatted = value_text
	local num_separators = 0
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
		num_separators = num_separators + 1
	end
	return formatted, num_separators
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