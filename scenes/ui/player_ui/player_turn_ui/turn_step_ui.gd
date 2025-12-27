class_name TurnStepUI
extends Panel

var initial_state : TurnStepState.State
var is_local_player : bool
var turn_step_state_machine_is_initalized : bool

@onready var byts_glow_effect = %BYTSGLowEffect
@onready var ds_glow_effect = %DSGLowEffect
@onready var cds_glow_effect = %CDSGLowEffect
@onready var as_glow_effect = %ASGLowEffect
@onready var eoyts_glow_effect = %EOYTSGLowEffect
@onready var turn_step_state_machine = $TurnStepStateMachine
@onready var button_exit_current_step = %ButtonExitCurrentStep

func initialize_turn_step_state_machine(local_player: bool):
	# Set if this is controlling the local player
	is_local_player = local_player
	
	# Update visuals if this is controlling the remote player
	if not is_local_player:
		button_exit_current_step.visible = false
		self.rotation_degrees = -180
	
	# Set the initial state based on whos going first and if its the local player
	# Global.is_going_first only represents the local player
	if Global.is_going_first and is_local_player:
		initial_state = TurnStepState.State.BEFOREYOURTURN
	elif !Global.is_going_first and !is_local_player:
		initial_state = TurnStepState.State.BEFOREYOURTURN
	else:
		initial_state = TurnStepState.State.OPPONENTSTURN
	turn_step_state_machine.initial_state = initial_state
	print("initializing state machine for the local player : ", is_local_player)
	turn_step_state_machine.init(self)
	turn_step_state_machine_is_initalized = true

# This is an RPC so that the remote player visuals can be updated
@rpc("any_peer","call_remote","reliable",0)
func on_button_exit_current_step_pressed():
	#turn_step_state_machine.on_turn_step_state_transition_requested()
	# When a match starts the remote players state machine isnt setup
	# So this handles the initial start of the match
	# This is also why the parameters, are both false.
	if not turn_step_state_machine_is_initalized:
		initialize_turn_step_state_machine(false)
	else:
		print("button press is running for the local player : ", is_local_player)
		turn_step_state_machine.on_turn_step_state_transition_requested()

func current_state_ready_to_exit() -> void:
	# Enable the button to allow player to go to the next step of the turn
	button_exit_current_step.disabled = false
