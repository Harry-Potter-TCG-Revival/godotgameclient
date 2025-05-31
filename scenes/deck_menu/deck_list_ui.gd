class_name DeckOptionUI
extends VBoxContainer

@onready var deck_name = $DeckName
@onready var deck_image = $DeckImage
@onready var select_deck = $SelectDeck

@export var deck_list: DeckList: set = _set_deck

func _set_deck(value: DeckList) -> void:
	if not is_node_ready():
		await ready
	
	deck_list = value
	deck_image.texture = deck_list.image
	deck_name.text = deck_list.name

func _on_open_deck_pressed():
	# Change scene, load deck
	pass # Replace with function body.
