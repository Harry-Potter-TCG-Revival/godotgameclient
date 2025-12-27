class_name TurnStepState
extends Node

enum State {BEFOREYOURTURN,DRAW,CREATUREDAMAGE,ACTION,ENDOFYOURTURN,OPPONENTSTURN}

@export var state: State

var turn_step_ui : TurnStepUI

func enter() -> void:
	pass

func exit() -> void:
	pass
