class_name CardRestrictionModifierValue
extends Node

enum ExpirationUnits {ACTIONS,TURNS}

@export var can_expire: bool = false
@export var duration: int
@export var expirationunit: ExpirationUnits
@export var source: String

@export_group("Card Restrictions")
# Card Type Based Restriction
# By default all of these values are set to true and the card will set
# the card type to false if that affect prevents that type from being played
@export_subgroup("Restricted by Card Type")
@export var type_adventure: bool = true
@export var type_character: bool = true
@export var type_creature: bool = true
@export var type_event: bool = true
@export var type_item: bool = true
@export var type_lesson: bool = true
@export var type_location: bool = true
@export var type_match: bool = true
@export var type_spell: bool = true

# Lesson Type Based Restrictions
# By default all of these values are set to true and the card will set
# the card type to false if that affect prevents that type from being played
@export_subgroup("Restricted by Lesson Type")
@export var CARE_OF_MAGICAL_CREATURES: bool = true
@export var CHARMS: bool = true
@export var POTIONS: bool = true
@export var TRANSFIGURATION: bool = true
@export var QUIDDITCH: bool = true

# Sub Type Based Restrictions
# By default all of these values are set to true and the card will set
# the card type to false if that affect prevents that type from being played
@export_subgroup("SubType")
@export var subtype_bird: bool = true
@export var subtype_cauldron: bool = true
@export var subtype_cat : bool = true
@export var subtype_deer: bool = true
@export var subtype_dog: bool = true
@export var subtype_dragon: bool = true
@export var subtype_ghost: bool = true
@export var subtype_gryffindor: bool = true
@export var subtype_healing: bool = true
@export var subtype_hufflepuff: bool = true
@export var subtype_kelpie: bool = true
@export var subtype_owl: bool = true
@export var subtype_rat: bool = true
@export var subtype_ravenclaw: bool = true
@export var subtype_slytherin: bool = true
@export var subtype_snake: bool = true
@export var subtype_spider: bool = true
@export var subtype_toad: bool = true
@export var subtype_troll: bool = true
@export var subtype_unicorn: bool = true
@export var subtype_wand: bool = true
@export var subtype_witch: bool = true
@export var subtype_wizard: bool = true
@export var subtype_wolf: bool = true

static func create_new_modifier(modifier_source: String) -> CardRestrictionModifierValue:
	var new_modifier := new()
	new_modifier.source = modifier_source
	
	return new_modifier
