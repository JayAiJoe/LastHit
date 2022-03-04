extends Node

class_name Player

var player_name
var max_hp = 20
var current_hp = 20
var crit_multiplier = 2
var initiative = 1

var shielded = false

var creatures

func _ready():
	creatures = [Creature.new(), Creature.new(), Creature.new()]
	
func _init(_name = "Sampy"):
	player_name = _name

