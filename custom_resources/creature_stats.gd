class_name CreatureStats
extends Stats

var card: Card
var max_health : int
var is_damaged : bool
var damage_taken : int

@export var base_health : int
@export var damage_per_turn : int

func _init():
	max_health = base_health
	damage_taken = 0

func take_damage(damage_amount : int) -> void:
	if damage_amount <= 0:
		return
	
	damage_taken += damage_amount
	
	# When a creature takes more damage than it has health, call the creature_died function
	if max_health <= damage_taken:
		creature_died()
	
	# When a creature takes damage instantiate a damage counter scene
	if is_damaged:
		# The creature is already damaged so just update the damage counter
		# FIXME
		pass
	else:
		# Creature is just now being damaged, instantiate damage counter
		# FIXME
		# Set the is_damaged to true, so the next damage instance gets handled correctly
		is_damaged = true
	

func do_damage() -> void:
	# Do damage equal to the damage per turn
	# FIXME
	pass

func remove_damage(amount : int) -> void:
	# When a creature gets its damage counters remove update the number
	#FIXME
	# The value is clamped here so damage taken doesnt go below 0
	damage_taken = clampi(damage_taken - amount,0,damage_taken)
	
	# When a creature has all its damage removed, call the remove_all_damage func
	if damage_taken == 0:
		remove_all_damage()

func remove_all_damage() -> void:
	# When a creature has all its damage removed, un-instantiate the damage counter scene
	#FIXME
	
	# Set the is_damage to false for the next intance of damage to be handled correctly
	is_damaged = false

# This function expects the amount to be passed as a positive or negative integer
func update_max_health(amount : int) -> void:
	# FIXME This needs to know what the source of the max health is, so that specific instance
	# can be removed, this also is needed to support multiple differnt max health buffs
	
	# A card should not be allowed to reduce the max health more than its addition
	# But we clamp the floor value to just ensure it
	# There is no ceiling to clamp here
	max_health = clampi(max_health + amount,base_health,999)
	
	# It is possible that if a creature loses its max health it will die, need to check here
	if max_health <= damage_taken:
		creature_died()
	

func creature_died() -> void:
	# Set the is_damage to false, this is reset the status if the card gets replayed
	is_damaged = false
	
	# Set the damge_taken to 0, this is reset the status if the card gets replayed
	damage_taken = 0
	
	# Loop through all the counters and remove them
	# FIXME
	
	# Discard the card as the creature has died
	Events.discard_card_requested.emit(card)
