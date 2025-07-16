class_name PowerStatsUI
extends VBoxContainer

@export var player_stats: PlayerStats : set = _set_player_stats

@onready var transfiguration_power_image = %TransfigurationPowerImage
@onready var charms_power_image = %CharmsPowerImage
@onready var potions_power_image = %PotionsPowerImage
@onready var care_of_magical_creatures_power_image = %CareOfMagicalCreaturesPowerImage
@onready var quidditch_power_image = %QuidditchPowerImage
@onready var transfiguration_power_count = %TransfigurationPowerCount
@onready var charms_power_count = %CharmsPowerCount
@onready var potions_power_count = %PotionsPowerCount
@onready var care_of_magical_creatures_power_count = %CareOfMagicalCreaturesPowerCount
@onready var quidditch_power_count = %QuidditchPowerCount
@onready var total_power_count = %TotalPowerCount

func _set_player_stats(value: PlayerStats) -> void:
	player_stats = value
	
	if not player_stats.stats_changed.is_connected(_on_stats_changed):
		player_stats.stats_changed.connect(_on_stats_changed)
	
	if not is_node_ready():
		await  ready
	
	_on_stats_changed()

func _on_stats_changed() -> void:
	transfiguration_power_count.text = str(player_stats.transfiguration_power_count)
	transfiguration_power_image.visible = player_stats.transfiguration_power_count > 0
	
	charms_power_count.text = str(player_stats.charms_power_count)
	charms_power_image.visible = player_stats.charms_power_count > 0
	
	potions_power_count.text = str(player_stats.potions_power_count)
	potions_power_image.visible = player_stats.potions_power_count > 0
	
	care_of_magical_creatures_power_count.text = str(player_stats.care_of_magical_creatures_power_count)
	care_of_magical_creatures_power_image.visible = player_stats.care_of_magical_creatures_power_count > 0
	
	quidditch_power_count.text = str(player_stats.quidditch_power_count)
	quidditch_power_image.visible = player_stats.quidditch_power_count > 0
	
	var totalpower = (player_stats.transfiguration_power_count) \
	+ (player_stats.charms_power_count) \
	+ (player_stats.potions_power_count) \
	+ (player_stats.care_of_magical_creatures_power_count) \
	+ (player_stats.quidditch_power_count)
	
	total_power_count.text = "Total Power :" + str(player_stats.total_power_count)
	total_power_count.visible = totalpower > 0
