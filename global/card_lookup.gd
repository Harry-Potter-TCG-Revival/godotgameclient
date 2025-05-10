extends Node

var card_resource_path_dict : Dictionary = {
	# Base Set
	"Dean Thomas" : "res://cards/base_set/resources/dean_thomas.tres"
}

func get_resource_path(cardname: String) -> String:
	return card_resource_path_dict[cardname]
