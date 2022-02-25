extends Node2D

var zone_radius = 50
var armor_class = 1
var max_hp = 5
var current_hp = 5
var crit_multiplier = 2
var initiative = 1

func _ready():
	randomize()
	set_zone_radius(120)
	set_armor_class(8)
	set_max_hp(30)
	set_current_hp(30)
	$DropZone.connect("trigger", self, "take_hit")
	$DropZone.type = 2
	$LifeBar/Life.set_text(str(current_hp) + "/" + str(max_hp))
	roll_initiative(20, 20)

func roll_initiative(minimum, maximum):
	initiative = randi() % (maximum-minimum+1) + minimum

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
	if current_hp == 0:
		remove_from_group("Enemies")
		queue_free()
		
func play_turn():
	print("Slime did a turn!")
	$Timer.wait_time = 0.1
	$Timer.start()
	yield($Timer, "timeout")

func play_hit_animation():
	$Timer.wait_time = 0.2
	$Timer.start()
	$AnimatedSprite.modulate = Color.webmaroon
	$AnimatedSprite.playing = false
	yield($Timer, "timeout")
	$AnimatedSprite.modulate = Color.white
	yield($Timer, "timeout")
	$AnimatedSprite.modulate = Color.webmaroon
	yield($Timer, "timeout")
	$AnimatedSprite.modulate = Color.white
	$AnimatedSprite.playing = true
