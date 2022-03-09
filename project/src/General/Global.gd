extends Node

var current_scene
var root

var player

var N = 10

var biome_sequence
var next_biome

var boss_sequence
var next_boss
var encounter

var creature_db = {}

var bgs

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count()-1)
	
	player = Player.new()
	
	generate_biome_sequence(N)
	generate_boss_sequence(N)
	encounter = 0
	
	fill_creature_db()
	
	bgs = {"steam": preload("res://src/Assets/Biomes/steam.png"),
			"fae": preload("res://src/Assets/Biomes/fae.png"),
			"shadow": preload("res://src/Assets/Biomes/shadow.png"),
			"water": preload("res://src/Assets/Biomes/water.jpg")}
	
func switch_scene_to(path):
	call_deferred("deferred_switch_scene", path)
	
func deferred_switch_scene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	
func generate_biome_sequence(n):
	var all = ["steam", "fae", "shadow", "water"]
	var final = []
	var i = 0
	n = max(n,12)
	while len(final) < n:
		if i%4 == 0:
			all.shuffle()
		final += [all[i%4], all[i%4], all[i%4]]
		i += 1
		
	biome_sequence = final
	print(biome_sequence)
	next_biome = biome_sequence[0]
	
func generate_boss_sequence(n):
	var all = ["0", "1", "2", "3", "4"]
	var final = []
	n = max(n,12)
	while len(final) < n:
		all.shuffle()
		final += all
	boss_sequence = final.slice(0,n-1)
	next_boss = boss_sequence[0]

func encounter_end():
	encounter += 1
	next_biome = biome_sequence[encounter]
	next_boss = boss_sequence[encounter]
	
func fill_creature_db():
	creature_db = {"-1":{"name":"Nullmon",
						 "passive_text":"There's something wrong",
						 "active_text":"Code better"},
						
					"0":{"name":"Slimey Slime",
						 "passive_text":"Whenever you apply poison, double it.",
						 "active_text":"Apply 1 poison to an enemy",
						 "animated": true,
						 "image_path": "res://src/Assets/Bosses/SlimeFrames.tres",
						 "scale": 10},
						
					"1":{"name":"Dr. Hedgehog",
						 "passive_text":"You can now throw dice to anyone but yourself. Your dice now heal instead of damage.",
						 "active_text":"Deal high damage to everyone.",
						 "animated": false,
						 "image_path": "res://src/Assets/Bosses/hedgehog.jpg",
						 "scale": 0.202},
						
					"2":{"name":"Voo Doo",
						 "passive_text":"Any damage you do is increased for every debuff you have.",
						 "active_text":"Deal high damage. Then gain a weaken debuff.",
						 "animated": false,
						 "image_path": "res://src/Assets/Bosses/voodoo.png",
						 "scale": 0.318},
						
					"3":{"name":"Brigitte",
						 "passive_text":"Every time you hit anyone, give the whole team 1 shield.",
						 "active_text":"Deal small damage to an enemy 3 times.",
						 "animated": false,
						 "image_path": "res://src/Assets/Bosses/brig.png",
						 "scale": 1.1},
						
					"4":{"name":"THE fence",
						 "passive_text":"Gain a barrier at the start of every encounter.",
						 "active_text":"Deal increased damage to an enemy if you have full health.",
						 "animated": false,
						 "image_path": "res://src/Assets/Bosses/fence.png",
						 "scale": 1.426},
					}
