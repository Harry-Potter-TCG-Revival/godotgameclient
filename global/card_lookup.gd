extends Node

var card_resource_path_dict : Dictionary = {
	# Base Set
	"Dean Thomas" : "res://cards/base_set/resources/001-Base-DeanThomas.tres",
	#"Draco Malfoy" : "res://cards/base_set/resources/002-Base-DracoMalfoy.tres",
	"Draco Malfoy" : "res://cards/base_set/resources/003-Base-DracoMalfoy.tres",
	"Dragon's Escape" : "res://cards/base_set/resources/004-Base-DragonsEscape.tres",
	"Elixir of Life" : "res://cards/base_set/resources/005-Base-ElixirOfLife.tres",
	"Gringotts' Cart Ride" : "res://cards/base_set/resources/006-Base-GringottsCartRide.tres",
	"Hannah Abbott" : "res://cards/base_set/resources/007-Base-HannahAbbott.tres",
	"Harry Potter" : "res://cards/base_set/resources/008-Base-HarryPotter.tres",
	#"Hermione Granger" : "res://cards/base_set/resources/009-Base-HermioneGranger.tres",
	"Hermione Granger" : "res://cards/base_set/resources/010-Base-HermioneGranger.tres",
	"Human Chess Game" : "res://cards/base_set/resources/011-Base-HumanChessGame.tres",
	"Invisibility Cloak" : "res://cards/base_set/resources/012-Base-InvisibilityCloak.tres",
	"Nearly Headless Nick" : "res://cards/base_set/resources/013-Base-NearlyHeadlessNick.tres",
	"Obliviate" : "res://cards/base_set/resources/014-Base-Obliviate.tres",
	"Professor Filius Flitwick" : "res://cards/base_set/resources/015-Base-ProfessorFiliusFlitwick.tres",
	"Professor Severus Snape" : "res://cards/base_set/resources/016-Base-ProfessorSeverousSnape.tres",
	"Ron Weasley" : "res://cards/base_set/resources/017-Base-RonWeasley.tres",
	"Rubeus Hagrid" : "res://cards/base_set/resources/018-Base-RubeusHagrid.tres",
	"Troll in the Bathroom" : "res://cards/base_set/resources/019-Base-TrollintheBathroom.tres",
	"Unicorn" : "res://cards/base_set/resources/020-Base-Unicorn.tres"
}

func get_resource_path(cardname: String) -> String:
	return card_resource_path_dict[cardname]
