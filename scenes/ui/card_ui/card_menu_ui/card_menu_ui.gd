class_name CardMenuUI
extends CenterContainer

signal tooltip_requested(card: Card)

@export var card: Card : set = _set_card

@onready var card_image = $Visuals/CardImage

func _on_visuals_gui_input(event) -> void:
	if event.is_action_pressed("left_mouse"):
		tooltip_requested.emit(card)

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	card_image.texture = card.card_image
