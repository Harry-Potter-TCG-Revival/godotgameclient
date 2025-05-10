class_name PlayerStats
extends Stats

@export var player_name: String
@export var selected_deck_list: DeckList
@export var deck_lists: Array[DeckList]
@export var player_avatar: Texture
@export var card_back: Texture

# These three settings need to get inherited from the game manager
# This allows different game modes to exist
@export var cards_per_turn: int
@export var cards_in_opening_hand: int
@export var max_action_count := 2


var action_count: int : set = set_action_count
var transfiguration_power_count: int : set = set_transifiguration_power_count
var potions_power_count: int : set = set_potions_power_count
var charms_power_count: int : set = set_charms_power_count
var care_of_magical_creatures_power_count: int : set = set_care_of_magical_creatures_power_count
var quidditch_power_count: int : set = set_quidditch_power_count
var total_power_count : int : set = set_total_power_count
var deck: CardPile
var discard: CardPile

func set_action_count(value: int) -> void:
	action_count = value
	stats_changed.emit()

func set_transifiguration_power_count(value: int) -> void:
	transfiguration_power_count = value
	set_total_power_count(value)
	stats_changed.emit()

func set_potions_power_count(value: int) -> void:
	potions_power_count = value
	set_total_power_count(value)
	stats_changed.emit()

func set_charms_power_count(value: int) -> void:
	charms_power_count = value
	set_total_power_count(value)
	stats_changed.emit()

func set_care_of_magical_creatures_power_count(value: int) -> void:
	care_of_magical_creatures_power_count = value
	set_total_power_count(value)
	stats_changed.emit()

func set_quidditch_power_count(value: int) -> void:
	quidditch_power_count = value
	set_total_power_count(value)
	stats_changed.emit()

func set_total_power_count(_value: int) -> void:
	total_power_count = (transfiguration_power_count) \
	+ (charms_power_count) \
	+ (potions_power_count) \
	+ (care_of_magical_creatures_power_count) \
	+ (quidditch_power_count)

func reset_action_count() -> void:
	self.action_count = max_action_count

func can_play_card(card: Card) -> bool:
	# The action cost for a card needs to be changed to the game or player handler
	var actions_needed = action_count >= card.actioncost
	var power_needed =  total_power_count >= card.powercost
	var power_needed_type
	if card.powerneeded_type == "CARE_OF_MAGICAL_CREATURES":
		power_needed_type = care_of_magical_creatures_power_count > 0
	elif card.powerneeded_type == "CHARMS":
		power_needed_type = charms_power_count > 0
	elif card.powerneeded_type == "POTIONS":
		power_needed_type = potions_power_count > 0
	elif card.powerneeded_type == "TRANSFIGURATION":
		power_needed_type = transfiguration_power_count > 0
	elif card.powerneeded_type == "QUIDDITCH":
		power_needed_type = quidditch_power_count > 0
	else : # This is set to true so cards that dont have a power type needed can still be played.
		power_needed_type = true

	return actions_needed and power_needed and power_needed_type
	

func create_instance() -> Resource:
	var instance: PlayerStats = self.duplicate()
	instance.reset_action_count()
	# This is just doing main deck, need to figure out sideboard
	instance.deck = instance.selected_deck_list.main_deck.duplicate()
	instance.discard = CardPile.new()
	return instance
