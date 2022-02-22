extends Node2D

var selected = false
var rest_point
var rest_nodes = []
var value = -1
var index = -1

onready var tray = get_parent()


func _ready():
	randomize()
	rest_nodes = get_tree().get_nodes_in_group("DropZones")
	value = roll(1,20)
	$Number.text = str(value)

func roll(minimum, maximum):
	var res = randi() % (maximum-minimum+1) + minimum
	return res


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("left_click"):
		for item in get_tree().get_nodes_in_group("Draggables"):
			if item.index != index:
				item.selected = false
		if tray.selected_dice == null:
			tray.selected_dice = self
			selected = true

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 30*delta)
		var angle = (get_global_mouse_position() - global_position).normalized().angle()
		if angle != 0:
			rotation = lerp_angle(rotation, angle, 0.1)
	else:
		global_position = lerp(global_position, rest_point, 5*delta)
		#rotation = lerp_angle(rotation, 0, 5*delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			
			if tray.selected_dice != null and tray.selected_dice.index == index:
				tray.selected_dice = null
				selected = false
			
			#for node in rest_nodes:
			#	var distance = global_position.distance_to(node.global_position)
			#	if distance <= node.radius:
			#		rest_point = node.global_position

