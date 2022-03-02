extends Node2D

var cards = []

func _ready():
	pass # Replace with function body.

func select_starter(index):
	if index in cards:
		get_child(index).deselect()
		cards.pop_at(cards.find(index))
	else:
		if len(cards) == 2:
			get_child(cards.pop_front()).deselect()
		cards.append(index)
		get_child(index).select()
		
	print(cards)
	
func accept_starters(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if len(cards) == 2:
			Global.switch_scene_to("res://src/General/CombatMaster.tscn")
		else:
			print("kulang sirrr")
		
