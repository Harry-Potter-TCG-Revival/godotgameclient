class_name CardPileOpener
extends TextureButton

@export var card_pile: CardPile : set = set_card_pile
@export var deck_title: String
@export var sorted: bool

func set_card_pile(new_value: CardPile) -> void:
	card_pile = new_value

func _on_pressed():
	Events.card_pile_view_requested.emit(card_pile,deck_title,sorted)
