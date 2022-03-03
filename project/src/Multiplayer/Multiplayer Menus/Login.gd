extends Control

signal register_pressed(email, password)
signal login_pressed(email, password)

var status := "" setget set_status
var is_enabled := true setget set_is_enabled

onready var email_field := $Form/Email/LineEdit
onready var password_field := $Form/Password/LineEdit
onready var status_panel := $Form/Message/Panel/Label
onready var login_button := $Form/Buttons/Login
onready var register_button := $Form/Buttons/Register


func _ready():
	pass 

func set_status(value: String) -> void:
	status = value
	status_panel.text = status

func set_is_enabled(value: bool) -> void:
	email_field.editable = value
	password_field.editable = value
	login_button.disabled = !value
	register_button.disabled = !value
	

func attempt_login() -> void:
	if email_field.text == "":
		status_panel.text = "Please enter your email to log in"
		return
	if password_field.text == "":
		status_panel.text = "Please enter your password to log in"
		return
	emit_signal("login_pressed", email_field.text, password_field.text)
	status_panel.text = "Authenticating..."

func attempt_register() -> void:
	if email_field.text.empty():
		self.status = "Email cannot be empty"
		return
	elif password_field.text.empty():
		self.status = "Password cannot be empty"
		return
	emit_signal("register_pressed", email_field.text, password_field.text)

func _on_Login_pressed():
	attempt_login()

func _on_Register_pressed():
	attempt_register()
