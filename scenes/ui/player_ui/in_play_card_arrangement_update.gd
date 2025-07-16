extends ColorRect

@export var y_separation: float = 20

var child_index : int
var column_count : int = 4
var grid_separation : int = 5
var margin : int = 5
var child_max_index : int
var child_array : Array
var child_scale_factor : float = .7
var child_scale_factor_tight : float = .34
var child_scaled_size : Vector2
var card_ui_reference = Global.card_ui_reference

func update_cards_tight() -> void:
	# Get all children and reset index
	var child_count := get_child_count()
	child_array = get_children()
	child_index = 0
	
	# Calculate the scaled size of cards
	child_scaled_size = card_ui_reference.card_size * child_scale_factor_tight
	var child_y := child_scaled_size.x
	
	# Adjust the minmum size if there are any children: collasible UI
	if child_count >= 1:
		custom_minimum_size.x = child_scaled_size.y
	else :
		custom_minimum_size.x = 0
	
	# X is used to calculate height/y because the card is rotated 90 degrees here
	var all_cards_y := child_y + (y_separation * (child_count-1))
	
	if all_cards_y > size.y:
		y_separation = (size.y - child_y) / (child_count - 1)
	
	for i in child_array:
		# Set the cards scale
		i.scale = Vector2(child_scale_factor_tight,child_scale_factor_tight)
		
		# Rotate the card 90 degrees. Because card is rotated X and Y are swapped now
		i.rotation_degrees = 90
		
		# The pivot offset is always half the card size
		var child_pivot_offset = card_ui_reference.card_size / 2
		
		# Calcualte how much needs to be offset due to 90 degree rotation
		var x_child_rotation_offset = child_pivot_offset.y - child_pivot_offset.x
		var y_child_rotation_offset = child_pivot_offset.x - child_pivot_offset.y
		
		# Calculate how much needs to be offset due to scaling
		var x_child_scale_offset = child_pivot_offset.y * (1 - child_scale_factor_tight)
		var y_child_scale_offset = child_pivot_offset.x * (1 - child_scale_factor_tight)
		
		# Calculate the offset of the card
		var x_offset = x_child_rotation_offset - x_child_scale_offset - child_scaled_size.y
		var y_offset = y_child_rotation_offset - y_child_scale_offset
		
		# set the y value based on cards above it
		var y_position: float =  y_separation * child_index + y_offset
		
		# Because the card is rotated, its X gets offset by its Y value
		var x_position = child_scaled_size.y + x_offset
		
		# Set the cards position
		i.position = Vector2(x_position,y_position)
		
		# Increment child_index to match loop progress
		child_index += 1
	

func update_cards_grid() -> void:
	# Get all children and reset index
	child_array = get_children()
	child_index = 0
	
	# Calculate the scaled size of cards
	child_scaled_size = card_ui_reference.card_size * child_scale_factor
	
	# Get the max index of the children to find the max rows needed
	child_max_index = get_child_count() - 1
	
	# 1 is added because index starts at 0
	var max_rows_needed = (child_max_index / column_count) + 1
	var max_rows_allowed = size.y / (child_scaled_size.x + grid_separation)
	
	# Calculate the new scale needed to have all rows fit in the node
	if max_rows_needed > max_rows_allowed:
		var adjusted_row_y = size.y / max_rows_needed
		var adjusted_card_y = adjusted_row_y - grid_separation
		child_scale_factor = adjusted_card_y / card_ui_reference.card_size.x
		child_scaled_size = card_ui_reference.card_size * child_scale_factor
		
		# Since cards have been scaled down check if another column can fit
		var adjusted_row_x = (child_scaled_size.y + grid_separation)  * column_count
		var space_row_x = size.x - adjusted_row_x
		var col_to_add: int = space_row_x / child_scaled_size.y
		column_count += col_to_add
	
	# The pivot offset is always half the card size
	var child_pivot_offset = card_ui_reference.card_size / 2
	
	# Calcualte how much needs to be offset due to 90 degree rotation
	var x_child_rotation_offset = child_pivot_offset.y - child_pivot_offset.x
	var y_child_rotation_offset = child_pivot_offset.x - child_pivot_offset.y
	
	# Calculate how much needs to be offset due to scaling
	var x_child_scale_offset = child_pivot_offset.y * (1 - child_scale_factor)
	var y_child_scale_offset = child_pivot_offset.x * (1 - child_scale_factor)
	
	# Calculate the offset of the card
	var x_offset = x_child_rotation_offset - x_child_scale_offset
	var y_offset = y_child_rotation_offset - y_child_scale_offset
	
	# Position each card in the grid
	for i in child_array:
		# Set the cards scale
		i.scale = Vector2(child_scale_factor,child_scale_factor)
		
		# Rotate the card 90 degrees. Because card is rotated X and Y are swapped now
		i.rotation_degrees = 90
		
		# Find grid position. Column and Row
		var row : int = child_index / column_count
		var col : int = child_index % column_count
		
		# Set the position based on other cards already in the grid
		var x_position = margin + (col * grid_separation) + (col * child_scaled_size.y) + x_offset
		var y_position = margin + (row * grid_separation) + (row * child_scaled_size.x) + y_offset
		i.position = Vector2(x_position,y_position)
		
		# Increment child_index to match loop progress
		child_index += 1
	
	# Grid container source code
	# https://github.com/godotengine/godot/blob/419e713a29f20bd3351a54d1e6c4c5af7ef4b253/scene/gui/grid_container.cpp
	
