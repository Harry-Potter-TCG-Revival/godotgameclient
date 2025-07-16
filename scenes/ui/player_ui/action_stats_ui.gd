class_name ActionStatsUI
extends VBoxContainer

@export var player_stats: PlayerStats : set = _set_player_stats

@onready var action_label = %ActionLabel

var out_of_actions: bool = false

func _ready():
	pass

func _set_player_stats(value: PlayerStats) -> void:
	player_stats = value
	
	if not player_stats.stats_changed.is_connected(_on_action_stats_changed):
		player_stats.stats_changed.connect(_on_action_stats_changed)
	
	if not is_node_ready():
		await  ready
	
	_on_action_stats_changed()

func _on_action_stats_changed() -> void:
	action_label.text = "%s / %s" % [player_stats.action_count, player_stats.max_action_count]
	
	if player_stats.action_count == 0:
		out_of_actions = true
		Events.out_of_actions.emit()
	
	# Only send this signal is the player was previously out of actions
	if out_of_actions and player_stats.action_count >= 1:
		out_of_actions = false
		Events.not_out_of_actions.emit()
