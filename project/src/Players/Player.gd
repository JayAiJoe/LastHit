extends Node2D

class_name Player

var player_name

var creatures

var max_hp = 20
var current_hp = 20
var crit_multiplier = 2
var initiative = 1

var shielded = false

var combat_master = null

signal end_turn

func _ready():
	randomize()
	set_max_hp(30)
	set_current_hp(30)
	$LifeBar/Life.set_text(str(current_hp) + "/" + str(max_hp))
	roll_initiative(1, 1)
	for a in get_tree().get_nodes_in_group("Actions"):
		a.connect("trigger", self, "perform_action")
	combat_master = get_parent()
	
func _init(_name):
	player_name = _name
	creatures = [Creature.new(), Creature.new(), Creature.new()]

func roll_initiative(minimum, maximum):
	initiative = randi() % (maximum-minimum+1) + minimum

func set_max_hp(hp):
	max_hp = hp
	$LifeBar.max_value = hp

func set_current_hp(hp):
	current_hp = max(min(hp, max_hp), 0)
	$LifeBar.value = current_hp
	$LifeBar/Life.set_text(str(current_hp) + "/" + str(max_hp))

func take_hit(dmg):
	if dmg > 0:
		set_current_hp(current_hp - dmg)
		play_hit_animation()

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

## gets called on turn start, waits until a die is played
func play_turn():
	yield(self, "end_turn")

## gets called when a die is played
func perform_action(roll, dmg):
	print("Hero turn: " + str(roll))
	emit_signal("end_turn")
	
func get_sprite_path():
	return $StaticSprite.texture.resource_path
	

