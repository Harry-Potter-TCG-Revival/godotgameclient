class_name LoginPage
extends Control

var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var received_error_message : String
var New_Player_Stats : PlayerStats

const MAIN_MENU_SCENE := preload("res://scenes/main_menu/main_menu.tscn")

@onready var login_ui = $LoginUI
@onready var email_input = $LoginUI/VBoxContainer/EmailInput
@onready var password_input = $LoginUI/VBoxContainer/PasswordInput

@onready var error_ui = $ErrorUI
@onready var error_label = $ErrorUI/ErrorLabel
@onready var error_message = $ErrorUI/ErrorMessage

@onready var register_ui = $RegisterUI
@onready var email_register_input = $RegisterUI/VBoxContainer/EmailRegisterInput
@onready var user_name_register_input = $RegisterUI/VBoxContainer/UserNameRegisterInput
@onready var display_name_register_input = $RegisterUI/VBoxContainer/DisplayNameRegisterInput
@onready var password_register_input = $RegisterUI/VBoxContainer/PasswordRegisterInput

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set Auto Login to help with Testing
	Global.auto_login = true
	
	# manually hiding/showing these is redundant but is helpful for testing
	login_ui.show()
	register_ui.hide()
	error_ui.hide()
	# Local Host Testing
	client = Nakama.create_client("defaultkey","127.0.0.1",7350,"http")
	# Hosted Internet Testing (do not use for PROD)
	#client = Nakama.create_client("defaultkey","api.finepointcgi.online",7350,"http")
	
	if Global.auto_login :
		auto_login()

func auto_login():
	email_input.text = "test@gmail.com"
	password_input.text = "Password"
	_on_login_button_pressed()

func _on_login_button_pressed():
	session = await client.authenticate_email_async(email_input.text,password_input.text,null,false)
	
	if session.is_exception():
		var exception = session.get_exception()
		show_error_ui("Login Failed",exception.message)
		return
	
	socket = Nakama.create_socket_from(client)
	
	socket.connected.connect(_on_socket_connected)
	socket.closed.connect(_on_socket_closed)
	socket.received_error.connect(_on_socket_received_error)
	
	await socket.connect_async(session)
	
	_on_successfull_login()

func _on_socket_connected():
	print("socket connected")

func _on_socket_closed():
	print("socket closed")

func _on_socket_received_error(error):
	print("The following error happened when trying to connect" + error)

func show_error_ui(title: String, message: String):
	error_label.text = title
	error_message.text = message
	error_ui.show()

func _on_start_register_button_pressed():
	login_ui.hide()
	register_ui.show()

func _on_finish_register_account_pressed():
	# Create Account
	session = await client.authenticate_email_async(email_register_input.text,password_register_input.text,user_name_register_input.text,true)
	
	if session.is_exception():
		var exception = session.get_exception()
		show_error_ui("Failed to Create Account",exception.message)
		return
	
	# Update Account
	var update_account_request = await client.update_account_async(session,user_name_register_input.text,display_name_register_input.text)
	
	if update_account_request.is_exception():
		var exception = update_account_request.get_exception()
		show_error_ui("Failed to Update Account", exception.message)
		return
	
	socket = Nakama.create_socket_from(client)
	
	await socket.connect_async(session)
	
	socket.connected.connect(_on_socket_connected)
	socket.closed.connect(_on_socket_closed)
	socket.received_error.connect(_on_socket_received_error)
	
	_on_successfull_login()
	


func _on_cancel_register_account_pressed():
	register_ui.hide()
	login_ui.show()

func _on_successfull_login() -> void:
	# Setup Global Multiplayer Networking
	Global.client = client
	Global.session = session
	Global.socket = socket
	
	# Setup new player stats and save it to disk
	New_Player_Stats = PlayerStats.new()
	New_Player_Stats.player_name = Global.session.username
	New_Player_Stats.deck_lists = await download_deck_lists()
	# Change this to pull from the nakama storage
	New_Player_Stats.card_back = load("res://art/cards/card_backs/HPTCG-RevivalBack.png")
	# Change this to pull from the nakama storage
	New_Player_Stats.player_avatar = load("res://art/player_avatars/owl_brown.jpg")
	
	Global.local_player_stats = New_Player_Stats
	
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)

func download_deck_lists() -> Array[DeckList]:
	var new_player_deck_lists: Array[DeckList] = []
	
	# Get Deck Lists from Nakama
	var nakama_deck_lists = await Global.client.list_storage_objects_async(
		Global.session,
		"Deck_List",
		Global.session.user_id,
		100,
		null
	)
	
	for i in nakama_deck_lists.objects:
		var i_parsed = JSON.parse_string(i.value)
		var new_player_deck = download_deck_list(i_parsed,i.version)
		new_player_deck_lists.append(new_player_deck)
	
	return new_player_deck_lists
	

func download_deck_list(downloaded_deck_list,downloaded_deck_version: String) -> DeckList:
	# Check if decklist is already downloaded
	
	# Initialize the new deck list
	var new_deck_list = DeckList.new()
	new_deck_list.main_deck = CardPile.new()
	new_deck_list.side_board = CardPile.new()
	
	# Set the deck info
	new_deck_list.image = load(downloaded_deck_list.Deck_Info.Card_Back)
	new_deck_list.name = downloaded_deck_list.Deck_Info.Name
	new_deck_list.version = downloaded_deck_version
	new_deck_list.starting_character = load(downloaded_deck_list.Deck_Info.Starting_Character)
	
	# Setup Main Deck
	for i in downloaded_deck_list.Main_Deck:
		# Add Card by loading the resource using the path
		new_deck_list.main_deck.cards.append(load(downloaded_deck_list.Main_Deck[i]))
	
	# Setup Side Board
	for i in downloaded_deck_list.Side_Board:
		# Add Card by loading the resource using the path
		new_deck_list.side_board.cards.append(load(downloaded_deck_list.Side_Board[i]))
	
	return new_deck_list
	
