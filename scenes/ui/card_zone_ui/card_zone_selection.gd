class_name CardZoneSelection
extends Control

@export var card_played: Card
@export var filtered_cards: Array[Card]

@onready var message_title = $MessageBackground/MessageTitle
@onready var submit_button = $SubmitButton

var is_open: bool
var selected_cards: Array[Card]
var all_cards: Array[Card]

func _ready() -> void:
	Events.card_zone_selection_requested.connect(update_cards_in_card_zone)
	
	hide()

func update_cards_in_card_zone(targets: Array[CardZone.Zone],new_card_played:Card,new_title:String) -> void:
	# remove any previously selected cards from the array
	selected_cards.clear()
	all_cards.clear()
	
	is_open = true
	
	# Set card to the global played card
	card_played = new_card_played
	
	# Update the title
	message_title.text = new_title
	
	# Get Card Zones to use for setup or pausing
	var player_handler := get_tree().get_first_node_in_group("player_handler") as PlayerHandler
	
	# Expad this to include all card zones, players and opponents
	if targets.has(CardZone.Zone.PlayerInPlay):
		all_cards += Global.cards_in_play
	if targets.has(CardZone.Zone.PlayerHand):
		var cards_in_hand = player_handler.hand.get_children()
		all_cards += cards_in_hand
	
	# Filter all card_uis to get valid targets for the effect
	filtered_cards = all_cards.filter(card_played.selection_filter)
	
	for card in all_cards:
		# Setup the signal so that it will go back to base state when done
		Events.card_zone_selection_finished.connect(card.card_ui._reset_valid_choice)
		
		# Compare the two arrays, the filtered array has all valid cards
		if filtered_cards.has(card):
			print(card.cardname, " : card is selectable")
			card.card_ui.is_valid_choice = true
			card.card_ui.selected_cards = selected_cards
			card.card_ui.selected_cards_updated.connect(_on_selected_cards_updated)
		else:
			print(card.cardname, " : card is not selectable")
			card.card_ui.is_valid_choice = false
		
	show()
	

func _on_selected_cards_updated() -> void:
	# Simply update the button to show how many cards have been selected
	submit_button.text = "Submit %s" % [selected_cards.size()]
	
	# Ask the active card if the selected cards are valid
	submit_button.disabled = !Global.active_card.check_selected_cards_is_valid(selected_cards)


func _on_submit_button_pressed():
	var selected_cards_card_pile = CardPile.new()
	selected_cards_card_pile.cards = selected_cards
	
	Events.card_zone_selection_finished.emit(selected_cards_card_pile)
	for card in all_cards:
		
		# Disconnect Signals
		if filtered_cards.has(card):
			card.card_ui.selected_cards_updated.disconnect(_on_selected_cards_updated)
		Events.card_zone_selection_finished.disconnect(card.card_ui._reset_valid_choice)
		card.card_ui.selected_cards.clear()
	
	hide()
