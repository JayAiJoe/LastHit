extends "res://addons/gut/test.gd"

var Encounter = load("res://src/Encounters/EncounterBase.tscn")
var _encounter = null

func before_each():
	_encounter = Encounter.instance()
	
func after_each():
	_encounter.free()



