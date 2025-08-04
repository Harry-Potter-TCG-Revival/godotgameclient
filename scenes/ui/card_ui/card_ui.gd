class_name CardUI
extends Panel

signal reparent_requested_hand(which_card_ui: CardUI)
signal selected_cards_updated

const HIGHLIGHT_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_highlight_stylebox.tres")
const HOVER_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_hover_stylebox.tres")
const STANDARD_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_standard_stylebox.tres")

var card_selected = false
var parent: Control
var tween: Tween
var playable := true : set = _set_playable
var disabled := false
var card_in_hand: bool
var card_in_play: bool
var card_size: Vector2 = Vector2(202,280)

@export var card: Card : set = _set_card
@export var player_stats: PlayerStats : set = _set_player_stats
@export var selected_cards: Array[Card]
@export var is_valid_choice: bool : set = _set_valid_choice

@onready var card_visuals = $CardVisuals
@onready var card_image = $CardVisuals/CardImage
@onready var card_back_image = $CardVisuals/CardBackImage
@onready var glow_effect = $CardVisuals/GlowEffect
@onready var statetext = $CardVisuals/CardImage/StateText
@onready var drop_point_detector = $CardVisuals/CardImage/DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var card_drop_area: Array[Node] = []
@onready var ability_used_flag = $CardVisuals/AbilityUsedFlag

# card size - MTG Arena - 448 x 320 (7 - 5 ratio)
# hptcg defaul card size - 1040 x 745 (7 - 5 ratio)
# after formatting card size down size is - 448 x 321 (locking aspect ratio)
func _ready():
	# This is temporary code to set to initiate the card state machine, this will happen on battle start
	card_state_machine.init(self)
	self.add_to_group("all_card_ui")
	
func _on_mouse_entered():
	card_state_machine.on_mouse_entered()

func _on_mouse_exited():
	card_state_machine.on_mouse_exited()

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func animate_to_position(new_position: Vector2, duration: float,new_rotation) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", new_position, duration)
	tween.tween_property(self,"rotation_degrees",new_rotation,duration)
	await tween.finished

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	# When a card is loaded into the game this handles setting all dynamic card properties, like visuals.
	card = value
	card_image.texture = card.card_image

func play() -> void:
	if not card:
		return
	
	card.play(player_stats)
	

func enter_play() -> void:
	if not card:
		return
	
	# Break out of this function since spells dont go into play
	if card.type_spell:
		return
	
	#custom_minimum_size = size/2
	#card_image.rotation_degrees = 90
	#card_image.scale = Vector2(.5,.5)
	#card_image.position = Vector2(140,0)
	Events.reparent_card_to_play_from_hand_requested.emit(self)
	play()
	card.enter_play(player_stats)
	card.enter_play_update_power(player_stats)

func leave_play() -> void:
	if not card:
		return
	
	print("CardUI leaving play")
	rotation_degrees = 0
	scale = Vector2(1,1)
	
	card.leave_play(player_stats)
	card.leave_play_upate_power(player_stats)
	
	# check if card is discarded from play
	# check if card is bounced to hand
	# check if card is shuffled into deck

func _set_playable(value: bool) -> void:
	playable = value
	if not playable:
		glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)
	else:
		glow_effect.set("theme_override_styles/panel", HIGHLIGHT_STYLEBOX)
	

func set_visuals_for_remote_cardui() -> void:
	glow_effect.set("theme_override_styles/panel",STANDARD_STYLEBOX)

func _set_player_stats(value: PlayerStats) -> void:
	player_stats = value
	player_stats.stats_changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()

func _set_valid_choice(value : bool) -> void:
	is_valid_choice = value
	if is_valid_choice:
		glow_effect.set("theme_override_styles/panel", HIGHLIGHT_STYLEBOX)
	else:
		modulate = Color(.4,.4,.4)
		glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)
	
	card_state_machine.transition_selectable_state(value)

func _reset_valid_choice(_card_pile: CardPile) -> void:
	card_state_machine.reset_selectable_state()
	print("reset selectable state using state machine")

func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	# Check if the card drop area has already been added to the card_drop_area array
	if not card_drop_area.has(area):
		card_drop_area.append(area)
	

func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	# Once we leave the card drop area we need to erase that from the card_drop_area array
	card_drop_area.erase(area)

func _on_card_drag_started(used_card: CardUI) -> void:
	# Disable cards that aren't being dragged
	if used_card == self:
		return 
	
	disabled = true

func _on_card_drag_ended(_card: CardUI) -> void:
	# Enable Cards again when drag ends
	disabled = false
	check_playability()

func _on_player_stats_changed() -> void:
	# Only need to check the playability of cards that are in the hand
	if self.card_in_hand:
		check_playability()

func check_playability() -> void:
	# Only run if the card_ui is for the local player by checking the player owner
	if self.card.player_owner == Global.session.username:
		self.playable = player_stats.can_play_card(card)
