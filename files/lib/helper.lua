function get_entity_held_or_random_wand( entity, or_random )
    if or_random == nil then or_random = true end
    local base_wand = nil
    local wands
    local children = EntityGetAllChildren( entity ) or {}
    for key,child in pairs( children ) do
        if EntityGetName( child ) == "inventory_quick" then
            wands = EntityGetAllChildren( child, "wand" )
            break
        end
    end
    if wands and #wands > 0 then
        local inventory2 = EntityGetFirstComponent( entity, "Inventory2Component" )
        local active_item = ComponentGetValue2( inventory2, "mActiveItem" )
        for _,wand in pairs( wands ) do
            if wand == active_item then
                base_wand = wand
                break
            end
        end
        if base_wand == nil and or_random then
            SetRandomSeed( EntityGetTransform( entity ) )
            base_wand =  Random( 1, #wands )
        end
    end
    return base_wand
end

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