local __draw_actions_for_shot = _draw_actions_for_shot
function _draw_actions_for_shot(...)
    do
        local entity_id = GetUpdatedEntityID()
        if not EntityHasTag(entity_id, "player_unit") then goto nevermind end
        if not ModSettingGet "%MODULE_FULL_ID%.enabled" then goto nevermind end
        GamePrint "$%MODULE_FULL_ID%.info"
        return
    end

    ::nevermind::
    __draw_actions_for_shot(...)
end

local __play_permanent_card = _play_permanent_card
function _play_permanent_card(...)
    do
        local entity_id = GetUpdatedEntityID()
        if not EntityHasTag(entity_id, "player_unit") then goto nevermind end
        if not ModSettingGet "%MODULE_FULL_ID%.enabled" then goto nevermind end
        return
    end

    ::nevermind::
    __play_permanent_card(...)
end
