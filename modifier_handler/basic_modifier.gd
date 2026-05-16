class_name BasicModifier
extends Modifier

# This is identify where in the game this is going to be used.
# When playing a card it only needs to check the CARDPLATYING Modifiers
enum Type {DMG_DEALT,DMG_TAKEN}

@export var type: Type

func get_value(source: String) -> BasicModifierValue:
	for value: BasicModifierValue in get_children():
		if value.source == source:
			return value
		
	return null
	

func add_new_value(value: BasicModifierValue) -> void:
	var basic_modifier_value := get_value(value.source)
	if not basic_modifier_value:
		add_child(value)
	else:
		basic_modifier_value.flat_value = value.flat_value
		basic_modifier_value.percent_value = value.percent_value
		basic_modifier_value.set_value -= value.set_value
	

func remove_value(source: String) -> void:
	for value: BasicModifierValue in get_children():
		if value.source == source:
			value.queue_free()
		
	

func clear_values() -> void:
	for value: BasicModifierValue in get_children():
		value.queue_free()
	
