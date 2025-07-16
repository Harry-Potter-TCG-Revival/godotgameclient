class_name ConfirmationModalUI
extends Control

signal confirmed(is_confirmed: bool)

@onready var header_label = %HeaderLabel
@onready var message_label = %MessageLabel
@onready var confirm_button = %ConfirmButton
@onready var cancel_button = %CancelButton

var is_open: bool
var _should_unpause: bool = false

func _ready() -> void:
	
	Events.confirmation_modal_ui_customize.connect(customize)
	Events.confirmation_modal_ui_prompt.connect(prompt)
	
	set_process_unhandled_key_input(false)
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_button_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_button_pressed)
	
	hide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancel()
	

func prompt(pause: bool = false) -> bool:
	_should_unpause = (get_tree().paused == false) and pause
	if pause:
		get_tree().paused= true
	
	show()
	is_open = true
	set_process_unhandled_key_input(true)
	var is_confirmed = await confirmed
	
	return is_confirmed

func customize(header: String, message: String, confirm_text: String = "Yes", cancel_text: String = "No") -> ConfirmationModalUI:
	header_label.text = header
	message_label.text = message
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	
	return self

func close(is_confirmed: bool = false) -> void:
	if is_confirmed:
		confirm()
	else:
		cancel()

func confirm() -> void:
	_close_modal(true)
	Events.confirmation_modal_response.emit(true)

func cancel() -> void:
	_close_modal(false)
	Events.confirmation_modal_response.emit(false)

func _close_modal(is_confirmed: bool) -> void:
	set_process_unhandled_key_input(false)
	confirmed.emit(is_confirmed)
	set_deferred("is_open", false)
	hide()
	if _should_unpause:
		get_tree().paused = false

func _on_confirm_button_pressed() -> void:
	confirm()

func _on_cancel_button_pressed() -> void:
	cancel()
