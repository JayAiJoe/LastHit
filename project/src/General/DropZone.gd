extends Position2D

var radius = 75

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
	
