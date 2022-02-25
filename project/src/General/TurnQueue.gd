extends Node2D

class_name TurnQueue

var characters
var active_character
var index = 0

var enemies

func _ready():
	initialize()
	while get_tree().get_nodes_in_group("Enemies").size() > 0:
		yield(play_turn(), "completed")
	print("Winner!")
		
func initialize():
	characters = get_tree().get_nodes_in_group("Characters")
	characters.sort_custom(self, 'sort_initiative')
	active_character = characters[index]

static func sort_initiative(a, b) -> bool:
	return a.initiative > b.initiative

func play_turn():
	active_character = characters[index]
	index = (index+1)%(characters.size())
	yield(active_character.play_turn(), "completed")
	
	
