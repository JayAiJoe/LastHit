local campaign_control = {}


local nk = require("nakama")


local OpCodes = {
    assign_captain = 1,
    initial_state = 2,
    do_spawn = 3,
    next_encounter = 4,
    character_action = 5,
    fetch_state = 6,
    add_creature = 7,
    turn_id = 8
}

function campaign_control.match_init(_, _)
    local gamestate = {
        presences = {},
        characters = {},
        captain_id = nil,
	    current_id = nil
    }
    local tickrate = 2
    local label = "Campaign"
    return gamestate, tickrate, label
end


function campaign_control.match_join_attempt(_, _, _, state, presence, _)
    if state.presences[presence.user_id] ~= nil then
        return state, false, "User already logged in."
    end
    return state, true
end


function campaign_control.match_join(_, dispatcher, _, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.user_id] = presence

        local stat_default = {
            initiative = 0,
            max_hp = 30,
            current_hp = 30,
            shields = 0,
            atk = 5,
            armor_class = nil,
            statuses = {}
        }

        local character = {
            position = 0,
            name = "player",
            stats = stat_default,
            creatures = {}
        }

        state.characters[presence.user_id] = character
    end
    return state
end


function campaign_control.match_leave(_, _, _, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.user_id] = nil
        state.characters[presence.user_id] = nil
        if captain_id == presence.user_id then
            captain_id = nil
        end
        if current_id == presence.user_id then
            current_id = nil
        end
    end
    return state
end


function campaign_control.match_loop(_, dispatcher, _, state, messages)
    for _, message in ipairs(messages) do
        local op_code = message.op_code
        local decoded = nk.json_decode(message.data)


        
        if op_code == OpCodes.assign_captain then
            if captain_id == nil then
                captain_id = decoded.id
                current_id = decoded.id
            end
        end
        if op_code == OpCodes.do_spawn then
            state.characters[decoded.id].name = decoded.nm
            local encoded = nk.json_encode(state.characters)

            dispatcher.broadcast_message(OpCodes.initial_state, encoded, {message.sender})
            dispatcher.broadcast_message(OpCodes.do_spawn, message.data)
        end
        if op_code == OpCodes.next_encounter then
            if decoded.id == captain_id then
                dispatcher.broadcast_message(OpCodes.next_encounter, message.data)
            end
        end
        if op_code == OpCodes.character_action then
            if decoded.id == current_id then
                dispatcher.broadcast_message(OpCodes.character_action, message.data)
            end
        end
        if op_code == OpCodes.fetch_state then
            local encoded = nk.json_encode(state)
            dispatcher.broadcast_message(OpCodes.fetch_state, encoded)
        end
        if op_code == OpCodes.add_creature then
            state.characters[decoded.id].creatures[decoded.ind] = decoded.ctr
            dispatcher.broadcast_message(OpCodes.add_creature, message.data)
        end
        if op_code == OpCodes.turn_id then
            if decoded.id == captain_id then
                current_id = decoded.tid
                dispatcher.broadcast_message(OpCodes.turn_id, message.data)
            end
        end
    end
    return state
end


function campaign_control.match_terminate(context, dispatcher, tick, state, grace_seconds)
    return state
end


function campaign_control.match_signal(_, _, _, state, data)
    return state, "signal received: " .. data
end

return campaign_control
