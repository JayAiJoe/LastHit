local campaign_control = {}


local nk = require("nakama")


local OpCodes = {
    assign_captain = 1,
    initial_state = 2,
    do_spawn = 3,
    normal_attack = 4,
    next_encounter = 5,
    enemy_action = 6
}


function campaign_control.match_init(_, _)
    local gamestate = {
        presences = {},
        positions = {},
        initiatives = {},
        stats = {},
        names = {},
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
        state.positions[presence.user_id] = 0
        state.initiatives[presence.user_id] = 0
        state.stats[presence.user_id] = {
            ["chp"] = 30,
            ["mhp"] = 30,
            ["atk"] = 5,
            ["def"] = 0
        }
        state.names[presence.user_id] = "User"
    end
    return state
end


function campaign_control.match_leave(_, _, _, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.user_id] = nil
        state.positions[presence.user_id] = nil
        state.initiatives[presence.user_id] = nil
        state.stats[presence.user_id] = nil
        state.names[presence.user_id] = nil
    end
    return state
end


function campaign_control.match_loop(_, dispatcher, _, state, messages)
    for _, message in ipairs(messages) do
        local op_code = message.op_code
        local decoded = nk.json_decode(message.data)
        
        if op_code == OpCodes.assign_captain then
            if host_id == nil then
                captain_id = decoded.id
                current_id = decoded.id
            end
        end
        if op_code == OpCodes.do_spawn then

            local object_ids = {
                {
                    collection = "player_data",
                    key = "position_" .. decoded.nm,
                    user_id = message.sender.user_id
                }
            }

            local objects = nk.storage_read(object_ids)

            local position
            for _, object in ipairs(objects) do
                position = object.value
                if position ~= nil then
                    state.positions[message.sender.user_id] = position
                    break
                end
            end

            if position == nil then
                state.positions[message.sender.user_id] = 0
            end

            state.names[message.sender.user_id] = decoded.nm

            local data = {
                ["pos"] = state.positions,
                ["ini"] = state.initiatives,
                ["stats"] = state.stats,
                ["nms"] = state.names
            }

            local encoded = nk.json_encode(data)
            dispatcher.broadcast_message(OpCodes.initial_state, encoded, {message.sender})

            dispatcher.broadcast_message(OpCodes.do_spawn, message.data)
        end
        if op_code == OpCodes.next_encounter then
            if decoded.id == captain_id then
                dispatcher.broadcast_message(OpCodes.next_encounter, message.data)
            end
        end
        if op_code == OpCodes.normal_attack then
            if decoded.id == current_id then
                dispatcher.broadcast_message(OpCodes.normal_attack, message.data)
            end
        end
        if op_code == OpCodes.enemy_action then
            if decoded.id == captain_id then
                dispatcher.broadcast_message(OpCodes.enemy_action, message.data)
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
