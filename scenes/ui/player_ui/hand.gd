class_name Hand
extends ColorRect

const CARD_UI_SCENE := preload("res://scenes/ui/card_ui/card_ui.tscn")

@onready var player = $".."

@export var player_stats: PlayerStats : set = _set_player_stats
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var max_rotation_degrees : int
@export var x_sep := -10
@export var y_min := 0
@export var y_max : int
@export var hand_disabled : bool = false

var card_ui_reference: CardUI = Global.card_ui_reference
# Used to restore hand after tween
var start_position: Vector2

func _ready() -> void:
	# When a card is played the cards in hand need to be updated
	Events.card_played.connect(_on_card_played)
	
	# When a card is being dragged the hand needs 
	Events.card_drag_started.connect(_disable_hand)
	Events.card_drag_ended.connect(_enable_hand)
	
	start_position = self.position

func add_card(card: Card) -> void:
	var new_card_ui := CARD_UI_SCENE.instantiate() as CardUI
	add_child(new_card_ui)
	new_card_ui.reparent_requested_hand.connect(_on_card_ui_reparent_requested_hand)
	# The card here is duplicated to make the same cards do not share the same resource
	new_card_ui.card = card.duplicate()
	new_card_ui.card.card_ui = new_card_ui
	new_card_ui.parent = self
	# Only set player stats for the card if its for the local player
	# Signals and other functions run when player stats are connected
	new_card_ui.add_to_group("local_hand")
	new_card_ui.name = Global.session.username + "cardUI" + player_stats.request_cardui_id()
	print("local card added is named ", new_card_ui.name)
	new_card_ui.player_stats = player_stats
	new_card_ui.card.player_owner = Global.session.username
	new_card_ui.card.player_controller = Global.session.username
	new_card_ui.card_back_image.visible = false
	new_card_ui.check_playability()
	_update_cards()
	# Tell game that you drew a card
	Events.card_drawn.emit(card,new_card_ui.name)

@rpc("any_peer","call_remote","reliable",0)
func add_remote_card(card_path: String,new_card_name: String) -> void:
	var card : Card = load(card_path)
	var new_card_ui := CARD_UI_SCENE.instantiate() as CardUI
	add_child(new_card_ui)
	new_card_ui.card = card.duplicate()
	new_card_ui.parent = self
	new_card_ui.name = new_card_name
	new_card_ui.add_to_group("remote_hand")
	new_card_ui.disabled = true
	new_card_ui.set_visuals_for_remote_cardui()
	_update_cards()

func discard_card(card_ui_to_discard: CardUI) -> void:
	card_ui_to_discard.queue_free()
	_update_cards()

func _on_card_played(_card: Card) -> void:
	_update_cards()

func _update_cards() -> void:
	var hand_size := get_child_count()
	max_rotation_degrees = clamp(hand_size,0,15)
	y_max = clamp(hand_size * 5,0,50)
	var total_hand_width := card_ui_reference.card_size.x * hand_size + x_sep * (hand_size - 1)
	var final_x_sep : float = x_sep
	
	if total_hand_width > size.x:
		final_x_sep = (size.x - card_ui_reference.card_size.x * hand_size) / (hand_size - 1)
		total_hand_width = size.x
	
	var offset := (size.x - total_hand_width) / 2
	
	for i in hand_size:
		var card_ui := get_child(i)
		var y_multiplier := hand_curve.sample(1.0 / (hand_size-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (hand_size-1) * i)
		
		if hand_size == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
		
		var final_x: float = offset + card_ui_reference.card_size.x * i + final_x_sep * i
		var final_y: float = y_min + y_max * y_multiplier
		
		card_ui.position = Vector2(final_x, final_y)
		card_ui.rotation_degrees = max_rotation_degrees * rot_multiplier
	

func _on_card_ui_reparent_requested_hand(child: CardUI) -> void:
	# Just reparent the card back into the hand.
	child.reparent(self)
	_update_cards()
	print("reparented card to hand ", child.card.cardname)

func _set_player_stats(value: PlayerStats):
	player_stats = value
	if not player_stats.stats_changed.is_connected(_on_player_stats_changed):
		# Refactor the player can call this function
		player_stats.stats_changed.connect(_on_player_stats_changed)

func _on_player_stats_changed():
	_check_cards_in_hand_playability()

func _check_cards_in_hand_playability():
	# This will set the cards playable border
	for child in get_children():
		if child is CardUI:
			child.playable = player_stats.can_play_card(child.card)
		
	


func _on_mouse_entered():
	# If the hand is disabled just return
	if hand_disabled or !player.is_local_player:
		return
	
	var hand_scale_factor = 1.3
	var target_x_position = (size.x * (1 - hand_scale_factor))/2
	var target_position = position + Vector2(target_x_position,-100)
	var tween_position = get_tree().create_tween()
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property(self,"scale",Vector2(hand_scale_factor,hand_scale_factor),0.2)
	tween_position.tween_property(self, "position", target_position, 0.2)
	


func _on_mouse_exited():
	# If the hand is disabled just return
	if hand_disabled or !player.is_local_player:
		return
	
	var tween_position = get_tree().create_tween()
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property(self,"scale",Vector2(1,1),0.2)
	tween_position.tween_property(self,"position",start_position,0.2)
	

func _disable_hand(_value: CardUI):
	# Shrink the hand because a card is selected
	_on_mouse_exited()
	hand_disabled = true

func _enable_hand(_value: CardUI):
	hand_disabled = false
