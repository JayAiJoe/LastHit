extends Node

const KEY := "last_hit"

signal presences_changed

var _client := Nakama.create_client(KEY, "127.0.0.1", 7350, "http")
var _socket: NakamaSocket setget _no_set
var _exception_handler := ExceptionHandler.new()
var _authenticator := Authenticator.new(_client, _exception_handler)
var _storage_worker: StorageWorker

var error_message := "" setget _no_set, _get_error_message
var presences := {} setget _no_set

func _no_set(_value) -> void:
	pass

func _get_error_message() -> String:
	return _exception_handler.error_message

func get_user_id() -> String:
	if _authenticator.session:
		return _authenticator.session.user_id
	return ""



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
	#match code:
		#op codes

func _on_NamakaSocket_received_channel_message(message: NakamaAPI.ApiChannelMessage) -> void:
	if message.code != 0:
		return
	var content: Dictionary = JSON.parse(message.content).result
	emit_signal("chat_message_received", message.sender_id, content.msg)
