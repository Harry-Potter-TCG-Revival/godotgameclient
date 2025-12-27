# Before Your Turn Step State
extends TurnStepState

# This is to handle logic for starting the battle
func enter_as_initial_state() -> void:
	# So far the logic is the same as entering normally
	enter()

func enter() -> void:
	# Change UI to update to current state
	turn_step_ui.byts_glow_effect.visible = true
	
	# Only do this if controlling the local player
	if turn_step_ui.is_local_player:
		# Disable the button until all automated actions are done
		turn_step_ui.button_exit_current_step.disabled = true
		turn_step_ui.button_exit_current_step.text = "Go to Draw Step"
		
		# Tell the player handler do all the before your turn functions
		Events.current_turn_step_changed.emit(self)
	

func exit() -> void:
	turn_step_ui.byts_glow_effect.visible = false
