class_name  PlayerStatsUI
extends ColorRect

@export var player_stats: PlayerStats : set = _set_player_stats

@onready var power_stats_ui = %PowerStatsUI
@onready var action_stats_ui = %ActionStatsUI
@onready var stats_ui_container = %StatsUIContainer

func _set_player_stats(value: PlayerStats) -> void:
	
	if not is_node_ready():
		await  ready
	
	player_stats = value
	action_stats_ui.player_stats = player_stats
	power_stats_ui.player_stats = player_stats

func set_remote_player_visuals() -> void:
	stats_ui_container.rotation_degrees = 180

@rpc("any_peer","call_remote","reliable",0)
func update_remote_player_stats(t_power: int,c_power: int,p_power: int,mc_power: int,q_power: int,
	max_action_count: int,action_count: int) -> void:
		# Tell the action stats UI to update the visuals this runs even if the number is the same
		action_stats_ui.update_remote_player_stats(max_action_count,action_count)
		
		# Tell the power stats UI to update the visuals this runs even if the numbers are the same
		power_stats_ui.update_remote_player_stats(t_power,c_power,p_power,mc_power,q_power)
