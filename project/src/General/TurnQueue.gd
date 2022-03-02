extends Node2D

class_name TurnQueue

var TurnCard = preload("res://src/General/TurnCard.tscn")

var characters
var active_character
var index = 0

var enemies

func _ready():
	initialize()
	while get_tree().get_nodes_in_group("Enemies").size() > 0:
		yield(play_turn(), "completed")
		
	for c in $Visual.get_children():
		$Visual.remove_child(c)
	print("Winner!")
		
func initialize():
	characters = get_tree().get_nodes_in_group("Characters")
	print(characters)
	characters.sort_custom(self, 'sort_initiative')
	active_character = characters[index]
	for c in characters:
		var turnCard = TurnCard.instance()
		turnCard.get_node("TextureRect").texture = load(c.get_sprite_path())
		$Visual.add_child(turnCard)

static func sort_initiative(a, b) -> bool:
	return a.initiative > b.initiative

func play_turn():
	active_character = characters[index]	
	index = (index+1)%(characters.size())
	yield(active_character.play_turn(), "completed")
	$Visual.move_child($Visual.get_child(0), characters.size() - 1)
	
	
	
