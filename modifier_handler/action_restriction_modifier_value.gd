class_name ActionRestrictionModiferValue
extends CardRestrictionModifierValue

# This extened the CardRestrictionModiferValue because Actions can be restricted the same way
# There are also more possibilites that can be restricited.
# Also the reason only one class doesnt exist with all the options is because
# some cards say "Your opponent can't play Spell cards" while others
# say "he or she can't use Actions to play Spell cards."
# and those need to be tracked and handled separately because some cards can be 
# played without using an action

@export_subgroup("Basic Actions")
@export var can_draw_card: bool = true
@export var can_activate_abilities: bool = true

static func create_new_modifier(modifier_source: String) -> ActionRestrictionModiferValue:
	var new_modifier := new()
	new_modifier.source = modifier_source
	
	return new_modifier
