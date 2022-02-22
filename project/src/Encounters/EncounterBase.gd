extends Node2D

var zone_radius = 50
var armor_class = 1
var max_hp = 5
var current_hp = 5
var crit_multiplier = 2

func _ready():
	set_zone_radius(120)
	set_armor_class(8)
	set_max_hp(30)
	set_current_hp(30)
	$DropZone.connect("trigger", self, "take_hit")
	$DropZone.type = 2
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
	$ArmorClass/Armor.text = str(ac)

func take_hit(roll, dmg):
	if roll > armor_class:
		if roll == 20:
			set_current_hp(current_hp - dmg*crit_multiplier)
		else:
			set_current_hp(current_hp - dmg)
		play_hit_animation()

func play_hit_animation():
	$Sprite.modulate = Color.webmaroon
	$Timer.wait_time = 0.2
	$Timer.start()
	yield($Timer, "timeout")
	$Sprite.modulate = Color.white
	yield($Timer, "timeout")
	$Sprite.modulate = Color.webmaroon
	yield($Timer, "timeout")
	$Sprite.modulate = Color.white
