extends CardHandState

const STANDARD_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_standard_stylebox.tres")

# Called when the node enters the scene tree for the first time.
@onready var glow_effect = $"../../../CardVisuals/GlowEffect"

# Called when the node enters the scene tree for the first time.
func enter():
	card_ui.modulate = Color(.4,.4,.4)
	glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)
	card_ui.statetext.text = "Hand_Selectable"

func exit() -> void:
	card_ui.modulate = Color(1,1,1)
