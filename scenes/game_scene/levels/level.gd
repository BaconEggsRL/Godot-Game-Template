extends Node

signal pause_pressed
signal restart_pressed

signal level_lost
signal level_won
signal level_won_and_changed(level_path : String)

## Optional path to the next level if using an open world level system.
@export_file("*.tscn") var prev_level_path : String
@export_file("*.tscn") var next_level_path : String

@onready var filename := get_scene_file_path().get_file().get_basename()
@onready var level_num := filename.trim_prefix("level_").to_int()

var level: Node2D
var spikes: Node2D
var level_ui: LevelUI
var player: Player

var level_state : LevelState


		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		restart_pressed.emit()

func _on_lose_button_pressed() -> void:
	level_lost.emit()

func _on_win_button_pressed() -> void:
	if not next_level_path.is_empty():
		level_won_and_changed.emit(next_level_path)
	else:
		level_won.emit()

func open_tutorials() -> void:
	%TutorialManager.open_tutorials()
	level_state.tutorial_read = true
	GlobalState.save()



func _ready() -> void:
	level = get_node_or_null("level")
	level_ui = get_node_or_null("LevelUI")
	if level:
		spikes = level.get_node_or_null("spikes")
		player = level.get_node_or_null("player")
	if spikes:
		for spike in spikes.get_children():
			spike.hit_spike.connect(_on_hit_spike)
	if level_ui:
		level_ui.pause.connect(_on_level_ui_pause)
		level_ui.prev.connect(_on_level_ui_prev)
		level_ui.restart.connect(_on_level_ui_restart)
		level_ui.skip.connect(_on_level_ui_skip)
		level_ui.level_num = level_num
	
	
	level_state = GameState.get_level_state(scene_file_path)
	# %ColorPickerButton.color = level_state.color
	# %BackgroundColor.color = level_state.color
	if not level_state.tutorial_read:
		open_tutorials()


func _on_color_picker_button_color_changed(color : Color) -> void:
	# %BackgroundColor.color = color
	level_state.color = color
	GlobalState.save()

func _on_tutorial_button_pressed() -> void:
	open_tutorials()





func _on_star_reached_star() -> void:
	_on_win_button_pressed()

func _on_hit_spike() -> void:
	restart_pressed.emit()




func _on_level_ui_pause() -> void:
	pause_pressed.emit()

func _on_level_ui_prev() -> void:
	if not prev_level_path.is_empty():
		level_won_and_changed.emit(prev_level_path)
	else:
		level_won.emit()

func _on_level_ui_restart() -> void:
	print("hello?")
	restart_pressed.emit()

func _on_level_ui_skip() -> void:
	_on_win_button_pressed()
