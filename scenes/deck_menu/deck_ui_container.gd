class_name DeckUIContainer
extends GridContainer

@onready var deck_ui_scene := preload("res://scenes/deck_menu/deck_ui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Loop through and Create DeckUI's
	for i in Global.player_stats.deck_lists:
		var new_deck_ui = deck_ui_scene.instantiate()
		add_child(new_deck_ui)
		
		new_deck_ui.deck_list = i
	
