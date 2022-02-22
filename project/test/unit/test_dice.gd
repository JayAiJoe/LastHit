extends "res://addons/gut/test.gd"

var Dice = load("res://src/Dice/Dice.gd")
var _dice = null

func before_each():
	_dice = Dice.new()
	
func after_each():
	_dice.free()

func test_roll():
	var res = _dice.roll(1,20)
	assert_true(res>0 and res <21, "roll should be 1-20")
