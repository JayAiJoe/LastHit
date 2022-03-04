extends Node

const MAX_REQUEST_ATTEMPTS := 3

var _server_request_attempts := 0
var username := ""

onready var login_register := $CanvasLayer/LoginRegister
onready var play_button := $CanvasLayer/PlayButton
onready var chat_box := $CanvasLayer/ChatBox

func _ready() -> void:
	login_register.connect("login_pressed", self, "valid_login_pressed")
	login_register.connect("register_pressed", self, "valid_register_pressed")
	play_button.disabled = true
	ServerConnection.connect("chat_message_received", self, "_on_chat_message_received")

#Authentication
func valid_login_pressed(email: String, password: String) -> void:
	login_register.status = "Logging in..."
	login_register.is_enabled = false
	yield(authenticate_user_async(email, password), "completed")
	login_register.is_enabled = true

func valid_register_pressed(email: String, password: String) -> void:
	login_register.status = "Registering..."
	login_register.is_enabled = false
	var result: int = yield(ServerConnection.register_async(email, password), "completed")
	if result == OK:
		yield(authenticate_user_async(email, password), "completed")
	else:
		login_register.status = "Error code %s: %s" % [result, ServerConnection.error_message]
	login_register.is_enabled = true

func authenticate_user_async(email: String, password: String) -> int:
	var result := -1
	login_register.is_enabled = false
	while result != OK:
		if _server_request_attempts == MAX_REQUEST_ATTEMPTS:
			break
		_server_request_attempts += 1
		result = yield(ServerConnection.login_async(email, password), "completed")
	if result == OK:
		login_register.status = "Successfully logged in!"
		login_register.is_enabled = false
		play_button.disabled = false
		username = email.split("@")[0]
		#open_character_menu_async()
	else:
		login_register.status = "Error code %s: %s" % [result, ServerConnection.error_message]
		login_register.is_enabled = true
	_server_request_attempts = 0
	return result


#Matchmaking
func _on_PlayButton_pressed():
	join_campaign_async(username)
	activate_chat()

func join_campaign_async(player_name: String) -> int:
	var result: int = yield(ServerConnection.connect_to_server_async(), "completed")
	if result == OK:
		result = yield(ServerConnection.join_campaign_async(), "completed")
	if result == OK:
		pass
		#get_tree().change_scene_to(load("res://src/General/CombatMaster.tscn"))
		#ServerConnection.send_spawn(player_color, player_name)
	return result

#Chat
func activate_chat():
	login_register.visible = false
	play_button.visible = false
	chat_box.visible = true
	
func _on_ChatBox_text_sent(text) -> void:
	ServerConnection.send_text_async(text) #async yield

func _on_chat_message_received(sender_name, text) -> void:
	chat_box.add_reply(text, sender_name)
