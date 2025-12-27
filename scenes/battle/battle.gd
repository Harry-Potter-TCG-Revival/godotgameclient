# Battle
extends Node2D

var turn_count : int

@export var local_player_stats: PlayerStats
@export var remote_player_stats: PlayerStats

@onready var turn_indicator = %TurnIndicator
@onready var turn_indicator_animation = %TurnIndicatorAnimation
@onready var player_ready_check = $PlayerReadyCheck/PlayerReadyCheck
@onready var local_player = %LocalPlayer
@onready var remote_player = %RemotePlayer


func _ready() -> void:
	# Set visibility of battle items
	turn_indicator.visible = false
	player_ready_check.visible = true
	
	var new_local_player_stats: PlayerStats = Global.local_player_stats.create_instance()
	local_player.player_stats = new_local_player_stats
	
	# These events need to have player ID as a parameter (maybe)
	# So it only runs for the desired player
	Events.ready_to_start_match.connect(ready_player_check)
	Events.current_turn_step_changed.connect(update_remote_current_turn_step)
	Events.player_turn_ended.connect(_start_opponents_turn)
	Events.increment_turn_count.connect(on_increment_turn_count)
	Events.card_drawn.connect(_on_card_drawn)
	Events.reparent_card_to_play_from_hand_requested.connect(_on_reparent_card_to_play_from_hand_requested)
	Events.update_remote_player_stats.connect(_on_update_remote_player_stats_requested)
	
	# before starting the battle
	# have start_battle be an RPC and run from host
	# need to have start battle determine starting player and send both players their starting turn step state
	#start_battle(new_local_player_stats)
	#local_player.initialize_card_pile_ui()
	#local_player.set_starting_character(local_player.player_stats.selected_deck_list.starting_character)
	## Tell the other peer that this peer has loaded
	#player_loaded.rpc(local_player.player_stats.selected_deck_list.starting_character.resource_path)

# This is just to call an RPC from a signal, might be a better way to do this.
func ready_player_check(id,turn_order_roll: int) -> void:
	server_ready_player_check.rpc(id,turn_order_roll)

@rpc("any_peer", "call_local","reliable",0)
func server_ready_player_check(id,turn_order_roll: int) -> void:
	Global.players_in_match[id].ready_status = 1
	Global.players_in_match[id].turn_order_roll = turn_order_roll
	
	# Have the host check if all players are ready
	if multiplayer.is_server():
		print("ready player check running on host")
		var readyPlayers = 0
		for i in Global.players_in_match:
			if Global.players_in_match[i].ready_status == 1:
				readyPlayers += 1
		if readyPlayers == Global.players_in_match.size():
			print("both players have readied up")
			# Need to validate that all player stats have been sent and received correctly
			# Now that all players are ready determine who goes first
			if Global.players_in_match.values()[0].turn_order_roll > Global.players_in_match.values()[1].turn_order_roll:
				# Zero Index Player is going first
				start_battle.rpc_id(Global.players_in_match.values()[0].player_id,true)
				start_battle.rpc_id(Global.players_in_match.values()[1].player_id,false)
			elif Global.players_in_match.values()[0].turn_order_roll < Global.players_in_match.values()[1].turn_order_roll:
				# Zero index is going second
				start_battle.rpc_id(Global.players_in_match.values()[0].player_id,false)
				start_battle.rpc_id(Global.players_in_match.values()[1].player_id,true)
			else :
				# This would happen if both players rolled the same number
				# Add a de-confliction, or have one of the if's be >= or <=
				pass
			
		
	

# RPC_ID is being used to call this, so only the correct parameter gets passed locally
@rpc("authority","call_local","reliable",0)
func start_battle(is_going_first:bool) -> void:
	Global.is_going_first = is_going_first
	print("start battle func for host ", multiplayer.is_server())
	player_ready_check.visible = false
	# gotta be a better way to do this. the player handler should already have this (i think)
	local_player.player_handler.start_battle(local_player.player_stats)
	local_player.initialize_card_pile_ui()
	local_player.turn_step_ui.initialize_turn_step_state_machine(true)
	# If this person is going first than the turn step needs to be initialized
	# This is to prevent extra RPC's being sent so its set manually
	# All other remote and local turn step state machines are setup with signals
	if is_going_first:
		remote_player.turn_step_ui.initialize_turn_step_state_machine(false)
	local_player.set_starting_character(local_player.player_stats.selected_deck_list.starting_character)
	# Tell the other peer that this peer has loaded
	player_loaded.rpc(local_player.player_stats.selected_deck_list.starting_character.resource_path)

@rpc("any_peer","call_remote","reliable",0)
func player_loaded(starting_character_path: String) -> void:
	# load starting character card
	var remote_player_starting_character = load(starting_character_path)
	remote_player.set_starting_character(remote_player_starting_character)
	

# This function is to run an RPC from a signal, might be a better way to do this
func _start_opponents_turn() -> void:
	# Play the animation to let the local player know the opponent turn has started
	# Maybe move this to after receiving confirmation that opponent has entered BYTS
	turn_indicator_animation.play("show_and_hide_opponents_turn")
	_start_remote_opponents_turn.rpc()

@rpc("any_peer","call_remote","reliable",0)
func _start_remote_opponents_turn() -> void:
	turn_indicator_animation.play("show_and_hide_your_turn")
	# Tell the local player to start their turn
	# Since this is being called remotely this is referencing the opponent
	local_player.turn_step_ui.on_button_exit_current_step_pressed()

func update_remote_current_turn_step(_new_state: TurnStepState):
	# Call the _on_button_exit_current_step_pressed on the remote player
	remote_player.turn_step_ui.on_button_exit_current_step_pressed.rpc()

# This function is to run an RPC from a signal, might be a better way to do this
func on_increment_turn_count() -> void:
	increment_remote_turn_count.rpc()

@rpc("any_peer","call_local","reliable",0)
func increment_remote_turn_count() -> void:
	# Only the host should have the turn count
	if multiplayer.is_server():
		turn_count += 1

func _on_mouse_entered() -> void:
	var hand_hover_tween := create_tween()
	hand_hover_tween.tween_property(self,"position",Vector2(0,-100),.02).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
 
func _on_card_drawn(value: Card,card_name: String):
	#var remote_card_to_draw : Card = load("res://cards/resources/HarryHunting.tres")
	# Maybe change this to route through the player handler
	remote_player.hand.add_remote_card.rpc(value.resource_path,card_name)

func _on_reparent_card_to_play_from_hand_requested(value: CardUI):
	# Pass the node name to allow the remote player to find the name by name and move it
	remote_player.player_handler.reparent_remote_card_to_play_from_hand.rpc(value.name)

func _on_update_remote_player_stats_requested(t_power: int,c_power: int,p_power: int,mc_power: int,q_power: int,
	max_action_count: int,action_count: int) -> void:
	# Tell the remote player to update the stats, this updates the visuals
	remote_player.player_stats_ui.update_remote_player_stats.rpc(t_power,c_power,p_power,mc_power,q_power,
	max_action_count,action_count)
