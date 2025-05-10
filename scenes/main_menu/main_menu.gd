class_name MainMenu
extends Control

const MATCH_SELECTION_UI_SCENE := preload("res://scenes/match_ui/match_selection_ui.tscn")
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")

var selected_match_name : String : set = _set_selected_match_name
var is_importing_decklist : bool = false
var imported_deck_list : DeckList

@onready var host_game_ui_container = $Matchmaking/Host_game_ui_container
@onready var custom_match_name = $Matchmaking/Host_game_ui_container/custom_match_name
@onready var cancel_game_ui_container = $Matchmaking/Cancel_game_ui_container
@onready var hosted_match_name = $Matchmaking/Cancel_game_ui_container/hosted_match_name
@onready var match_game_container = $Matchmaking/Match_game_list/MarginContainer/MatchGameContainer
@onready var cancel_hosted_game_button = $Matchmaking/Cancel_game_ui_container/cancel_hosted_game_button
@onready var join_game_button = $Matchmaking/HBoxContainer/join_game_button
@onready var deck_import = $DeckImport
@onready var file_dialog_load_deck = $DeckImport/FileDialogLoadDeck

func _ready():
	host_game_ui_container.show()
	cancel_game_ui_container.hide()
	deck_import.hide()
	file_dialog_load_deck.hide()
	Global.player_is_host = false

func _on_host_game_button_pressed():
	# Create the multiplayer bridge
	Global.player_is_host = true
	setupMutilplayerBridge()
	
	# Joined the multiplayer bridge match
	Global.joined_match = await Global.multiplayerbridge.join_named_match(custom_match_name.text)
	
	host_game_ui_container.hide()
	cancel_game_ui_container.show()

func setupMutilplayerBridge():
	Global.multiplayerbridge = NakamaMultiplayerBridge.new(Global.socket)
	Global.multiplayerbridge.match_join_error.connect(_on_match_join_error)
	Global.multiplayerbridge.match_joined.connect(_on_match_joined)
	multiplayer.multiplayer_peer = Global.multiplayerbridge.multiplayer_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	if Global.player_is_host:
		var created_bridge_properties = {
			"match_name" : custom_match_name.text,
			"match_creator" : Global.session.username
		}
		
		var created_bridge_properties_json = JSON.stringify(created_bridge_properties)
		
		var _created_bridge_storage = await  Global.client.write_storage_objects_async(
			Global.session,[
				NakamaWriteStorageObject.new(
					"Matches",
					"Open_Match",
					2,
					1, 
					created_bridge_properties_json,
					"")
			]
		)

func _on_match_join_error(error):
	show_error_ui("Failed to Join match",error.message)

func _on_match_joined():
	print("joined matched with id of : " + Global.multiplayerbridge.match_id)
	
	# Set the Nakama Unique ID to the Player ID
	# This is used for validating the owner/controller of cards
	Global.player_id = multiplayer.get_unique_id()
	

func _on_peer_connected(id):
	print("Peer conencted id : " + str(id))
	
	# Check for and add the peer
	if !Global.players_in_match.has(id):
		
		# Get the peer info, has username and other info
		var connected_peer_info = Global.multiplayerbridge.get_user_presence_for_peer(id)
		
		Global.players_in_match[id] = {
			"player_id" : id,
			"player_username" : connected_peer_info.username
		}
	
	# Check for and add the host
	if !Global.players_in_match.has(multiplayer.get_unique_id()):
		Global.players_in_match[multiplayer.get_unique_id()] = {
			"player_id" : multiplayer.get_unique_id(),
			"player_username" : Global.session.username
		}
	
	# Set the Nakama Unique ID to the Player ID
	# This is used for validating the owner/controller of cards
	Global.player_id = multiplayer.get_unique_id()
	print("test")
	
	# If ther are two players connecte in the match start it
	if multiplayer.is_server():
		if Global.players_in_match.size() == 2:
			start_match.rpc()

func _on_peer_disconnected(id):
	print("Peer disconnected id : " + str(id))

@rpc("any_peer","call_local")
func start_match():
	# Move players to battle scene
	get_tree().change_scene_to_packed(BATTLE_SCENE)

func _on_cancel_hosted_game_button_pressed():
	await Global.socket.leave_match_async(Global.joined_match.match_id)
	cancel_game_ui_container.hide()
	host_game_ui_container.show()
	join_game_button.disabled = false

func _on_refresh_game_list_button_pressed():
	var open_match_list = await Global.client.list_storage_objects_async(
		Global.session,
		"Matches",
		"",
		100,
		null
	)
	_update_match_list(open_match_list)

func show_error_ui(title:String,message: String):
	print("Error is" + title + message)

func _update_match_list(match_list):
	# Remove all matches regardless if current or not
	for i in match_game_container.get_children():
		i.queue_free()
	
	# Add all current matches
	for i in match_list.objects:
		var i_parsed = JSON.parse_string(i.value)
		var new_match_selection_ui := MATCH_SELECTION_UI_SCENE.instantiate() as MatchSelectionUI
		match_game_container.add_child(new_match_selection_ui)
		new_match_selection_ui.match_creator.text = i_parsed.match_creator
		new_match_selection_ui.match_name.text = i_parsed.match_name
		new_match_selection_ui.match_button.pressed.connect(_update_selected_match.bind(new_match_selection_ui))
	

func _update_selected_match(selected_match_ui: MatchSelectionUI):
	selected_match_name = selected_match_ui.match_name.text

func _set_selected_match_name(value: String):
	selected_match_name = value
	# Check if a match has been selected, and if the user is hosting a match
	if selected_match_name:
		if Global.player_is_host:
			join_game_button.disabled = true
		else:
			join_game_button.disabled = false
	else:
		join_game_button.disabled = true

func _on_join_game_button_pressed():
	# Check if a match id is selected first
	if not selected_match_name:
		show_error_ui("No match selected","")
	
	# Setup multiplayer bridge
	Global.player_is_host = false
	setupMutilplayerBridge()
	
	# Join multplayerbridge match
	Global.joined_match = await Global.multiplayerbridge.join_named_match(selected_match_name)
	

func _on_import_deck_accio_button_pressed():
	is_importing_decklist = true
	_show_deck_import()

func _show_deck_import():
	deck_import.show()
	file_dialog_load_deck.show()
	# Only works for windows, need to have OS detector and switch default value
	file_dialog_load_deck.current_dir = "C:\\Users"
	file_dialog_load_deck.add_filter("*.txt, Text File")

func _hide_deck_import():
	deck_import.hide()
	file_dialog_load_deck.hide()

func _on_file_dialog_load_deck_file_selected(path):
	
	# Hide the canvar layer
	_hide_deck_import()
	
	# Check that file exists
	if FileAccess.file_exists(path):
		# Create the new deck list
		imported_deck_list = DeckList.new()
		
		# Get the file and read the text
		var deck_file = FileAccess.open(path, FileAccess.READ)
		var deck_file_text = deck_file.get_as_text()
		
		# Get File Name or Prompt User
		imported_deck_list.name = "Imported_Deck"
		
		# Split the file into three sections. Main Deck, Sideboard, Starting Character
		var deck_file_text_split = deck_file_text.split("//",true)
		
		# Loop through each section and check what section you are in
		for card_section_in_deck_file in deck_file_text_split:
			if card_section_in_deck_file.contains("deck"):
				# Split on the new line to get each entry
				var cards_in_main_deck = card_section_in_deck_file.split("\n",false)
				for current_card in cards_in_main_deck:
					# Skip the line that says "deck-1"
					if not current_card == "deck-1":
						# Split on the space to get the card name and count
						var current_card_split = current_card.split(" ",false,1)
						
						# Add the card to the deck
						add_card_to_main_deck(current_card_split[0],current_card_split[1])
					
			if card_section_in_deck_file.contains("sideboard"):
				# Split on the new line to get each entry
				var cards_in_sideboard = card_section_in_deck_file.split("\n",false)
				for current_card in cards_in_sideboard:
					# Skip the line that says "sideboard-1"
					if not current_card == "sideboard-1":
						# Split on the space to get the card name and count
						var current_card_split = current_card.split(" ",false,1)
						
						# Add the card to the sideboard
						add_card_to_side_board(current_card_split[0],current_card_split[1])
			if card_section_in_deck_file.contains("play"):
				# Split on the new line to get each entry
				var starting_character = card_section_in_deck_file.split("\n",false)
				
				# There should be only one starting character, but size is 2 because of the
				# line of "play-1" break out if not
				if not starting_character.size() == 2:
					print("More than one starting character fix it")
					return
				
				# Split on the space to get the card name and count, get the 2nd line because
				# The first line is the "play-1"
				var starting_character_split = starting_character[1].split(" ",false,1)
				
				# Add the starting character to the deck
				add_card_as_starting_character(starting_character_split[1])
			
		
	

func add_card_to_main_deck(card_amount_to_add:String, card_name_to_add:String):
	var main_deck_card_resource_path = CardLookup.get_resource_path(card_name_to_add)
	for i in card_amount_to_add:
		imported_deck_list.main_deck.cards.append(main_deck_card_resource_path)
	print("Add ", card_amount_to_add, " copies of ", card_name_to_add, " to the main deck")

func add_card_to_side_board(card_amount_to_add:String, card_name_to_add:String):
	var side_board_card_resource_path = CardLookup.get_resource_path(card_name_to_add)
	for i in card_amount_to_add:
		imported_deck_list.side_board.cards.append(side_board_card_resource_path)
	print("Add ", card_amount_to_add, " copies of ", card_name_to_add, " to the side board")

func add_card_as_starting_character(card_name_to_add:String):
	print("Add ", card_name_to_add, " as the starting character")
