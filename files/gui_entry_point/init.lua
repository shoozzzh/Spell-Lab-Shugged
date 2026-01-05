---@type callbacks
local callbacks = {}

function callbacks.OnPlayerSpawned( player_id )
	GlobalsSetValue( "mod_button_tr_width", "0" )
end

function callbacks.OnWorldInitialized()
	local mod_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_width", "0" ) )
	GlobalsSetValue( "spell_lab_shugged_mod_button_reservation", tostring( mod_button_reservation ) )
	GlobalsSetValue( "mod_button_tr_width", tostring( mod_button_reservation + 15 ) )
end

function callbacks.OnWorldPostUpdate()
	GlobalsSetValue( "mod_button_tr_current", "0" )
end

return callbacks
