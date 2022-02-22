extends Node2D


var zone_radius = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	set_zone_radius(30)


func set_zone_radius(radius):
	zone_radius = radius
	$DropZone.radius = radius
	$DropZone.update()
