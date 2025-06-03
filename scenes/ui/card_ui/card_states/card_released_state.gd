class_name CardReleasedState
extends CardState

var played: bool

func enter() -> void:
	print("entered released state")
	card_ui.statetext.text = "Released"
	
	# Because we just entered the released state the card is not played yet
	played = false
	
	# Check if the card_ui has any targets, meaning it is over the card drop area
	if not card_ui.targets.is_empty():
		played = true
		
		card_ui.play()
		
		# A timer is used so that the enter() function finishes and we properly enter the state
		if card_ui.card.goes_in_play():
			print("going to in in play state")
			get_tree().create_timer(.1).timeout.connect(move_card_to_inplay)
		else:
			print("going to Spell Zone state")
			get_tree().create_timer(.1).timeout.connect(move_card_to_spell_zone)
		
	

func move_card_to_inplay() -> void:
	card_state_transition_requested.emit(self, CardState.State.IN_PLAY)

func move_card_to_spell_zone() -> void:
	card_state_transition_requested.emit(self, CardState.State.SPELLZONE)

func on_gui_input(_event: InputEvent) -> void:
		if played:
			return
		
		# If there is no area, than the card was released outside the card drop area
		# And the card show be put back into the hand.
		print("going to hand state")
		card_state_transition_requested.emit(self, CardState.State.HAND)
	
