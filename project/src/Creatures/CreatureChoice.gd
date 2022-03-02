extends Area2D

var selected
func _ready():
	deselect()
	
func select():
	selected = true
	$Frame.show()
	
func deselect():
	selected = false
	$Frame.hide()
	
func click(viewport, event, shapeidx):
	if event is InputEventMouseButton and event.pressed:
		get_parent().select_starter(get_index())

