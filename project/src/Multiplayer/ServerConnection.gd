extends Node

enum OpCodes {
	ASSIGN_CAPTAIN = 1
	INITIAL_STATE = 2,
	DO_SPAWN = 3,
	NEXT_ENCOUNTER = 4,
	CHARACTER_ACTION = 5,
	FETCH_STATE = 6
}

const KEY := "last_hit"

signal presences_changed
signal chat_message_received(username, text)
signal initial_state_received(character_states)
signal character_spawned(id, name)
signal next_encounter(biome, boss)
signal character_action_received(target, value)

var _client := Nakama.create_client(KEY, "127.0.0.1", 7350, "http")
var _socket: NakamaSocket setget _no_set
var _exception_handler := ExceptionHandler.new()
var _authenticator := Authenticator.new(_client, _exception_handler)
var _storage_worker: StorageWorker

var error_message := "" setget _no_set, _get_error_message
var presences := {} setget _no_set
var _campaign_id: String setget _no_set
var _channel_id: String setget _no_set

var username = "default name"

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
			var decoded : Dictionary = JSON.parse(raw).result
			emit_signal("initial_state_received", decoded)
		OpCodes.DO_SPAWN:
			var decoded: Dictionary = JSON.parse(raw).result
			var id : String = decoded.id
			var name : String = decoded.nm
			emit_signal("character_spawned", id, name)
		OpCodes.NEXT_ENCOUNTER:
			var decoded: Dictionary = JSON.parse(raw).result
			var biome : String = decoded.bio
			var boss : String = decoded.bss
			emit_signal("next_encounter", biome, boss)
		OpCodes.CHARACTER_ACTION:
			var decoded: Dictionary = JSON.parse(raw).result
			var actor_id : String = decoded.id
			var action_id : int = decoded.act
			var targets : Array = decoded.tgt
			var dice_value : int = decoded.die
			emit_signal("character_action_received", actor_id, action_id, targets, dice_value)
		OpCodes.FETCH_STATE:
			var decoded: Dictionary = JSON.parse(raw).result
			print(decoded)
			
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
	if parsed_result == OK:
		send_assign_captain()
	return parsed_result

func send_assign_captain() -> void:
	if _socket:
		var payload := {id = get_user_id()}
		_socket.send_match_state_async(_campaign_id, OpCodes.ASSIGN_CAPTAIN, JSON.print(payload))

func send_spawn(name: String) -> void:
	if _socket:
		var payload := {id = get_user_id(), nm = name}
		_socket.send_match_state_async(_campaign_id, OpCodes.DO_SPAWN, JSON.print(payload))

func send_next_encounter() -> void:
	if _socket:
		var payload = {id = get_user_id(), bio = Global.next_biome, bss = Global.next_boss}
		_socket.send_match_state_async(_campaign_id, OpCodes.NEXT_ENCOUNTER, JSON.print(payload))

func send_action(actor_id : String, action_id : int, targets : Array, dice_value : int) -> void:
	if _socket:
		var payload = {id = actor_id, act = action_id, tgt = targets, die = dice_value}
		_socket.send_match_state_async(_campaign_id, OpCodes.CHARACTER_ACTION, JSON.print(payload))

func send_fetch_state() -> void:
	if _socket:
		var payload = {id = get_user_id()}
		_socket.send_match_state_async(_campaign_id, OpCodes.FETCH_STATE, JSON.print(payload))


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
