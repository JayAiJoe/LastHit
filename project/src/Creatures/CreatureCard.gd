extends TextureRect

var creature

func _ready():
	creature = Creature.new()

func set_creature(cid):
	creature.switch_creature(cid)
	get_node("HBoxContainer/VBoxContainer2/Name").set_text(creature.creature_name)
	get_node("HBoxContainer/VBoxContainer2/Passive2/Label").set_text(creature.creature_passive_text)
	get_node("HBoxContainer/VBoxContainer2/Active/Label").set_text(creature.creature_active_text)
