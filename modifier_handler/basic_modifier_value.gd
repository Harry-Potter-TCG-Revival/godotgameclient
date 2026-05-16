class_name BasicModifierValue
extends Node

# FLAT, adjusts the amount by a set value, positive and negative
# PERCENT, adjusts the amount by a percent, positive and negative
# SET, does not adjust the value, but sets it to a value, overriding other types
enum Type {FLAT,PERCENT,SET}
enum ExpirationUnits {ACTIONS,TURNS}

@export var can_expire: bool = false
@export var duration: int
@export var expirationunit: ExpirationUnits
@export var type: Type
@export var flat_value: int
@export var percent_value: float
@export var set_value: int
@export var source: String

static func create_new_modifier(modifier_source: String, modifier_type: Type) -> BasicModifierValue:
	var new_modifier := new()
	new_modifier.source = modifier_source
	new_modifier.type = modifier_type
	
	return new_modifier
