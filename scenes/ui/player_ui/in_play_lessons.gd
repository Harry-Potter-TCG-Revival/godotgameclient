class_name InPlayLessons
extends HBoxContainer

@onready var card_ui_scene := preload("res://scenes/ui/card_ui/card_ui.tscn")
@onready var care_of_magical_creatures = $CareOfMagicalCreatures
@onready var charms = $Charms
@onready var potions = $Potions
@onready var transfiguration = $Transfiguration
@onready var quidditch = $Quidditch

func _ready() -> void:
	#Events.reparent_card_to_play_requested.connect(_on_card_reparent_requested_in_play_lessons)
	pass

func reparent_card_to_in_play_lessons(child: CardUI) -> void:
	
	if not child.card.type_lesson:
		return
	
	if child.card.care_of_magical_creatures_power_provided_amount >= 1:
		child.reparent(care_of_magical_creatures)
		care_of_magical_creatures.update_cards_tight()
	
	elif child.card.charms_power_provided_amount >= 1:
		child.reparent(charms)
		charms.update_cards_tight()
	
	elif child.card.potions_power_provided_amount >= 1:
		child.reparent(potions)
		potions.update_cards_tight()
	
	elif child.card.transfiguration_power_provided_amount >= 1:
		child.reparent(transfiguration)
		transfiguration.update_cards_tight()
	
	elif child.card.quidditch_power_provided_amount >= 1:
		child.reparent(quidditch)
		quidditch.update_cards_tight()
	else :
		# This line should never be hit, since all lesson types are accounted for
		# Not the best way to handle this, but send the card back to the hand
		child.reparent_requested_hand.emit(child)
	

func update_cards_requested() -> void:
	care_of_magical_creatures.update_cards_tight()
	charms.update_cards_tight()
	potions.update_cards_tight()
	transfiguration.update_cards_tight()
	quidditch.update_cards_tight()
