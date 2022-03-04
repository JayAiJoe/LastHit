extends TextureRect

var creature

func _ready():
	creature = Creature.new()

func set_creature(cid):
	creature.set_creature(cid)
	get_node("HBoxContainer/VBoxContainer2/Name").set_text(creature.creature_name)
	get_node("HBoxContainer/VBoxContainer2/Passive2/Label").set_text(creature.creature_passive_text)
	get_node("HBoxContainer/VBoxContainer2/Active/Label").set_text(creature.creature_active_text)
	
func show_creature(c):
	if c.creature_id == "empty":
		hide()
	else:
		show()
		get_node("HBoxContainer/VBoxContainer2/Name").set_text(c.creature_name)
		get_node("HBoxContainer/VBoxContainer2/Passive2/Label").set_text(c.creature_passive_text)
		get_node("HBoxContainer/VBoxContainer2/Active/Label").set_text(c.creature_active_text)
