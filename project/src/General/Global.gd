extends Node

var root = null
var current_scene = null

var player
var creature_db

func _ready():
	root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	player = Player.new("Apollo")
	#[Player{name, creatures=[creature{}, creature{}, creature{}] }, Player{}]
	
	creature_db = {"0": {"name":"Slimey Slime",
						 "passive_text":"Whenever you apply poison, double it.",
						 "active_text":"Apply 1 poison to the enemy"},
				   "1": {"name":"Dr. Hedgehog",
						 "passive_text":"Throwing dice will heal instead of damage. You can now throw dice to anyone.",
						 "active_text":"Deal high damage to everyone."},
				   "2": {"name":"THE Fence",
						 "passive_text":"Negate the first damage you receive every encounter.",
						 "active_text":"Deal increased damage if you have full health"},
				   "3": {"name":"Brigitte Umbrella",
						 "passive_text":"Whenever you hit an enemy, give armor to the whole team.",
						 "active_text":"Deal small damage to an enemy 3 times"},
				   "4": {"name":"Voo Doo",
						 "passive_text":"Increase damage based on number of debuffs you have.",
						 "active_text":"Deal high damage to enemy. Gain random debuff."}
				   }
				
func switch_scene_to(path):
	call_deferred("deferred_switch_scene_to", path)

func deferred_switch_scene_to(path):
	 # assume that it is now safe to remove the current scene
	current_scene.free()
	# Load the new scene.
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
