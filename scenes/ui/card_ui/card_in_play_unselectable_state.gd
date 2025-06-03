extends CardInPlayState

# Called when the node enters the scene tree for the first time.
@onready var glow_effect = $"../../../CardVisuals/GlowEffect"

# Called when the node enters the scene tree for the first time.
func enter():
	card_ui.modulate = Color(.4,.4,.4)
	glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)
	card_ui.statetext.text = "Inplay_Unselectable"

func exit() -> void:
	card_ui.modulate = Color(1,1,1)
