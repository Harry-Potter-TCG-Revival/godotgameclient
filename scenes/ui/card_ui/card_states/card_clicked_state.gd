class_name CardClickedState
extends CardState

func enter() -> void:
	print("entered clicked state")
	card_ui.statetext.text = "Clicked"
	# The drop point detector is set to monitoring so we know if we have entered the card drop area
	card_ui.drop_point_detector.monitoring = true
	
	# Settings the CardUI's card selected var to true
	card_ui.card_selected = true

func on_gui_input(event: InputEvent) -> void:
	# Card State machine say the only way to leave the clicked state is to go to the Dragging State
	# That is only done by moving the mouse. So we need to check if the input is mouse motion
	if event is InputEventMouseMotion:
		print("going to dragging state")
		card_state_transition_requested.emit(self, CardState.State.DRAGGING)
		
