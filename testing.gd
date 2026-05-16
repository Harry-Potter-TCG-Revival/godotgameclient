extends Node2D

enum State {BEFOREYOURTURN,DRAW,CREATUREDAMAGE,ACTION,ENDOFYOURTURN,OPPONENTSTURN}

var players_in_match : Dictionary
var rng = RandomNumberGenerator.new()

func _ready():
	var new_state = State.keys()[0]
	print("zero index key is ",new_state)

func add_player(id,username:String,roll:int):
	players_in_match[id] = {
			"player_id" : id,
			"player_username" : username,
			"ready_status" : 0,
			"turn_order_roll" : roll
		}
	print(players_in_match)

func _on_button_pressed():
	rng = randi_range(1,20)
	add_player(1,"player1",rng)


func _on_button_2_pressed():
	rng = randi_range(1,20)
	add_player(2,"player2",rng)


func _on_button_3_pressed():
	if players_in_match.values()[0].turn_order_roll > players_in_match.values()[1].turn_order_roll:
		print("Player1 is going first")
	else:
		print("Player2 is going first")
	
