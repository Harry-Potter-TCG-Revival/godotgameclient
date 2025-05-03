class_name LoginPage
extends Control

var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var received_error_message : String

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
	# manually hiding/showing these is redundant but is helpful for testing
	login_ui.show()
	register_ui.hide()
	error_ui.hide()
	# Local Host Testing
	#client = Nakama.create_client("defaultkey","127.0.0.1",7350,"http")
	# Hosted Internet Testing (do not use for PROD)
	client = Nakama.create_client("AGgpLqM45wdkEIH4PMvs5c90T6HxtrBV","164.90.255.189",7350,"https")

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
	
	# transition player to the main menu
	Global.client = client
	Global.session = session
	Global.socket = socket
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)

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
	
	# Update Account
	var update_account_request = await client.update_account_async(session,user_name_register_input.text,display_name_register_input.text)
	
	if session.is_exception():
		var exception = session.get_exception()
		show_error_ui("Failed to Create Account",exception.message)
		return
	
	if update_account_request.is_exception():
		var exception = update_account_request.get_exception()
		show_error_ui("Failed to Update Account", exception.message)
		return
	
	socket = Nakama.create_socket_from(client)
	
	await socket.connect_async(session)
	
	socket.connected.connect(_on_socket_connected)
	socket.closed.connect(_on_socket_closed)
	socket.received_error.connect(_on_socket_received_error)
	
	# transition player to the main menu
	Global.client = client
	Global.session = session
	Global.socket = socket
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)

func _on_cancel_register_account_pressed():
	register_ui.hide()
	login_ui.show()
