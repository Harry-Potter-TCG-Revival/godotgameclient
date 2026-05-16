class_name CounterUI
extends Label

const DAMAGE_COUNTER_THEME := preload("res://custom_resources/Themes/damage_counter_label.tres")
const STANDARD_COUNTER_THEME := preload("res://custom_resources/Themes/standard_counter_label.tres")
const MAX_HEALTH_COUNTER_THEME := preload("res://custom_resources/Themes/max_health_counter_label.tres")

enum counter_types {STANDARD,DAMAGE,MAXHEALTH}

@export var counter_type : counter_types  : set = _set_counter_type
@export var counter_amount : int : set = _set_counter_amount

@onready var hover_text_label = $HoverTextLabel

func _set_counter_type(type: counter_types):
	match type:
		counter_types.STANDARD:
			hover_text_label.text = "Counters"
			self.label_settings = STANDARD_COUNTER_THEME
		counter_types.DAMAGE:
			hover_text_label.text = "Damage Counters"
			self.label_settings = DAMAGE_COUNTER_THEME
		counter_types.MAXHEALTH:
			hover_text_label.text = "Additional Health"
			self.label_settings = MAX_HEALTH_COUNTER_THEME
		
	

func _set_counter_amount(value: int):
	counter_amount = value
	self.text = str(counter_amount)

func _on_area_2d_mouse_entered():
	hover_text_label.visible = true


func _on_area_2d_mouse_exited():
	hover_text_label.visible = false
