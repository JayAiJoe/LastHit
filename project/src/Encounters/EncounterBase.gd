extends Node2D

var zone_radius = 50

func _ready():
	set_zone_radius(150)

func set_zone_radius(radius):
	zone_radius = radius
	$DropZone.radius = radius
	$DropZone.update()
