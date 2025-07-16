class_name CardSelectionUI
extends CenterContainer

signal selected_cards_updated

const SELECTED_STYLEBOX := preload("res://scenes/ui/card_ui/card_ui_selected_stylebox.tres")
const HOVER_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_hover_stylebox.tres")
const HIGHLIGHT_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_highlight_stylebox.tres")
const STANDARD_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_standard_stylebox.tres")

@export var card: Card : set = _set_card
@export var selected_cards: Array[Card]
@export var is_valid_choice: bool : set = _set_is_valid_choice

@onready var card_image = $Visuals/CardImage
@onready var glow_effect = $Visuals/CardImage/GlowEffect

var selected: bool = false

func _set_card(value: Card):
	card = value
	card_image.texture = value.card_image

func _set_is_valid_choice(value: bool):
	is_valid_choice = value
	if is_valid_choice:
		glow_effect.set("theme_override_styles/panel", HIGHLIGHT_STYLEBOX)
	else:
		modulate = Color(.4,.4,.4)
		glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)
	

func _on_visuals_gui_input(event):
	if is_valid_choice:
		if event.is_action_pressed("left_mouse") and not selected:
			selected_cards.append(card)
			selected = true
			glow_effect.set("theme_override_styles/panel", SELECTED_STYLEBOX)
			selected_cards_updated.emit()
		elif event.is_action_pressed("left_mouse") and selected:
			selected_cards.erase(card)
			selected = false
			glow_effect.set("theme_override_styles/panel", HOVER_STYLEBOX)
			selected_cards_updated.emit()
		else:
			return
		
	

func _on_visuals_mouse_entered():
	if is_valid_choice:
		if not selected:
			glow_effect.set("theme_override_styles/panel", HOVER_STYLEBOX)
		
	

func _on_visuals_mouse_exited():
	if is_valid_choice:
		if not selected:
			glow_effect.set("theme_override_styles/panel", HIGHLIGHT_STYLEBOX)
		
	
