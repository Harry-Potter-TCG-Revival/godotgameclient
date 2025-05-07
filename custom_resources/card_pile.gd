class_name CardPile
extends Resource

signal card_pile_size_changed(cards_amount)

@export var cards: Array[Card] =[]

func empty() -> bool:
	return cards.is_empty()

func draw_card() -> Card:
	var card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return card

func draw_specific_card(card_to_draw: Card) -> Card:
	var card_position = cards.find(card_to_draw)
	var card = cards.pop_at(card_position)
	card_pile_size_changed.emit(cards.size())
	return card

func add_card(card: Card):
	cards.append(card)
	card_pile_size_changed.emit(cards.size())

func shuffle() -> void:
	cards.shuffle()

func clear() -> void:
	cards.clear()
	card_pile_size_changed.emit(cards.size())

func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s" % [i+1, cards[i].cardname])
	return "\n".join(_card_strings)
