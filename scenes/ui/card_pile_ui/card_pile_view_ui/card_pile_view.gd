class_name CardPileView
extends Control

const CARD_MENU_UI_SCENE := preload("res://scenes/ui/card_ui/card_menu_ui/card_menu_ui.tscn")

@export var card_pile: CardPile

@onready var title = %Title
@onready var cards = %Cards
@onready var back_button = %BackButton

func _ready() -> void:
	Events.card_pile_view_requested.connect(show_current_view)
	
	back_button.pressed.connect(hide)
	
	for card: Node in cards.get_children():
		card.queue_free()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
	

func show_current_view(new_card_pile:CardPile, new_title: String, sorted: bool) -> void:
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_pile = new_card_pile
	title.text = new_title
	#_update_view.call_deferred(randomized)
	_update_view.call_deferred(sorted)

func _update_view(sorted: bool) -> void:
	if not card_pile:
		return
	
	var all_cards := card_pile.cards.duplicate()
	if sorted:
		all_cards.sort_custom(sort_by_card_name)
	
	for card: Card in all_cards:
		var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
		cards.add_child(new_card)
		new_card.card = card
	
	show()

func sort_by_card_name(card_a: Card,card_b: Card):
	if card_a.cardname < card_b.cardname :
		return true
	return false
