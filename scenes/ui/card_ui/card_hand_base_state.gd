extends CardHandState

# The parent hand state handles some enter functions.
# This enter function clears or resets values made while in other hand states
func enter():
	pass

# The only way for a card to leave the hand state is for it to be left clicked
func on_gui_input(event: InputEvent) -> void:
	if not card_ui.playable or card_ui.disabled:
		return
	
	if event.is_action_pressed("left_mouse"):
		# This is calculating the position on the card where the user clicked the card
		print("going to clicked state")
		
		var card_reset_tween := create_tween()
		card_reset_tween.tween_property(card_ui.card_visuals,"position",Vector2(0,0),.01)
		
		card_state_transition_requested.emit(self, CardState.State.CLICKED)
	
func on_mouse_entered() -> void:
	# Only tween cards if they owner hovers over it
	if !card_ui.card.player_owner == Global.session.username:
		return
	
	var card_hover_tween := create_tween()
	card_hover_tween.tween_property(card_ui.card_visuals,"position",Vector2(0,-100),.02).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func on_mouse_exited() ->void:
		# Only tween cards if they owner hovers over it
	if !card_ui.card.player_owner == Global.session.username:
		return
	
	var card_unhover_tween := create_tween()
	card_unhover_tween.tween_property(card_ui.card_visuals,"position",Vector2(0,0),.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	

func exit() -> void:
	pass
