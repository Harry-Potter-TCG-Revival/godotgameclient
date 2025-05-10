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
var player_stats : PlayerStats
