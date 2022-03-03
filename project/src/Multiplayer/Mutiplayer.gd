extends Node

const MAX_REQUEST_ATTEMPTS := 3

var _server_request_attempts := 0

onready var login_register := $CanvasLayer/LoginRegister
onready var play_button := $CanvasLayer/PlayButton

func _ready() -> void:
	login_register.connect("login_pressed", self, "valid_login_pressed")
	login_register.connect("register_pressed", self, "valid_register_pressed")
	play_button.disabled = true

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


# Requests the server to authenticate the player using their credentials.
# Attempts authentication up to `MAX_REQUEST_ATTEMPTS` times.
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
		#open_character_menu_async()
	else:
		login_register.status = "Error code %s: %s" % [result, ServerConnection.error_message]
		login_register.is_enabled = true
	_server_request_attempts = 0
	return result


func _on_PlayButton_pressed():
	print("play!")
	ServerConnection.connect_to_server_async()
