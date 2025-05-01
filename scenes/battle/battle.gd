extends Node2D

@export var player_scene : PackedScene

var spawnpoints

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the spawnpoints
	spawnpoints = get_tree().get_nodes_in_group("Group_Spawnpoints")
	
	spawn_players()
	

func spawn_players():
		# Spawn all players
	for i in Global.players_in_match:
		var new_player = player_scene.instantiate()
		new_player.player_id = Global.players_in_match[i].player_id
		new_player.name = str(Global.players_in_match[i].player_id) + "_player"
		new_player.player_name = str(Global.players_in_match[i].player_username)
		add_child(new_player)
		
		# Determine players starting position based on host
		if Global.player_is_host:
			new_player.global_position = spawnpoints[0].global_position
		else:
			new_player.global_position = spawnpoints[1].global_position
		
	
