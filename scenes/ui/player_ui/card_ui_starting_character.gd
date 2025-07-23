class_name StartingCharacterUI
extends PanelContainer

const CARD_UI_HIGHLIGHT_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_highlight_stylebox.tres")
const CARD_UI_HOVER_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_hover_stylebox.tres")
const CARD_UI_STANDARD_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_standard_stylebox.tres")

@export var Starting_Character : Card : set = _set_card

@onready var card_image = $CardImage
@onready var glow_effect = $CardImage/GlowEffect

func _ready() -> void:
	self.rotation_degrees = 90
	pass

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	# When a card is loaded into the game this handles setting all dynamic card properties, like visuals.
	Starting_Character = value
	card_image.texture = Starting_Character.card_image

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse"):
		Events.card_tooltip_popup_requested.emit(self.Starting_Character)
	
