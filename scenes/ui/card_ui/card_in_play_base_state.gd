extends CardInPlayState

func enter() -> void:
	card_ui.statetext.text = "Inplay_Base"
	card_ui.glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_released("left_mouse"):
		card_ui.card.activated_ability(card_ui.player_stats)
	
	if event.is_action_pressed("right_mouse"):
		Events.card_tooltip_popup_requested.emit(card_ui.card)

func on_mouse_entered() -> void:
	card_ui.glow_effect.set("theme_override_styles/panel", HOVER_STYLEBOX)

func on_mouse_exited() ->void:
	card_ui.glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)

func exit() -> void:
	pass
