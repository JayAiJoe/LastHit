extends Node

enum OpCodes {
	INITIAL_STATE = 1,
	DO_SPAWN = 2,
	NORMAL_ATTACK = 3
}

const KEY := "last_hit"

signal presences_changed
signal chat_message_received(username, text)
signal normal_attack(target, attacker, dice_value)
signal initial_state_received(positions, initiatives, stats, names)
signal character_spawned(id, name)

var _client := Nakama.create_client(KEY, "127.0.0.1", 7350, "http")
var _socket: NakamaSocket setget _no_set
var _exception_handler := ExceptionHandler.new()
var _authenticator := Authenticator.new(_client, _exception_handler)
var _storage_worker: StorageWorker

var error_message := "" setget _no_set, _get_error_message
var presences := {} setget _no_set
var _campaign_id: String setget _no_set
var _channel_id: String setget _no_set

func _no_set(_value) -> void:
	pass

func _get_error_message() -> String:
	return _exception_handler.error_message

func get_user_id() -> String:
	if _authenticator.session:
		return _authenticator.session.user_id
	return ""


#Authentication
func register_async(email: String, password: String) -> int:
	var result: int = yield(_authenticator.register_async(email, password), "completed")
	if result == OK:
		_storage_worker = StorageWorker.new(_authenticator.session, _client, _exception_handler)
	return result

func login_async(email: String, password: String) -> int:
	var result: int = yield(_authenticator.login_async(email, password), "completed")
	if result == OK:
		_storage_worker = StorageWorker.new(_authenticator.session, _client, _exception_handler)
	return result


#Server Connection
func connect_to_server_async() -> int:
	_socket = Nakama.create_socket_from(_client)
	var result: NakamaAsyncResult = yield(_socket.connect_async(_authenticator.session), "completed")
	var parsed_result := _exception_handler.parse_exception(result)
	if parsed_result == OK:
		_socket.connect("connected", self, "_on_NakamaSocket_connected")
		_socket.connect("closed", self, "_on_NakamaSocket_closed")
		_socket.connect("received_error", self, "_on_NakamaSocket_received_error")
		_socket.connect("received_match_presence", self, "_on_NakamaSocket_received_match_presence")
		_socket.connect("received_match_state", self, "_on_NakamaSocket_received_match_state")
		_socket.connect("received_channel_message", self, "_on_NamakaSocket_received_channel_message")
	return parsed_result

func _on_NakamaSocket_connected() -> void:
	return

func _on_NakamaSocket_closed() -> void:
	_socket = null

func _on_NakamaSocket_received_error(error: String) -> void:
	error_message = error
	_socket = null

func _on_NakamaSocket_received_match_presence(new_presences: NakamaRTAPI.MatchPresenceEvent) -> void:
	for leave in new_presences.leaves:
		presences.erase(leave.user_id)
	for join in new_presences.joins:
		if not join.user_id == get_user_id():
			presences[join.user_id] = join
	emit_signal("presences_changed")

func _on_NakamaSocket_received_match_state(match_state: NakamaRTAPI.MatchData) -> void:
	var code := match_state.op_code
	var raw := match_state.data
	match code:
		OpCodes.INITIAL_STATE:
			var decoded: Dictionary = JSON.parse(raw).result
			var positions: Dictionary = decoded.pos
			var initiatives: Dictionary = decoded.ini
			var stats: Dictionary = decoded.stats
			var names: Dictionary = decoded.nms
			emit_signal("initial_state_received", positions, initiatives, stats, names)
		OpCodes.DO_SPAWN:
			var decoded: Dictionary = JSON.parse(raw).result
			var id: String = decoded.id
			var name: String = decoded.nm
			emit_signal("character_spawned", id, name)
		OpCodes.NORMAL_ATTACK:
			var decoded: Dictionary = JSON.parse(raw).result
			var target = decoded.trgt
			var attacker = decoded.atk
			var dice_value = decoded.dice
			emit_signal("normal_attack", target, attacker, dice_value)
			
func _on_NamakaSocket_received_channel_message(message: NakamaAPI.ApiChannelMessage) -> void:
	if message.code != 0:
		return
	var content: Dictionary = JSON.parse(message.content).result
	emit_signal("chat_message_received", message.username.split("@")[0], content.msg)


#Matchmaking
func join_campaign_async() -> int:
	if not _socket:
		error_message = "Server not connected."
		return ERR_UNAVAILABLE

	if not _campaign_id:
		var campaign: NakamaAPI.ApiRpc = yield(_client.rpc_async(_authenticator.session, "get_campaign_id", ""), "completed")
		var parsed_result := _exception_handler.parse_exception(campaign)
		if parsed_result != OK:
			return parsed_result
		_campaign_id = campaign.payload

	#Chat
	var match_join_result: NakamaRTAPI.Match = yield(_socket.join_match_async(_campaign_id), "completed")
	var parsed_result := _exception_handler.parse_exception(match_join_result)
	if parsed_result == OK:
		for presence in match_join_result.presences:
			presences[presence.user_id] = presence

		var chat_join_result: NakamaRTAPI.Channel = yield(_socket.join_chat_async("campaign", NakamaSocket.ChannelType.Room, false, false), "completed")
		parsed_result = _exception_handler.parse_exception(chat_join_result)
		_channel_id = chat_join_result.id
	return parsed_result

func send_spawn(name: String) -> void:
	if _socket:
		var payload := {id = get_user_id(), nm = name}
		_socket.send_match_state_async(_campaign_id, OpCodes.DO_SPAWN, JSON.print(payload))

#Chat
func send_text_async(text: String) -> int:
	if not _socket:
		return ERR_UNAVAILABLE
	var data := {"msg": text}
	var message_response: NakamaRTAPI.ChannelMessageAck = yield(_socket.write_chat_message_async(_channel_id, data), "completed")

	var parsed_result := _exception_handler.parse_exception(message_response)
	if parsed_result != OK:
		emit_signal("chat_message_received", "SYSTEM", "Error code %s: %s" % [parsed_result, error_message])
	yield(get_tree(), "idle_frame")
	return parsed_result
