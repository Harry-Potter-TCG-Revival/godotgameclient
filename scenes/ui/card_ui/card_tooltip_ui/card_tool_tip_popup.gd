class_name CardTooltipPopup
extends Control

const CARD_MENU_UI_SCENE := preload("res://scenes/ui/card_ui/card_menu_ui/card_menu_ui.tscn")

@onready var card_tool_tip = %CardToolTip
@onready var card_menu_ui = $VBoxContainer/CardToolTip/CardMenuUI

func _ready() -> void:
	for card: CardMenuUI in card_tool_tip.get_children():
		card.queue_free()
	
	Events.card_tooltip_popup_requested.connect(show_tooltip)

func show_tooltip(card: Card) -> void:
	var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	card_tool_tip.add_child(new_card)
	new_card.card = card
	new_card.tooltip_requested.connect(hide_tooltip.unbind(1))
	show()

func hide_tooltip() -> void:
	if not visible:
		return
	
	for card: CardMenuUI in card_tool_tip.get_children():
		card.queue_free()
	
	hide()

func _on_gui_input(event) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()
