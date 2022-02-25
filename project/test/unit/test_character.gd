extends "res://addons/gut/test.gd"

var Character = load("res://src/Characters/Character.tscn")
var _character = null

func before_each():
	_character = Character.instance()
	_character.set_max_hp(10)
	_character.set_current_hp(10)
	
func after_each():
	_character.free()

func test_set_zone_radius():
	_character.set_zone_radius(25)
	assert_eq(_character.get_node("DropZone").radius, 25, "The radius should be 25")

func test_hit():
	_character.take_hit(5)
	assert_eq(_character.current_hp, 5, "Hp should be 5")
	
func test_overkill():
	_character.take_hit(15)
	assert_eq(_character.current_hp, 0, "Hp should be 0")
	
func test_overheal():
	_character.set_current_hp(20)
	assert_eq(_character.current_hp, 10, "Hp should be 10")
