extends CardHandState

const SELECTED_STYLEBOX := preload("res://scenes/ui/card_ui/card_ui_selected_stylebox.tres")
const HOVER_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_hover_stylebox.tres")
const HIGHLIGHT_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_highlight_stylebox.tres")

@onready var glow_effect = $"../../../CardVisuals/GlowEffect"

# Called when the node enters the scene tree for the first time.
func enter():
	glow_effect.set("theme_override_styles/panel", HIGHLIGHT_STYLEBOX)
	card_ui.statetext.text = "Hand_Selectable"

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") and not card_ui.card_selected:
		card_ui.selected_cards.append(card_ui.card)
		card_ui.card_selected = true
		glow_effect.set("theme_override_styles/panel", SELECTED_STYLEBOX)
		card_ui.selected_cards_updated.emit()
	elif event.is_action_pressed("left_mouse") and card_ui.card_selected:
		card_ui.selected_cards.erase(card_ui.card)
		card_ui.selected = false
		glow_effect.set("theme_override_styles/panel", HOVER_STYLEBOX)
		card_ui.selected_cards_updated.emit()
	else:
		return
	

func on_mouse_entered():
	if not card_ui.card_selected:
		glow_effect.set("theme_override_styles/panel", HOVER_STYLEBOX)
	

func on_mouse_exited():
	if not card_ui.card_selected:
		glow_effect.set("theme_override_styles/panel", HIGHLIGHT_STYLEBOX)
	

func exit() -> void:
	pass
