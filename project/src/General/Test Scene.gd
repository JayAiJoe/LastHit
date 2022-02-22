extends Node2D

var screen_size = Vector2.ZERO

func _ready():
	screen_size = get_viewport_rect().size
	$DiceTray.position.x = screen_size.x/8
	$DiceTray.position.y = screen_size.y/2
