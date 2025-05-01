extends Panel

@export var player_id : int
@export var player_name : String : set = _set_player_name

@onready var player_text = $CardVisuals/PlayerText

func _ready():
	print("Player id is : " , player_id)
	print("Multiplayer id is : " , multiplayer.get_unique_id())

func _set_player_name(value: String):
	await self.ready
	player_name = value
	player_text.text = player_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if player_id == multiplayer.get_unique_id():
	if player_name == Global.session.username:
		self.global_position = lerp(self.global_position, self.get_global_mouse_position() - self.size/2, 25 * delta)
		sync_position.rpc(self.global_position)
	

@rpc("any_peer")
func sync_position(p):
	self.global_position = p
