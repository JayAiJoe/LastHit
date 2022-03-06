extends Node2D

var screen_size = Vector2.ZERO

var characters
var players
var enemies

var cards

var active_character
var character_turn_index = 0

func _ready():
	screen_size = get_viewport_rect().size
	characters = get_tree().get_nodes_in_group("Characters")
	players = get_tree().get_nodes_in_group("Players")
	enemies = get_tree().get_nodes_in_group("Enemies")
	cards = get_node("Control/CombatHUD/Skills").get_children()
	
	start_encounter()
	
static func sort_initiative(a, b) -> bool:
	return a.initiative > b.initiative

static func sort_max_hp(a, b) -> bool:
	return a.max_hp > b.max_hp

static func sort_current_hp(a, b) -> bool:
	return a.current_hp > b.current_hp

func get_player_by_initiative(index):
	players.sort_custom(self, 'sort_initiative')
	return players[index]

func get_player_by_max_hp(index):
	players.sort_custom(self, 'sort_max_hp')
	return players[index]

func get_player_by_current_hp(index):
	players.sort_custom(self, 'sort_current_hp')
	return players[index]

func get_enemy(index):
	return enemies[index]
	
func start_encounter():
	for i in range(len(cards)):
		cards[i].show_creature(Global.player.creatures[i]) #if error occurs, try running ChooseStarterMenu first
		
	print(Global.next_biome)
	$Background.set_texture(Global.bgs[Global.next_biome])
	print(Global.next_boss)
	$EnemySprite.set_creature(Global.next_boss)
	
	$DiceTray.set_dice(Global.player.dice)
	$TurnQueue.on_encounter_start()
	
	play_turn()
	
func end_encounter():
	$DiceTray.clear_dice()
	$TurnQueue.on_encounter_end()
	Global.encounter_end()
	if Global.encounter % 3 == 0:
		print("campfire time")
	else:
		start_encounter()
		
func play_turn():
	active_character = characters[character_turn_index]
	character_turn_index = (character_turn_index+1)%(characters.size())
	yield(active_character.play_turn(),"completed")
	$TurnQueue.move_queue()
	if $EnemySprite.creature.current_hp > 0:
		play_turn()
