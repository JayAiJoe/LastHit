extends Node2D

var creature

var zone_radius = 50

var combat_master = null

func _ready():
	randomize()
	creature = Creature.new()
	
	combat_master = get_parent()
	
func set_creature(cid):
	creature.set_creature(cid)
	#enemy stats
	set_zone_radius(120)
	set_armor_class(1)
	set_max_hp(30)
	set_current_hp(30)
	roll_initiative(1, 1)
	
	#visuals
	$DropZone.type = 2
	$LifeBar/Life.set_text(str(creature.current_hp) + "/" + str(creature.max_hp))
	$StaticSprite.hide()
	$AnimatedSprite.hide()
	var sprite = $StaticSprite
	if creature.animated:
		sprite = $AnimatedSprite
	else:
		sprite.set_texture(load(creature.image_path))
	sprite.scale = Vector2(1,1) * creature.scale
	sprite.show()

func roll_initiative(minimum, maximum):
	creature.initiative = randi() % (maximum-minimum+1) + minimum

func set_zone_radius(radius):
	zone_radius = radius
	$DropZone.radius = radius
	$DropZone.update()

func set_max_hp(hp):
	creature.max_hp = hp
	$LifeBar.max_value = hp

func set_current_hp(hp):
	creature.current_hp = max(min(hp, creature.max_hp), 0)
	$LifeBar.value = creature.current_hp
	$LifeBar/Life.set_text(str(creature.current_hp) + "/" + str(creature.max_hp))

func set_armor_class(ac):
	creature.armor_class = ac
	$ArmorClass/Armor.text = str(ac)

#called when a die is dropped on this encounter's dropzone
func take_hit(dmg : int, roll : int):
	if roll > creature.armor_class:
		if roll == 20:
			set_current_hp(creature.current_hp - dmg*creature.crit_multiplier)
		else:
			set_current_hp(creature.current_hp - dmg)
		play_hit_animation()
	if creature.current_hp == 0:
		combat_master.end_encounter()
		

#called on turn start
func play_turn():
	print(creature.creature_name + " did a turn!")
	$Timer.wait_time = 0.5
	$Timer.start()
	yield($Timer, "timeout")
	if combat_master != null:
		ServerConnection.send_enemy_action(randi()%combat_master.players.size()+1, 5)

func play_hit_animation():
	$Timer.wait_time = 0.2
	$Timer.start()
	$AnimatedSprite.modulate = Color.webmaroon
	$AnimatedSprite.playing = false
	yield($Timer, "timeout")
	$AnimatedSprite.modulate = Color.white
	yield($Timer, "timeout")
	$AnimatedSprite.modulate = Color.webmaroon
	yield($Timer, "timeout")
	$AnimatedSprite.modulate = Color.white
	$AnimatedSprite.playing = true

func get_sprite_path():
	return $StaticSprite.texture.resource_path
