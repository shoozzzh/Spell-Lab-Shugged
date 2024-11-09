local _register_action = register_action
function register_action( ... )
	if not reflecting then
		if ModSettingGet( "spell_lab_shugged.no_recoil" ) then shot_effects.recoil_knockback = 0 end
	end
	_register_action( ... )
end