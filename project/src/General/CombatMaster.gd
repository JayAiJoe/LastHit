extends Node2D

var screen_size = Vector2.ZERO

var TeamSlot = preload("res://src/Players/TeamSlot.tscn")

var characters
var players
var enemies
var team

var cards

var active_character
var character_turn_index = 0

onready var chat_box := $ChatBox

func _ready():
	screen_size = get_viewport_rect().size
	characters = get_tree().get_nodes_in_group("Characters")
	players = get_tree().get_nodes_in_group("Players")
	enemies = get_tree().get_nodes_in_group("Enemies")
	cards = get_node("Control/CombatHUD/Skills").get_children()
	team = $Team
	
	ServerConnection.connect("initial_state_received", self, "_on_ServerConnection_initial_state_received")
	ServerConnection.connect("character_spawned", self, "_on_ServerConnection_character_spawned")
	ServerConnection.connect("next_encounter", self, "_on_ServerConnection_encounter_started")
	ServerConnection.connect("character_action_received" , self, "_on_ServerConnection_character_action_received")
	ServerConnection.connect("turn_id_received", self, "_on_ServerConnection_turn_id_received")
	ServerConnection.send_spawn(ServerConnection.username)
	
	
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
	
func _on_ServerConnection_encounter_started(biome : String, boss : String): 
	for i in range(len(cards)):
		cards[i].show_creature(Global.player.creatures[i]) #if error occurs, try running ChooseStarterMenu first
		
	$Background.set_texture(Global.bgs[biome])
	$EnemySprite.set_creature(boss)
	
	$DiceTray.set_dice(Global.player.dice)
	$TurnQueue.on_encounter_start()
	
	start_turn()
		
func start_encounter():
	pass
	
func start_turn():
	active_character = characters[character_turn_index]
	active_character.play_turn()
	
func end_turn():
	$TurnQueue.move_queue()
	character_turn_index = (character_turn_index+1)%(characters.size())
	if $EnemySprite.creature.current_hp > 0:
		start_turn()
	
func end_encounter():
	$StartButton.disabled = false
	$DiceTray.clear_dice()
	$TurnQueue.on_encounter_end()
	Global.encounter_end()
	if Global.encounter % 3 == 0:
		print("campfire time")
		$Background.set_texture(load("res://src/Assets/Biomes/campfire.jpg"))
	else:
		start_encounter()
		

func play_turn():
	active_character = characters[character_turn_index]
	character_turn_index = (character_turn_index+1)%(characters.size())
	ServerConnection.send_turn_id(active_character.id)
	yield(active_character.play_turn(), "completed")
	$TurnQueue.move_queue()

	
#Chat
func activate_chat():
	chat_box.visible = true
	
func _on_ChatBox_text_sent(text) -> void:
	ServerConnection.send_text_async(text) #async yield

func _on_chat_message_received(sender_name, text) -> void:
	chat_box.add_reply(text, sender_name)
	
	
#In-game Functions
func join_campaign(character_states: Dictionary) -> void:
	var user_id := ServerConnection.get_user_id()
	assert(character_states.has(user_id), "Server did not return valid state")
	for c in character_states:
		if c != user_id:
			spawn(c)
			
	ServerConnection.connect("chat_message_received", self, "_on_chat_message_received")
	activate_chat()

	

func _on_ServerConnection_initial_state_received(character_states: Dictionary) -> void:
	ServerConnection.disconnect("initial_state_received", self, "_on_ServerConnection_initial_state_received")

	join_campaign(character_states)

func _on_ServerConnection_turn_id_received(turn_id : String) -> void:
	Global.turn_id = turn_id

func _on_ServerConnection_character_action_received(actor_id : String, action_id : int, targets: Array, dice_value : int):
	for t in targets:
		if t < 0:
			var te = -1 - t
			if te < enemies.size():
				enemies[te].take_hit(5, dice_value)
		else:
			if t < players.size():
				players[t].take_hit(5)

func spawn(id : String):
	var p = TeamSlot.instance()
	team.add_child(p)
	var p_sprite = p.get_child(0)
	p_sprite.id = id
	p_sprite.add_to_group("Characters")
	p_sprite.add_to_group("Players")
	players = get_tree().get_nodes_in_group("Players")
	characters = get_tree().get_nodes_in_group("Characters")

func _on_ServerConnection_character_spawned(id : String, name : String):
	spawn(id)
	
func _on_StartButton_pressed():
	ServerConnection.send_next_encounter()
	$StartButton.disabled = true
	ServerConnection.send_fetch_state()
