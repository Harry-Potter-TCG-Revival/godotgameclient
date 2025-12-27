# End of Your Turn Step State
extends TurnStepState

func enter() -> void:
	# Change UI to update to current state
	turn_step_ui.eoyts_glow_effect.visible = true
	
	# Only do this if controlling the local player
	if turn_step_ui.is_local_player:
		# Disable the button until all automated actions are done
		turn_step_ui.button_exit_current_step.disabled = true
		turn_step_ui.button_exit_current_step.text = "End Turn"
		
		# Tell the player handler do all the end of your turn step functions
		Events.current_turn_step_changed.emit(self)
	

func exit() -> void:
	# Turn off the glow
	turn_step_ui.eoyts_glow_effect.visible = false
