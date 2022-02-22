extends Position2D

var radius = 75
var type = 1

signal trigger


func _ready():
	pass

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.blanchedalmond)
	
func select():
	for child in get_tree().get_nodes_in_group("DropZones"):
		child.deselect()
	modulate = Color.webmaroon

func deselect():
	modulate = Color.white

func trigger(value1, value2):
	emit_signal("trigger", value1, value2)
	if type == 1:
		remove_from_group("DropZones")
		queue_free()
	
