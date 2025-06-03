class_name CardDraggingState
extends CardState

const DRAG_MINIMUM_THRESHOLD := 0.05
const SELECTED_STYLEBOX := preload("res://scenes/ui/card_ui/card_ui_selected_stylebox.tres")
const HOVER_STYLEBOX = preload("res://scenes/ui/card_ui/card_ui_hover_stylebox.tres")

var card_position_when_clicked
var minimum_drag_time_elapsed := false
var horizontal_pivot_offset = Vector2.ZERO

func enter() -> void:
	print("entered dragging state")
	
	# The BattleUI node is setup as a node group called "player_ui_layer".
	# The BattleUI node is stored in the variable so we can re-parent to it
	# This gets the CardUI out of the hand
	var player_ui_layer := get_tree().get_first_node_in_group("player_ui_layer")
	if player_ui_layer:
		card_ui.reparent(player_ui_layer)
	
	Events.card_drag_started.emit(card_ui)
	
	card_ui.statetext.text = "Dragging"

	
	# Creating a  timer to ensure that a left mouse quick click and release 
	# are treated as one action. This is to prevent a user from clicking on a card
	# to pick it up and it just snap backs to the hand
	minimum_drag_time_elapsed = false
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false)
	threshold_timer.timeout.connect(func(): minimum_drag_time_elapsed = true)
	

func on_gui_input(event: InputEvent) -> void:
	
	# If the card_ui has a target i.e. over the card drop area, update the glow effect
	if card_ui.targets.size() > 0:
		card_ui.glow_effect.set("theme_override_styles/panel", SELECTED_STYLEBOX)
	else :
		card_ui.glow_effect.set("theme_override_styles/panel", HOVER_STYLEBOX)
	
	# Set the cancel var if the right mouse button is clicked
	var cancel = event.is_action_pressed("right_mouse")
	# Set the confirm var if the left mouse is clicked or released
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	
	# If the action was canceled we need to transition back to the hand state
	if cancel:
		print("going to hand state from dragging state")
		if card_ui.card.goes_in_play():
			card_ui.card_image.rotation_degrees = 0
		card_state_transition_requested.emit(self, CardState.State.HAND)
	elif minimum_drag_time_elapsed and confirm:
		print("going to released state from dragging state")
		# ?
		get_viewport().set_input_as_handled()
		card_state_transition_requested.emit(self, CardState.State.RELEASED)
	
func _physics_process(delta):
	
	# If the cardstate is dragging and a card is selected than move this card to follow the mouse
	# Subtract half the size of the card so the mouse centers on the card
	if card_ui.card_state_machine.current_state.name == "CardDraggingState" and card_ui.card_selected:
		card_ui.global_position = lerp(card_ui.global_position, card_ui.get_global_mouse_position() - card_ui.size/2, 25 * delta)
	

func exit() -> void:
	Events.card_drag_ended.emit(card_ui)
	card_ui.card_selected = false
