extends Node2D

var hp = 100
var max_hp = 100
var shielded = false


func _ready():
	pass 


func take_damage(amount):
	if shielded:
		amount/=2
	hp = max(0, hp-amount)

