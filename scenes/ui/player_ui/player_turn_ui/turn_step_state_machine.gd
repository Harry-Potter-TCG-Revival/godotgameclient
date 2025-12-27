class_name TurnStepStateMachine
extends Node

@onready var button_exit_current_step = %ButtonExitCurrentStep

# The initial state of the turn needs to be set by the battle manager
# This can be used to reference who went first in a game
var initial_state: TurnStepState.State
var current_state: TurnStepState
var states := {}

# Each possible state in the card state machine is a child of this parent node.
# So loop through them to get all possible values as a reference and validation.
func init(turn_step_ui:TurnStepUI) -> void:
	
	for child in get_children():
		if child is TurnStepState:
			states[child.state] = child
			child.turn_step_ui = turn_step_ui
		
	# Call the initial states enter function
	# Have to index into the enum here because zero can be a value and zero is a false truthy value
	if states[initial_state]:
		states[initial_state].enter_as_initial_state()
		current_state = states[initial_state]
	

func on_turn_step_state_transition_requested() -> void:
	# Need to check the current state
	# Since all the states have to go in order the next state is just +1
	# Have to exit the current state before entering the new one
	current_state.exit()
	if current_state.state == TurnStepState.State.OPPONENTSTURN:
		# Manully start the state machine over because its now the players turn
		var before_your_turn_state = TurnStepState.State.BEFOREYOURTURN
		var new_state = states[before_your_turn_state]
		new_state.enter()
		current_state = new_state
	else:
		# current_state.state is to get the index of the enum, +1 is to go to the next state
		var new_state = states[current_state.state + 1]
		new_state.enter()
		current_state = new_state
		
	
