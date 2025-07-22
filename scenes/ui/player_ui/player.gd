class_name Player
extends Panel

# Get the player stats
@export var player_stats: PlayerStats : set = _set_player_stats


# Non Play Area
@onready var player_handler = $PlayerHandler
@onready var hand = %Hand
@onready var player_avatar = %PlayerAvatar
@onready var player_name = %PlayerName
@onready var player_stats_ui = %PlayerStatsUI
@onready var end_turn_button = %EndTurnButton
@onready var card_draw_button = %CardDrawButton
@onready var deck_button = %DeckButton
@onready var discard_button = %DiscardButton


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
	Events.draw_step_completed.connect(_on_draw_step_completed)


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
	# This might not be needed since a setter function is being used to update player stats
	pass


func initialize_card_pile_ui() -> void:
	deck_button.card_pile = player_stats.deck
	discard_button.card_pile = player_stats.discard


func set_starting_character() -> void:
	card_ui_starting_character.Starting_Character = player_stats.selected_deck_list.starting_character


func take_damage(_damage: int) -> void:
	player_stats.take_damage()


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
		
	


func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.player_end_of_turn_start.emit()


func _on_card_draw_button_pressed() -> void:
	Events.on_card_draw_button_pressed.emit()


func _on_draw_step_completed() -> void:
	end_turn_button.disabled = false
	# Need to add more pieces to this
	# More than the button gets enabled, like action usage
