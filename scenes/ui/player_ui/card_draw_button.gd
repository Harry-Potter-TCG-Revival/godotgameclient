class_name CardDrawButton
extends Button

func _ready() -> void:
	self.visible = true
	Events.out_of_actions.connect(_on_out_of_actions)
	Events.not_out_of_actions.connect(_not_out_of_actions)

func _on_out_of_actions() -> void:
	self.visible = false

func _not_out_of_actions() -> void:
	self.visible = true
