class_name DeckMenu
extends Control

@onready var deck_ui_container = $DeckUIContainer

# Load here creates a pointer, preload isnt needed since its already loaded
var MAIN_MENU_SCENE = load("res://scenes/main_menu/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_main_menu_pressed():
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)
	
