class_name CardSpellZoneState
extends CardState

var resolved : bool

func enter() -> void:
	print("entered SpellZone state")
	card_ui.statetext.text = "Spell Zone"
	
	# Clear the current targets so only new valid targets exist
	card_ui.targets.clear()
	
	# Animate Card to Spell Zone
	await card_ui.animate_to_position(Vector2(1600,400),.6)
	
	# Start resolving the spell
	card_ui.card.spell_effect(card_ui.player_stats)
	
