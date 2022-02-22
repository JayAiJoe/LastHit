extends "res://addons/gut/test.gd"

var Encounter = load("res://src/Encounters/EncounterBase.gd")
var _encounter = null

func before_each():
	_encounter = Encounter.new()
	
func after_each():
	_encounter.free()



