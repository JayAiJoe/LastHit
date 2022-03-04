extends Control

signal text_sent(text)
signal edit_started
signal edit_ended

const HISTORY_LENGTH := 20

var reply_count := 0

onready var chat_log: RichTextLabel = $ScrollContainer/ChatLog
onready var line_edit: LineEdit = $HBoxContainer/LineEdit

func _init() -> void:
	visible = false

func _ready() -> void:
	chat_log.bbcode_text = ""

func add_reply(text: String, sender_name: String) -> void:
	if reply_count == HISTORY_LENGTH:
		chat_log.bbcode_text = chat_log.bbcode_text.substr(chat_log.bbcode_text.find("\n"))
	else:
		reply_count += 1
	chat_log.bbcode_text += ("\n%s: %s"% [sender_name, text])


func send_chat_message() -> void:
	if line_edit.text.length() == 0:
		return
	var text: String = line_edit.text.replace("[", "{").replace("]", "}")
	emit_signal("text_sent", text)
	line_edit.text = ""


func _on_SendButton_pressed() -> void:
	send_chat_message()


func _on_LineEdit_text_entered(_new_text: String) -> void:
	send_chat_message()


func _on_LineEdit_focus_entered() -> void:
	emit_signal("edit_started")


func _on_LineEdit_focus_exited() -> void:
	emit_signal("edit_ended")


func _on_ToggleChatButton_toggled(button_pressed: bool) -> void:
	visible = button_pressed
