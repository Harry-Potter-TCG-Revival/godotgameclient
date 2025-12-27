class_name PlayerReadyCheck
extends Control

@onready var die_result = %DieResult
@onready var button_roll_die = %ButtonRollDie
@onready var button_ready = $ButtonReady

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	button_ready.disabled = true
	button_roll_die.disabled = false
	

func _on_button_roll_die_pressed() -> void:
	button_roll_die.disabled = true
	button_ready.disabled = false
	var rolled_number = rng.randi_range(1,20)
	die_result.text = str(rolled_number)
	

func _on_button_ready_pressed():
	button_ready.disabled = true
	button_ready.text = "Waiting for Opponent to Ready"
	Events.ready_to_start_match.emit(multiplayer.get_unique_id(),int(die_result.text))
