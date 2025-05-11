class_name Card
extends Resource

signal update_once_per_game_ability_state # need to add boolean to reset ability state
signal update_card_is_valid_choice_requested(value: bool)

enum SetName {BASE}
enum Rarity {RARE, UNCOMMON, COMMON}

@export_group("Card Attributes")
@export var setname: SetName
@export var setnumber: int
@export var cardname: String
@export var rarity: Rarity
@export var powercost: int
# The action cost for a card needs to be changed to the game or player handler
@export var actioncost : int
@export var care_of_magical_creatures_power_provided_amount: int
@export var charms_power_provided_amount: int
@export var potions_power_provided_amount: int
@export var transfiguration_power_provided_amount: int
@export var quidditch_power_provided_amount: int
@export_enum("CARE_OF_MAGICAL_CREATURES", "CHARMS", "POTIONS", "TRANSFIGURATION", "QUIDDITCH") var powerneeded_type: String
@export var artist: String

@export_subgroup("Type")
@export var type_adventure: bool
@export var type_character: bool
@export var type_creature: bool
@export var type_item: bool
@export var type_lesson: bool
@export var type_spell: bool

@export_subgroup("SubType")
@export var subtype_bird: bool
@export var subtype_cauldron: bool
@export var subtype_cat : bool
@export var subtype_deer: bool
@export var subtype_dog: bool
@export var subtype_dragon: bool
@export var subtype_ghost: bool
@export var subtype_gryffindor: bool
@export var subtype_healing: bool
@export var subtype_hufflepuff: bool
@export var subtype_kelpie: bool
@export var subtype_owl: bool
@export var subtype_rat: bool
@export var subtype_ravenclaw: bool
@export var subtype_slytherin: bool
@export var subtype_snake: bool
@export var subtype_spider: bool
@export var subtype_toad: bool
@export var subtype_troll: bool
@export var subtype_unicorn: bool
@export var subtype_wand: bool
@export var subtype_witch: bool
@export var subtype_wizard: bool
@export var subtype_wolf: bool

@export_group("Card Text")
@export_multiline var rulestexteffect: String
@export_multiline var rulestexttoSolve: String
@export_multiline var rulestextreward: String
@export_multiline var flavortext: String

@export_group("Card Visuals")
@export var card_image: Texture
@export var card_back_image: Texture

@export var is_valid_choice: bool : set = _set_is_valid_choice

func _init():
	# This is make each resource unique and not be shared
	resource_local_to_scene = true

func play(player_stats: PlayerStats) -> void:
	Events.card_played.emit(self)
	player_stats.action_count -= actioncost
	

func goes_in_play() -> bool:
	# All types except spells go into play, return true or false
	return !type_spell

func spell_effect(_player_stats: PlayerStats) -> void:
	# Each card will have its own spell effect code
	pass

func update_max_action_count(gain_action:bool, amount:int, player_stats: PlayerStats) -> void:
	# Both methods need to update both max and current count
	if gain_action:
		player_stats.max_action_count += amount
		player_stats.action_count += amount
	else:
		player_stats.max_action_count -= amount
		player_stats.action_count -= amount

func enter_play(_player_stats: PlayerStats):
	# Each card will have its own enter play code
	pass

func enter_play_update_power(player_stats: PlayerStats):
	# Update Power for All Types
	# Power is set at each cards so this one function works for all cards
	player_stats.care_of_magical_creatures_power_count += care_of_magical_creatures_power_provided_amount
	player_stats.charms_power_count += charms_power_provided_amount
	player_stats.potions_power_count += potions_power_provided_amount
	player_stats.transfiguration_power_count += transfiguration_power_provided_amount
	player_stats.quidditch_power_count += quidditch_power_provided_amount

func leave_play(_player_stats: PlayerStats):
	# Each card will have its own leave play code
	pass

func leave_play_upate_power(player_stats: PlayerStats):
	# Update Power for All Types
	# Power is set at each cards so this one function works for all cards
	player_stats.care_of_magical_creatures_power_count -= care_of_magical_creatures_power_provided_amount
	player_stats.charms_power_count -= charms_power_provided_amount
	player_stats.potions_power_count -= potions_power_provided_amount
	player_stats.transfiguration_power_count -= transfiguration_power_provided_amount
	player_stats.quidditch_power_count -= quidditch_power_provided_amount

func _set_is_valid_choice(value: bool) -> void:
	is_valid_choice = value
	update_card_is_valid_choice_requested.emit(is_valid_choice)

func apply_effects(_targets: Array[Node]) -> void:
	# Each card will have its own apply effects code, and some multiple
	pass

func activated_ability(_player_stats: PlayerStats) -> void:
	# Each card will have its own ability code
	pass 

func selection_filter(_value: Card) -> bool:
	# Return false by default, each card to override if needed
	return false

func selection_sort(_card_a: Card,_card_b: Card) -> bool:
	# Return false by default, each card to override if needed
	return false

func check_selected_cards_is_valid(_card_array: Array[Card]) -> bool:
	# Return false by default, each card to override if needed
	return false

func effect_finished() -> void:
	# Set the active card to null when the cards effects have been completed.
	Global.active_card = null

#Card Deck Size - 115 - 159
#Card Browser - 237 - 328
#Card Deck Browser - 198 - 274
#Card Highlight - 463 - 641
#Card in Hand - 202 - 280
#Card initial hand display - 282 - 390
#Card Hover in hand - 320 - 443
#Card in play (half image) - (361 - 282) -> (174 - 144)
#Card in play Hover - 363 - 503
#Card in play Investigate - 466 - 645
