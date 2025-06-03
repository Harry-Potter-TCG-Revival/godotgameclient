class_name CardState
extends Node

enum State {HAND, CLICKED, DRAGGING, RELEASED, SPELLZONE, IN_PLAY}

signal card_state_transition_requested(from: CardState, to: State)
signal card_child_state_transition_requested(selectable: bool)

@export var state: State

var card_ui: CardUI

func enter() -> void:
	pass

func exit() -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass

func on_gui_input(_event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func reset_selectable_state() -> void:
	pass

func transition_selectable_state(_value: bool) -> void:
	pass
