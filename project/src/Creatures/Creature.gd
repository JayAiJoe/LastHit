extends Node

class_name Creature

var creature_id
var creature_name
var creature_passive_text
var creature_active_text

var armor_class = 1
var max_hp = 5
var current_hp = 5
var crit_multiplier = 2
var initiative = 1
var base_dmg = 5

func _ready():
	creature_id = "-1"

func switch_creature(cid):
	creature_id = cid
	creature_name = Global.creature_db[cid]["name"]
	creature_passive_text = Global.creature_db[cid]["passive_text"]
	creature_active_text = Global.creature_db[cid]["active_text"]
