class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 1
const HAND_DISCARD_INTERVAL := 0.25

var is_local_player : bool

@export var hand: Hand
@export var player_stats: PlayerStats
@onready var turn_step_ui = %TurnStepUI


# turned off until it gets moved and setup as a signal
#@onready var turn_indicator_animation = %TurnIndicatorAnimation
@onready var player = $".."
@onready var in_play_adventure = %InPlayAdventure
@onready var in_play_match = %InPlayMatch
@onready var in_play_location = %InPlayLocation
@onready var in_play_creatures = %InPlayCreatures
@onready var in_play_items = %InPlayItems
@onready var in_play_lessons = %InPlayLessons
@onready var in_play_events = %InPlayEvents
@onready var in_play_characters = %InPlayCharacters

# This array will hold all cards in play for the player
var cards_in_play : Array[Card]

func _ready() -> void:
	# Only connect events if controlling local player
	if player.is_local_player:
		Events.initial_turn_step_entered.connect(_on_initial_turn_step_entered)
		Events.current_turn_step_changed.connect(_on_current_turn_step_changed)
		Events.draw_cards_requested.connect(draw_cards)
		Events.draw_specific_cards_requested.connect(draw_specific_cards)
		Events.discard_card_requested.connect(discard_card)
		Events.discard_cards_requested.connect(discard_cards)
		Events.on_card_draw_button_pressed.connect(_on_card_draw_button_pressed)
		Events.card_resolved.connect(_on_card_resolved)
		Events.reparent_card_to_play_from_hand_requested.connect(reparent_card_to_play_from_hand)
	

func start_battle(value: PlayerStats) -> void:
	player_stats = value
	hand.player_stats = value
	draw_opening_hand()

func draw_opening_hand():
	draw_cards(player_stats.cards_in_opening_hand)
	# Setup mulligan function
	#start_turn()

func _on_initial_turn_step_entered(initial_state: TurnStepState) -> void:
	# Depending on what state we are in, call the correct function
	match initial_state.state:
		TurnStepState.State.BEFOREYOURTURN:
			_on_before_your_turn_step_started()
		TurnStepState.State.OPPONENTSTURN:
			# Both players have already entered into their initial state, no need to pass that info over the network
			pass
		
	

func _on_current_turn_step_changed(new_state: TurnStepState) -> void:
	# Depending on what state we are in, call the correct function
	match new_state.state:
		TurnStepState.State.BEFOREYOURTURN:
			_on_before_your_turn_step_started()
		TurnStepState.State.DRAW:
			_on_draw_step_started()
		TurnStepState.State.CREATUREDAMAGE:
			_on_creature_damage_step_started()
		TurnStepState.State.ACTION:
			_on_action_step_started()
		TurnStepState.State.ENDOFYOURTURN:
			_on_end_of_your_turn_step_started()
		TurnStepState.State.OPPONENTSTURN:
			# Tell the battle manager this player has ended their turn
			Events.player_turn_ended.emit()
		
	

@rpc("any_peer","call_remote","reliable",0)
func _on_remote_current_turn_step_changed(new_state_int: TurnStepState.State) -> void:
	# Convert the integer to the actual state
	print("the remotely called new state is ", new_state_int)
	var new_state = TurnStepState.State.keys()[new_state_int]
	print("the remotely called index state is ", new_state_int)
	_on_current_turn_step_changed(new_state)

func _on_before_your_turn_step_started() -> void:
	# Reset Player Action Count to 2
	player_stats.reset_action_count()
	
	# Check registered cards for before your turn effects
	# Set Action Count to 1 if less than 1
	# Now that this step is done let the UI know
	turn_step_ui.current_state_ready_to_exit()

func _on_draw_step_started() -> void:
	# Draw for draw step
	draw_cards_in_draw_step(player_stats.cards_per_turn)
	# Check registered cards for draw step effects
	# Now that this step is done let the UI know
	turn_step_ui.current_state_ready_to_exit()

func _on_creature_damage_step_started() -> void:
	# Let the player use abilities that don't require actions
	player_stats.can_activate_abilities = true
	
	# Need to have cards in play re-check playability at this point
	# Creatures do damage (one at a time)
	# Check registered cards for creature damage step effects
	# Now that this step is done let the UI know
	turn_step_ui.current_state_ready_to_exit()

func _on_action_step_started() -> void:
	# Let the player use actions
	player_stats.can_use_actions = true
	
	# Check what cards in hand can be played now
	hand.check_cards_in_hand_playability()
	
	# Check registered cards for action step effects
	# Now that this step is done let the UI know
	turn_step_ui.current_state_ready_to_exit()

func _on_end_of_your_turn_step_started() -> void:
	# Block the player from using actions or activating abilities
	player_stats.can_activate_abilities = false
	player_stats.can_use_actions = false
	
	# Check what cards in hand can be played now
	hand.check_cards_in_hand_playability()
	# Need to have cards in play re-check playability at this point
	
	# Check registered cards for end of your turn effects
	# Now that this step is done let the UI know
	turn_step_ui.current_state_ready_to_exit()

func start_turn() -> void:
	pass
	

func draw_card() -> void:
	hand.add_card(player_stats.deck.draw_card())

func draw_cards(amount: int) -> void:
	#var tween := create_tween()
	for i in range(amount):
		var tween := create_tween()
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	

func draw_cards_in_draw_step(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	

func draw_specific_card(card_to_draw: Card) -> void:
	hand.add_card(player_stats.deck.draw_specific_card(card_to_draw))

func draw_specific_cards(cards_to_draw: CardPile) -> void:
	for card_to_draw in cards_to_draw.cards:
		draw_specific_card(card_to_draw)
		await get_tree().create_timer(HAND_DRAW_INTERVAL).timeout

func _on_card_draw_button_pressed():
	player_stats.action_count -= 1
	draw_cards(1)


func reparent_card_to_play_from_hand(child: CardUI) -> void:
	# Add and remove groups
	if player.is_local_player:
		child.remove_from_group("local_hand")
		child.add_to_group("local_inplay")
	else:
		child.remove_from_group("remote_hand")
		child.add_to_group("remote_inplay")
		child.card_back_image.visible = false
	# Check Card Type and reparent it to its appropriate spot
	# Since some cards can have multiple types the order here is important
	if child.card.type_character:
		child.reparent(in_play_characters)
		in_play_characters.update_cards_grid(player.is_local_player)
	elif child.card.type_creature:
		child.reparent(in_play_creatures)
		in_play_creatures.update_cards_grid(player.is_local_player)
	elif child.card.type_item:
		child.reparent(in_play_items)
		in_play_items.update_cards_grid(player.is_local_player)
	elif child.card.type_lesson:
		in_play_lessons.reparent_card_to_in_play_lessons(child,player.is_local_player)
	elif child.card.type_adventure:
		child.reparent(in_play_adventure)
		in_play_adventure.update_cards_grid(player.is_local_player)
	else:
		child.reparent_requested_hand.emit(self)
		return
	

@rpc("any_peer","call_remote","reliable",0)
func reparent_remote_card_to_play_from_hand(card_name: String) -> void:
	var remote_card_ui: CardUI
	var cards_in_remote_hand = get_tree().get_nodes_in_group("remote_hand")
	
	# Loop through each card and find the correct name
	for card in cards_in_remote_hand:
		if card.name == card_name:
			remote_card_ui = card
	
	# Reparent the cardUI
	reparent_card_to_play_from_hand(remote_card_ui)
	# Update the cards in hand layout now that the card is no longer a child of the hand
	hand._update_cards()

func _on_card_resolved(resolved_card: Card) -> void:
	if resolved_card.type_spell:
		discard_card(resolved_card)

func discard_card(card_to_discard: Card) -> void:
	print("discard card : ", card_to_discard.cardname)
	# Add card to discard
	player_stats.discard.add_card(card_to_discard)
	
	# Check where if card is, and tell its parent to handle it
	if card_to_discard.card_ui.card_in_hand:
		hand.discard_card(card_to_discard.card_ui)
	elif card_to_discard.card_ui.card_in_play:
		card_to_discard.card_ui.leave_play()
		Global.cards_in_play.erase(card_to_discard)
		player.discard_card(card_to_discard.card_ui)
	else:
		# If its not in the hand or inplay we can just get rid of it here.
		card_to_discard.card_ui.queue_free()
	

func discard_cards(cards_to_discard: CardPile):
	print("player handler discard cards")
	for card_to_discard in cards_to_discard.cards:
		discard_card(card_to_discard)
		await get_tree().create_timer(HAND_DISCARD_INTERVAL).timeout
	
