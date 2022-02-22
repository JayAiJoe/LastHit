extends Node2D

var Dice = preload("res://src/Dice/Dice.tscn")
var radius = 75
var d_num = 5
var selected_dice = null
var dice_distance = 100
var dice_size = 64

func _ready():
	reset()
	
func reset():
	for i in range(d_num):
		var dice = Dice.instance()
		dice.index = i
		dice.rest_point = global_position + Vector2(i*dice_distance, -dice_size/2)
		add_child(dice)
