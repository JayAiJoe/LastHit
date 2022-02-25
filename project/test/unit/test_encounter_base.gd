extends "res://addons/gut/test.gd"

var Encounter = load("res://src/Encounters/EncounterBase.tscn")
var _encounter = null

func before_each():
	_encounter = Encounter.instance()
	_encounter.set_max_hp(10)
	_encounter.set_current_hp(10)
	_encounter.set_armor_class(10)
	
func after_each():
	_encounter.free()

func test_initiative():
	_encounter.roll_initiative(1,20)
	var res = _encounter.initiative
	assert_true(res>0 and res <21, "roll should be 1-20")
	
func test_set_zone_radius():
	_encounter.set_zone_radius(25)
	assert_eq(_encounter.get_node("DropZone").radius, 25, "The radius should be 25")

func test_miss():
	_encounter.take_hit(10, 5)
	assert_eq(_encounter.current_hp, 10, "Hp should be 10")

func test_hit():
	_encounter.take_hit(11, 5)
	assert_eq(_encounter.current_hp, 5, "Hp should be 5")
	
func test_critical_hit():
	_encounter.take_hit(20, 5)
	assert_eq(_encounter.current_hp, 0, "Hp should be 0")
	
func test_overkill():
	_encounter.take_hit(20, 7)
	assert_eq(_encounter.current_hp, 0, "Hp should be 0")
	
func test_overheal():
	_encounter.set_current_hp(20)
	assert_eq(_encounter.current_hp, 10, "Hp should be 10")
