extends Node2D

var zone_radius = 50
var armor_class = 1
var max_hp = 5
var current_hp = 5

func _ready():
	set_zone_radius(120)
	set_armor_class(8)
	set_max_hp(30)
	set_current_hp(30)
	$DropZone.connect("trigger", self, "take_hit")
	$LifeBar/Life.set_text(str(current_hp) + "/" + str(max_hp))

func set_zone_radius(radius):
	zone_radius = radius
	$DropZone.radius = radius
	$DropZone.update()

func set_max_hp(hp):
	max_hp = hp
	$LifeBar.max_value = hp

func set_current_hp(hp):
	current_hp = max(min(hp, max_hp), 0)
	$LifeBar.value = current_hp
	$LifeBar/Life.set_text(str(current_hp) + "/" + str(max_hp))

func set_armor_class(ac):
	armor_class = ac

func take_hit(hit):
	if hit > armor_class:
		set_current_hp(current_hp - 5)
		play_hit_animation()

func play_hit_animation():
	$Sprite.modulate = Color.webmaroon
	yield(get_tree().create_timer(0.2), "timeout")
	$Sprite.modulate = Color.white
	yield(get_tree().create_timer(0.2), "timeout")
	$Sprite.modulate = Color.webmaroon
	yield(get_tree().create_timer(0.2), "timeout")
	$Sprite.modulate = Color.white
