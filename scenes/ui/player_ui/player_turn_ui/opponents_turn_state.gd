# Opponents Turn Step State
extends TurnStepState

# This is to handle logic for starting the battle
func enter_as_initial_state() -> void:
	# Tell the player handler to enter the initial state
	Events.initial_turn_step_entered.emit(self)
	
	if turn_step_ui.is_local_player:
		# Disable the button, as its the opponents turn
		turn_step_ui.button_exit_current_step.disabled = true
		
		# Change UI to update to current state
		turn_step_ui.button_exit_current_step.text = "Opponent's Turn"
	

func enter() -> void:
	print("entering Opponent step, host:", multiplayer.is_server(), " local player:", turn_step_ui.is_local_player)
	# Only do this if controlling the local player
	if turn_step_ui.is_local_player:
		# Disable the button, as its the opponents turn
		turn_step_ui.button_exit_current_step.disabled = true
		
		# Change UI to update to current state
		turn_step_ui.button_exit_current_step.text = "Opponent's Turn"
		
		# Play Opponent Turn Animation
		# Emit the signal to let the player and battle manager know the turn is over
		Events.current_turn_step_changed.emit(self)
	

func exit() -> void:
	# Tell the battle manager to increment the turn count if this player went second
	if Global.is_going_first:
		Events.increment_turn_count.emit()
