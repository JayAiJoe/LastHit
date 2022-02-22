extends Node2D

var Dice = preload("res://src/Dice/Dice.tscn")
var radius = 75
var d_num = 5
var selected_dice = null
var entered = false

func _ready():
	for i in range(d_num):
		var dice = Dice.instance()
		dice.index = i
		dice.rest_point = global_position + Vector2(randi()%250-90, randi()%250-90)
		add_child(dice)
		
func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if selected_dice != null and entered:
				selected_dice.rest_point = get_global_mouse_position()

func _on_Area2D_mouse_entered():
	entered = true

func _on_Area2D_mouse_exited():
	entered = false
