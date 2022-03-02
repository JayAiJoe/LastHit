extends Area2D

func _ready():
	deselect()

func deselect():
	$Frame.hide()

func select():
	$Frame.show()
	
func click(event):
	if event is InputEventMouseButton and event.pressed:
		get_parent().select_starter(get_index())
