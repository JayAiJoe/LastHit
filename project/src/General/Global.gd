extends Node

var current_scene
var root

var player

var creature_db = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count()-1)
	
	creature_db = {"-1":{"name":"Nullmon",
						 "passive_text":"There's something wrong",
						 "active_text":"Code better"},
					"0":{"name":"Slimey Slime",
						 "passive_text":"Whenever you apply poison, double it.",
						 "active_text":"Apply 1 poison to an enemy"},
					"1":{"name":"Dr. Hedgehog",
						 "passive_text":"You can now throw dice to anyone but yourself. Your dice now heal instead of damage.",
						 "active_text":"Deal high damage to everyone."},
					"2":{"name":"Voo Doo",
						 "passive_text":"Any damage you do is increased for every debuff you have.",
						 "active_text":"Deal high damage. Then gain a weaken debuff."},
					"3":{"name":"Umbrella Brigitte",
						 "passive_text":"Every time you hit anyone, give the whole team 1 shield.",
						 "active_text":"Deal small damage to an enemy 3 times."},
					"4":{"name":"THE fence",
						 "passive_text":"Gain a barrier at the start of every encounter.",
						 "active_text":"Deal increased damage to an enemy if you have full health."}
					}
	
func switch_scene_to(path):
	call_deferred("deferred_switch_scene", path)
	
func deferred_switch_scene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

