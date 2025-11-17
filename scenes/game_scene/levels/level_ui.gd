class_name LevelUI
extends CanvasLayer

var level_num:int :
	set(value):
		level_num = value
		level_label.text = "Level %d" % level_num
		
var player:Player

@onready var hp_bar: LifeBar = $HealthBars/hp_bar
@onready var umbrella_bar: LifeBar = $HealthBars/umbrella_bar
@onready var level_label: Label = $LevelLabel


signal prev
signal restart
signal skip
signal pause


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	await get_tree().process_frame
	
	hp_bar.setup(player)
	umbrella_bar.setup(player.umbrella)



func _on_prev_btn_pressed() -> void:
	prev.emit()

func _on_restart_btn_pressed() -> void:
	restart.emit()

func _on_skip_btn_pressed() -> void:
	skip.emit()

func _on_pause_btn_pressed() -> void:
	pause.emit()
