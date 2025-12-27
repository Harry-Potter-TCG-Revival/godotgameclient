# Action State Step
extends TurnStepState

func enter() -> void:
	# Change UI to update to current state
	turn_step_ui.as_glow_effect.visible = true
	
	# Only do this if controlling the local player
	if turn_step_ui.is_local_player:
		# Disable the button until all automated actions are done
		turn_step_ui.button_exit_current_step.disabled = true
		turn_step_ui.button_exit_current_step.text = "Go to End Step"
		
		# Tell the player handler do all the action step functions
		Events.current_turn_step_changed.emit(self)
	


func exit() -> void:
	turn_step_ui.as_glow_effect.visible = false
