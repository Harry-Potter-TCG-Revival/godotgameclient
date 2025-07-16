class_name  PlayerStatsUI
extends ColorRect

@export var player_stats: PlayerStats : set = _set_player_stats

@onready var power_stats_ui = %PowerStatsUI
@onready var action_stats_ui = %ActionStatsUI

func _set_player_stats(value: PlayerStats) -> void:
	
	if not is_node_ready():
		await  ready
	
	player_stats = value
	action_stats_ui.player_stats = player_stats
	power_stats_ui.player_stats = player_stats
