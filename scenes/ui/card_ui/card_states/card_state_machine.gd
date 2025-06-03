class_name CardStateMachine
extends Node

@onready var card_hand_state = $CardHandState
@onready var card_in_play_state = $CardInPlayState

@export var initial_state: CardState

var current_state: CardState
var states := {}

# Each possible state in the card state machine is a child of this parent node.
# So loop through them to get all possible values as a reference and validation.
func init(card: CardUI) -> void:
	for child in get_children():
		if child is CardState:
			states[child.state] = child
			child.card_state_transition_requested.connect(_on_card_state_transition_requested)
			child.card_ui = card
		
	# Call the initial states enter function 
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	
	# Call the Sub state machines init functions
	card_hand_state.init(card)
	card_in_play_state.init(card)
	

# These functions are all going to call their respective state machine functions
# So the flow of the call is CardUI -> CardStateMachine -> CurrentState Function -> Execute Action
func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)
	

func on_gui_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_gui_input(event)
	

func on_mouse_entered() -> void:
	if current_state:
		current_state.on_mouse_entered()
	

func on_mouse_exited() -> void:
	if current_state:
		current_state.on_mouse_exited()
	

func reset_selectable_state() -> void:
	if current_state:
		current_state.reset_selectable_state()
	

func transition_selectable_state(value: bool) -> void:
	if current_state:
		current_state.transition_selectable_state(value)

func _on_card_state_transition_requested(fromstate: CardState, tostate: CardState.State) -> void:
	# Validate that the state we are leaving is the state we are in right now
	if fromstate != current_state:
		return
	
	# Validate the state we are transitioning to is inside the "states" dictionary and exists
	var new_state: CardState = states[tostate]
	if not new_state:
		return
	
	# Now that both fromstate and tostate are valid, we can begin the transition.
	# We must exist the current state first
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
