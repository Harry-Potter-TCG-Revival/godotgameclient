class_name CardHandState
extends CardState

enum HandState {PARENT,BASE,SELECTABLE,UNSELECTABLE}

signal card_hand_state_transition_requested(from: CardHandState, to: HandState)

@export var initial_hand_state: CardHandState
@export var hand_state: HandState

var current_hand_state: CardHandState
var hand_states := {}

# Each possible state in the card state machine is a child of this parent node.
# So loop through them to get all possible values as a reference and validation.
func init(card: CardUI) -> void:
	for child in get_children():
		if child is CardHandState:
			hand_states[child.hand_state] = child
			child.card_ui = card
			child.card_hand_state_transition_requested.connect(_on_card_hand_state_transition_requested)
			child.card_state_transition_requested.connect(_on_card_state_transition_requested)
		
	

func enter():
	# Wait for the parent CardUI to be ready
	# The parent CardUI is saved as a variable card_ui in the card state script
	if not card_ui.is_node_ready():
		await card_ui.ready
	
	Events.card_drag_started.connect(card_ui._on_card_drag_started)
	Events.card_drag_ended.connect(card_ui._on_card_drag_ended)
	
	# Check if the card is curently in an animation or tween, kill it to have card jump to hand
	if card_ui.tween and card_ui.tween.is_running():
		card_ui.tween.kill()
	
	# According to the card states, when a card enters the base state it will always come from 
	# outside the Hand, so it will always need to be re-parented to the Hand container.
	card_ui.reparent_requested_hand.emit(card_ui)
	card_ui.statetext.text = "Hand"
	
	# When a card come back into the hand reset its position back to zero
	# This is needed because the card could not be centered do to a hover tween
	var card_reset_tween := create_tween()
	card_reset_tween.tween_property(card_ui.card_visuals,"position",Vector2(0,0),.01)
	
	# Set the card_in_hand bool to true. 
	# This is used to identify cards in handwithout using the state machine
	card_ui.card_in_hand = true
	
	# Call the initial states enter function 
	if initial_hand_state:
		initial_hand_state.enter()
		current_hand_state = initial_hand_state
	

func on_gui_input(event: InputEvent) -> void:
	if current_hand_state:
		current_hand_state.on_gui_input(event)
	

func on_mouse_entered() -> void:
	if current_hand_state:
		current_hand_state.on_mouse_entered()
	

func on_mouse_exited() -> void:
	if current_hand_state:
		current_hand_state.on_mouse_exited()
	

func _on_card_state_transition_requested(_fromstate: CardState, tostate: CardState.State) -> void:
	# Validate the state we are transitioning to is inside the "states" dictionary and exists
	var new_state: CardState = get_parent().states[tostate]
	if not new_state:
		return
	
	card_state_transition_requested.emit(self, tostate)

func _on_card_hand_state_transition_requested(fromhandstate: CardHandState, tohandstate: CardHandState.HandState) -> void:
	# Validate that the state we are leaving is the state we are in right now
	if fromhandstate != current_hand_state:
		return
	
	# Validate the state we are transitioning to is inside the "hand_states" dictionary and exists
	var new_hand_state: CardState = hand_states[tohandstate]
	if not new_hand_state:
		return
	
	# Now that both fromstate and tohandstate are valid, we can begin the transition.
	# We must exist the current state first
	if current_hand_state:
		current_hand_state.exit()
	
	new_hand_state.enter()
	current_hand_state = new_hand_state

func transition_selectable_state(value: bool) -> void:
	# Check that the card is supposed to be chosen
	if card_ui.is_valid_choice != value:
		return
	
	if value:
		_on_card_hand_state_transition_requested(current_hand_state, CardHandState.HandState.SELECTABLE)
	else:
		_on_card_hand_state_transition_requested(current_hand_state, CardHandState.HandState.UNSELECTABLE)
	

func reset_selectable_state() -> void:
	_on_card_hand_state_transition_requested(current_hand_state, CardHandState.HandState.BASE)

func exit():
	Events.card_drag_started.disconnect(card_ui._on_card_drag_started)
	Events.card_drag_ended.disconnect(card_ui._on_card_drag_ended)
	card_ui.card_in_hand = false
