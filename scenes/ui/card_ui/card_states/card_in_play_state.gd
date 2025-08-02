class_name CardInPlayState
extends CardState

enum InPlayState {BASE,SELECTABLE,UNSELECTABLE, Parent}

signal card_inplay_state_transition_requested(from: CardInPlayState, to: InPlayState)

@export var initial_inplay_state: CardInPlayState
@export var inplay_state: InPlayState

const STANDARD_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_standard_stylebox.tres")
const HOVER_STYLEBOX := preload("res://scenes/ui/card_ui/card_ui_hover_stylebox.tres")

var current_inplay_state: CardInPlayState
var inplay_states := {}

# Each possible state in the card state machine is a child of this parent node.
# So loop through them to get all possible values as a reference and validation.
func init(card: CardUI) -> void:
	for child in get_children():
		if child is CardInPlayState:
			inplay_states[child.inplay_state] = child
			child.card_ui = card
			child.card_inplay_state_transition_requested.connect(_on_card_inplay_state_transition_requested)
			child.card_state_transition_requested.connect(_on_card_state_transition_requested)
		
	

func enter() -> void:
	# Check there is a valid card_ui
	if not card_ui :
		return
	
	# Clear the current card_drop_area so only new valid card_drop_area exist
	card_ui.card_drop_area.clear()
	
	# Connect the card ability signal since it can only be used in play
	card_ui.card.update_once_per_game_ability_state.connect(_update_update_once_per_game_ability_state)
	
	# Debugging print and label
	print("entered In Play state")
	card_ui.statetext.text = "In Play"
	
	# Call the cards enter play function if it has one
	card_ui.enter_play()
	
	# Update the glow to be standard
	card_ui.glow_effect.set("theme_override_styles/panel", STANDARD_STYLEBOX)
	
	# Set the card_in_play bool to true. 
	# This is used to identify cards in play without using the state machine
	card_ui.card_in_play = true
	
	# Add the card to the global "cards_in_play" array
	Global.cards_in_play.append(card_ui.card)
	
	# Call the initial in play states enter function 
	if initial_inplay_state:
		initial_inplay_state.enter()
		current_inplay_state = initial_inplay_state
	

func on_gui_input(event: InputEvent) -> void:
	if current_inplay_state:
		current_inplay_state.on_gui_input(event)
	

func on_mouse_entered() -> void:
	if current_inplay_state:
		current_inplay_state.on_mouse_entered()
	

func on_mouse_exited() -> void:
	if current_inplay_state:
		current_inplay_state.on_mouse_exited()
	

func _update_update_once_per_game_ability_state():
	if card_ui.card.once_per_game_ability_used:
		card_ui.ability_used_flag.show()

func _on_card_state_transition_requested(_fromstate: CardState, tostate: CardState.State) -> void:
	# Validate the state we are transitioning to is inside the "states" dictionary and exists
	var new_state: CardState = get_parent().states[tostate]
	if not new_state:
		return
	
	card_state_transition_requested.emit(self, tostate)

func _on_card_inplay_state_transition_requested(frominplaystate: CardInPlayState, toinplaystate: CardInPlayState.InPlayState) -> void:
	# Validate that the state we are leaving is the state we are in right now
	if frominplaystate != current_inplay_state:
		return
	
	# Validate the state we are transitioning to is inside the "hand_states" dictionary and exists
	var new_inplay_state: CardState = inplay_states[toinplaystate]
	if not new_inplay_state:
		return
	
	# Now that both fromstate and tohandstate are valid, we can begin the transition.
	# We must exist the current state first
	if current_inplay_state:
		current_inplay_state.exit()
	
	new_inplay_state.enter()
	current_inplay_state = new_inplay_state

func transition_selectable_state(value: bool) -> void:
	# Check that the card is supposed to be chosen
	if card_ui.is_valid_choice != value:
		return
	
	if card_ui.is_valid_choice:
		_on_card_inplay_state_transition_requested(current_inplay_state, CardInPlayState.InPlayState.SELECTABLE)
	else:
		_on_card_inplay_state_transition_requested(current_inplay_state, CardInPlayState.InPlayState.UNSELECTABLE)
	

func reset_selectable_state() -> void:
	_on_card_inplay_state_transition_requested(current_inplay_state, CardInPlayState.InPlayState.BASE)

func exit() -> void:
	card_ui.card_in_play = false
	
	card_ui.leave_play()
	
	# Add the card to the global "cards_in_play" array
	Global.cards_in_play.erase(card_ui.card)
