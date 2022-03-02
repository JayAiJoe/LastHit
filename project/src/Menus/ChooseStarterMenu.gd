extends Node2D

var starters = []
var cards = []

func _ready():
	pass

func select_starter(index):
	if len(cards) == 2:
		get_child(cards.pop_front()).deslect()
	get_child(index).select()
	cards.append(index)
	
func accept_starters(viewport, event, shapeidx):
	if event is InputEventMouseButton:
		if len(starters) == 2:
			var p = Global.player
			Global.switch_scene_to("res://src/General/CombatMaster.tscn")
		print("kulang sirr")


