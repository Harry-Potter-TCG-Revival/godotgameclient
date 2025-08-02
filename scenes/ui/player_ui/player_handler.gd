class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 1
const HAND_DISCARD_INTERVAL := 0.25

@export var hand: Hand
@export var player_stats: PlayerStats

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
		Events.draw_cards_requested.connect(draw_cards)
		Events.draw_specific_cards_requested.connect(draw_specific_cards)
		Events.discard_card_requested.connect(_discard_card)
		Events.discard_cards_requested.connect(_discard_cards)
		Events.on_card_draw_button_pressed.connect(_on_card_draw_button_pressed)
		Events.card_resolved.connect(_on_card_resolved)
		Events.reparent_card_to_play_requested.connect(reparent_card_to_play)

func start_battle(value: PlayerStats) -> void:
	player_stats = value
	hand.player_stats = value
	#player_stats.deck = 
	#player_stats.deck
	#player_stats.deck.shuffle()
	#player_stats.discard = CardPile.new()
	draw_opening_hand()

func draw_opening_hand():
	draw_cards(player_stats.cards_in_opening_hand)
	start_turn()

func start_turn() -> void:
	#turn_indicator_animation.play("show_and_hide_your_turn")
	player_stats.reset_action_count()
	draw_cards_in_draw_step(player_stats.cards_per_turn)

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
	
	tween.finished.connect(
		func(): Events.draw_step_completed.emit()
	)

func draw_specific_card(card_to_draw: Card) -> void:
	hand.add_card(player_stats.deck.draw_specific_card(card_to_draw))

func draw_specific_cards(cards_to_draw: CardPile) -> void:
	for card_to_draw in cards_to_draw.cards:
		draw_specific_card(card_to_draw)
		await get_tree().create_timer(HAND_DRAW_INTERVAL).timeout

func _on_card_draw_button_pressed():
	player_stats.action_count -= 1
	draw_cards(1)

func reparent_card_to_play(child: CardUI) -> void:
	# Check Card Type and reparent it to its appropriate spot
	# Since some cards can have multiple types the order here is important
	if child.card.type_character:
		child.reparent(in_play_characters)
		in_play_characters.update_cards_grid()
	elif child.card.type_creature:
		child.reparent(in_play_creatures)
		in_play_creatures.update_cards_grid()
	elif child.card.type_item:
		child.reparent(in_play_items)
		in_play_items.update_cards_grid()
	elif child.card.type_lesson:
		in_play_lessons.reparent_card_to_in_play_lessons(child)
	elif child.card.type_adventure:
		child.reparent(in_play_adventure)
		in_play_adventure.update_cards_grid()
	else:
		child.reparent_requested_hand.emit(self)
		return
	


func _on_card_resolved(resolved_card: Card) -> void:
	if resolved_card.type_spell:
		_discard_card(resolved_card)

func _discard_card(card_to_discard: Card) -> void:
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
	

func _discard_cards(cards_to_discard: CardPile):
	print("player handler discard cards")
	for card_to_discard in cards_to_discard.cards:
		_discard_card(card_to_discard)
		await get_tree().create_timer(HAND_DISCARD_INTERVAL).timeout

func end_turn() -> void:
	# Have end of turn effects be coded here
	Events.player_end_of_turn_finished.emit()
