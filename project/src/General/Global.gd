extends Node

var current_scene
var root

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count()-1)
	
func switch_scene_to(path):
	call_deferred("deferred_switch_scene", path)
	
func deferred_switch_scene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

