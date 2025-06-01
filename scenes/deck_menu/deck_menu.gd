class_name DeckMenu
extends Control

# Load here creates a pointer, preload isnt needed since its already loaded
var MAIN_MENU_SCENE = load("res://scenes/main_menu/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_main_menu_pressed():
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)
	
