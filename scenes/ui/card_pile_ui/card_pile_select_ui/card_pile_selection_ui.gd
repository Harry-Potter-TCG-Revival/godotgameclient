class_name CardPileSelection
extends Control

const CARD_SELECTION_UI_SCENE := preload("res://cards/resources/BorrowedWand.tres")

@export var card_played: Card
@export var filtered_cards: Array[Card]

@onready var title = %Title
@onready var cards_container = %CardsContainer
@onready var submit_button = $SubmitButton

var selected_cards: Array[Card]
var active_card_pile: CardPile

func _ready() -> void:
	Events.card_pile_selection_requested.connect(show_current_view)
	
	for card: Node in cards_container.get_children():
		card.queue_free()
	
	#show_current_view(card_pile,filtered_cards,"Choose",3,true)

func show_current_view(new_card_played: Card, new_card_pile: CardPile, new_title: String) -> void:
	# remove any previously selected cards from the array
	selected_cards.clear()
	
	for card: Node in cards_container.get_children():
		card.queue_free()
	
	if Global.active_card != new_card_played:
		print("broke out of selection because card isnt global.active_card")
		return
	
	card_played = new_card_played
	active_card_pile = new_card_pile
	filtered_cards = active_card_pile.cards.filter(card_played.selection_filter)
	active_card_pile.cards.sort_custom(card_played.selection_sort)
	title.text = new_title
	submit_button.text = "Submit 0"
	_update_view.call_deferred()

func _update_view() -> void:
	if not active_card_pile:
		return
	
	var all_cards := active_card_pile.cards.duplicate()
	
	for card: Card in all_cards:
		var new_card_selection_ui := CARD_SELECTION_UI_SCENE.instantiate() as CardSelectionUI
		cards_container.add_child(new_card_selection_ui)
		new_card_selection_ui.card = card
		new_card_selection_ui.selected_cards = selected_cards
		new_card_selection_ui.selected_cards_updated.connect(_on_selected_cards_updated)
		
		# Compare the two arrays, the filtered array has all valid cards
		if filtered_cards.has(card):
			new_card_selection_ui.is_valid_choice = true
		else:
			new_card_selection_ui.is_valid_choice = false
		
	show()

func _on_selected_cards_updated() -> void:
	# Simply update the button to show how many cards have been selected
	submit_button.text = "Submit %s" % [selected_cards.size()]
	
	# Ask the active card if the selected cards are valid
	submit_button.disabled = !Global.active_card.check_selected_cards_is_valid(selected_cards)

func _on_submit_button_pressed():
	var selected_cards_card_pile = CardPile.new()
	selected_cards_card_pile.cards = selected_cards
	Events.card_pile_selection_finished.emit(selected_cards_card_pile)
	
	# Shuffle the cardpile, FIX THIS, it will shuffle deck and discard pile
	active_card_pile.shuffle()
	
	hide()
	
