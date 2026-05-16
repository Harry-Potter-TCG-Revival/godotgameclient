class_name CardCostModifierValue
extends Node

# This modidifer value will be used to capture increases of action or power costs
# Example : Ron Weasley. Character Action Cost : -1
# Example : Harry Huntin. Creatures and Spells : 2

enum ExpirationUnits {ACTIONS,TURNS}

@export var can_expire: bool = false
@export var duration: int
@export var expirationunit: ExpirationUnits
@export var source: String

@export_subgroup("Card Types")
@export var adventure_cost : int = 0
@export var character_cost : int = 0
@export var creature_cost : int = 0
@export var event_cost : int = 0
@export var item_cost : int = 0
@export var lesson_cost : int = 0
@export var location_cost : int = 0
@export var match_cost : int = 0
@export var spell_cost : int = 0

static func create_new_modifier(modifier_source: String) -> CardCostModifierValue:
	var new_modifier := new()
	new_modifier.source = modifier_source
	
	return new_modifier
