class_name LevelUI
extends CanvasLayer

@export var player:Player

@onready var hp_bar: LifeBar = $HealthBars/hp_bar
@onready var umbrella_bar: LifeBar = $HealthBars/umbrella_bar

func _ready() -> void:
	if player:
		pass
	else:
		player = get_tree().get_first_node_in_group("player")
	
	await get_tree().process_frame
	
	hp_bar.setup(player)
	umbrella_bar.setup(player.umbrella)
