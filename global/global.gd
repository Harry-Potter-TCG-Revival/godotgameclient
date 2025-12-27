extends Node

# Multiplayer Variables
var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var multiplayerbridge : NakamaMultiplayerBridge
var joined_match : NakamaRTAPI.Match
var players_in_match : Dictionary
var player_id : int
var player_is_host : bool

# Player Variables
var local_player_stats : PlayerStats
var remote_player_stats : PlayerStats
var is_going_first : bool

# Testing Variables
var auto_login : bool = true
var auto_join_match : bool = true

# Card Variables
var active_card: Card : set = _set_active_card
var cards_in_play : Array[Card]
var card_ui_reference : CardUI = CardUI.new()

# When a card is being played or its effect is being used
# The card gets set as active
func _set_active_card(value: Card):
	active_card = value
	if value:
		print("Active card is now : ", value.cardname)
	else:
		print("Active card is now : blank")
