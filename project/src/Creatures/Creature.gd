extends Node

class_name Creature

var creature_id
var creature_name
var creature_passive_text
var creature_active_text

func _ready():
	pass
	
func _init():
	creature_id = "-1"
	
func switch_creature(new_id):
	creature_id = new_id

