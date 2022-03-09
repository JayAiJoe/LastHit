extends Node2D

class_name TurnQueue

var TurnCard = preload("res://src/General/TurnCard.tscn")

var characters

var enemies

func _ready():
	pass
	
func on_encounter_start():
	characters = get_tree().get_nodes_in_group("Characters")
	characters.sort_custom(self, 'sort_initiative')
	for c in characters:
		var turnCard = TurnCard.instance()
		turnCard.get_node("TextureRect").texture = load(c.get_sprite_path())
		$Visual.add_child(turnCard)

func on_encounter_end():
	for c in $Visual.get_children():
		$Visual.remove_child(c)
	print("Winner!")
		
static func sort_initiative(a, b) -> bool:
	var x
	var y
	if "player" in a:
		x = a.player.initiative
	else:
		x = a.creature.initiative
	
	if "player" in b:
		y = b.player.initiative
	else:
		y = b.creature.initiative
	
	return x > y

func move_queue():
	$Visual.move_child($Visual.get_child(0), characters.size() - 1)
