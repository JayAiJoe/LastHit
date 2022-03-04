extends Node2D

var screen_size = Vector2.ZERO

var characters
var players
var enemies

var cards

func _ready():
	screen_size = get_viewport_rect().size
	characters = get_tree().get_nodes_in_group("Characters")
	players = get_tree().get_nodes_in_group("Players")
	enemies = get_tree().get_nodes_in_group("Enemies")
	
	cards = get_node("Control/CombatHUD/Skills").get_children()
	
	for i in range(len(cards)):
		cards[i].show_creature(Global.player.creatures[i])
	
	
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
