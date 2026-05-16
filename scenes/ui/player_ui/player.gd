class_name Player
extends Panel

# Get the player stats
@export var player_stats: PlayerStats : set = _set_player_stats

# Set if this is controlling the remote or local player
@export var is_local_player: bool

# Non Play Areas
@onready var player_handler = $PlayerHandler
@onready var hand = %Hand
@onready var player_avatar = %PlayerAvatar
@onready var player_name = %PlayerName
@onready var player_stats_ui = %PlayerStatsUI
@onready var card_draw_button = %CardDrawButton
@onready var deck_button = %DeckButton
@onready var discard_button = %DiscardButton
@onready var turn_step_ui = %TurnStepUI


# Play Area
@onready var card_ui_starting_character = %CardUIStartingCharacter
@onready var in_play_creatures = %InPlayCreatures
@onready var in_play_items = %InPlayItems
@onready var in_play_lessons = %InPlayLessons
@onready var in_play_adventure = %InPlayAdventure
@onready var in_play_location = %InPlayLocation
@onready var in_play_match = %InPlayMatch
@onready var in_play_events = %InPlayEvents
@onready var in_play_characters = %InPlayCharacters


func _ready() -> void:
	# Only connect events if controlling local player
	if is_local_player:
		player_handler.is_local_player = true
		# Maybe set is_local_plater turn turnstepui here, instead of parameter as part of initialize state machine
	else:
		# Setup visuals for remote player
		player_stats_ui.set_remote_player_visuals()
	

func _set_player_stats(value: PlayerStats) -> void:
	player_stats = value
	
	if not player_stats.stats_changed.is_connected(update_player_stats):
		player_stats.stats_changed.connect(update_player_stats)
	
	player_avatar.texture = player_stats.player_avatar
	player_name.text = player_stats.player_name
	
	update_player()


func update_player() -> void:
	if not player_stats is PlayerStats:
		return
	if not is_inside_tree():
		await ready
	
	player_stats_ui.player_stats = player_stats
	update_player_stats()


func update_player_stats() -> void:
	Events.update_remote_player_stats.emit(
		player_stats.transfiguration_power_count,
		player_stats.charms_power_count,
		player_stats.potions_power_count,
		player_stats.care_of_magical_creatures_power_count,
		player_stats.quidditch_power_count,
		player_stats.max_action_count,
		player_stats.action_count)
	


func initialize_card_pile_ui() -> void:
	deck_button.card_pile = player_stats.deck
	discard_button.card_pile = player_stats.discard


func set_starting_character(new_starting_character: Card) -> void:
	# Rotate the starting character to point to the local player
	if !is_local_player:
		card_ui_starting_character.rotation_degrees = -90
	card_ui_starting_character.Starting_Character = new_starting_character


func take_damage(damage_amount: int) -> void:
	# This is not being used and needs to be re-done
	player_stats.take_damage(damage_amount)


func discard_card(card_ui_to_discard: CardUI) -> void:
	# Remove the card visually
	card_ui_to_discard.queue_free()
	
	# Call the correct play area based on the card type, have cards be re-arranged.
	match card_ui_to_discard:
		card_ui_to_discard.card.type_adventure:
			# just passing here because adventure isnt setup yet.
			pass
		card_ui_to_discard.card.type_character:
			in_play_characters.update_cards_grid()
		card_ui_to_discard.card.type_creature:
			in_play_creatures.update_cards_grid()
		card_ui_to_discard.card.type_item:
			in_play_items.update_cards_grid()
		card_ui_to_discard.card.type_lesson:
			in_play_lessons.update_cards_requested()
		
	

func _on_card_draw_button_pressed() -> void:
	# move to turn step ui
	Events.on_card_draw_button_pressed.emit()
