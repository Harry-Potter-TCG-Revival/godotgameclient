extends Node2D

@export var local_player_stats: PlayerStats
@export var remote_player_stats: PlayerStats
@export var battle_startup: BattleStartup

@onready var turn_indicator_animation = $TurnandPhaseInfo/TurnIndicator/TurnIndicatorAnimation
@onready var local_player = %LocalPlayer
@onready var remote_player = %RemotePlayer


func _ready() -> void:
	if not battle_startup:
		return
	
	var new_local_player_stats: PlayerStats = local_player_stats.create_instance()
	local_player.player_stats = new_local_player_stats
	# Need to call RPC to tell other client to setup the instanced player stats
	# Need to accept RPC to setup remote player stats
	
	# These events need to have player ID as a parameter
	# So it only runs for the desired player
	Events.player_end_of_turn_start.connect(local_player.player_handler.end_turn)
	Events.player_end_of_turn_finished.connect(_start_opponent_turn)
	Events.opponent_turn_ended.connect(_opponent_turn_ended)
	
	# This is temporary to make the opponents turn not end immediately
	turn_indicator_animation.connect("animation_finished",_opponent_turn_ended)
	
	# Need to validate that all player stats have been sent and received correctly
	# before starting the battle
	# A ready up button maybe if it cant detect automatically
	# have start_battle be an RPC and run from host
	start_battle(new_local_player_stats)
	local_player.initialize_card_pile_ui()
	local_player.set_starting_character()

func start_battle(stats: PlayerStats) -> void:
	local_player.player_handler.start_battle(stats)

func _start_opponent_turn() -> void:
	#Send signal to opponent their turn has begun
	#get_tree().create_timer(1.5).timeout.connect(_opponent_turn_ended)
	turn_indicator_animation.play("show_and_hide_opponents_turn")

func _opponent_turn_ended(animation_name) -> void:
	if animation_name == "show_and_hide_opponents_turn":
		local_player.player_handler.start_turn()

func _on_mouse_entered() -> void:
	var hand_hover_tween := create_tween()
	hand_hover_tween.tween_property(self,"position",Vector2(0,-100),.02).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
