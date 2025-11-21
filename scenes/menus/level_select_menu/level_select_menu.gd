extends Control

## Loads a simple ItemList node within a margin container. SceneLister updates
## the available scenes in the directory provided. Activating a level will update
## the GameState's current_level, and emit a signal. The main menu node will trigger
## a load action from that signal.

signal level_selected
signal close

@onready var level_buttons_container: ItemList = %LevelButtonsContainer
@onready var scene_lister: SceneLister = $SceneLister
var level_paths : Array[String]

var last_selected:int = -1

@onready var play_button: Button = %PlayButton


func _ready() -> void:
	add_levels_to_container()
	
## A fresh level list is propgated into the ItemList, and the file names are cleaned
func add_levels_to_container() -> void:
	level_buttons_container.clear()
	level_paths.clear()
	var game_state := GameState.get_or_create_state()
	for file_path in game_state.level_states.keys():
		var file_name : String = file_path.get_file()  # e.g., "level_1.tscn"
		file_name = file_name.trim_suffix(".tscn")  # Remove the ".tscn" extension
		file_name = file_name.replace("_", " ")  # Replace underscores with spaces
		file_name = file_name.capitalize()  # Convert to proper case
		var button_name := str(file_name)
		level_buttons_container.add_item(button_name)
		level_paths.append(file_path)



func _unhandled_input(event: InputEvent) -> void:
	# Accept key activation
	if event.is_action_pressed("ui_accept") and last_selected != -1:
		start_level(last_selected)
		return


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Only act on left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			reset_selection()


func reset_selection():
	last_selected = -1
	level_buttons_container.deselect_all()
	play_button.disabled = true


func start_level(index:int) -> void:
	GameState.set_current_level(level_paths[index])
	level_selected.emit()


func _on_level_buttons_container_item_activated(index: int) -> void:
	start_level(index)


func _on_level_buttons_container_item_clicked(index: int, _pos: Vector2, mouse_button_index: int) -> void:
	# Ignore scroll wheel events
	if mouse_button_index == MOUSE_BUTTON_WHEEL_UP or mouse_button_index == MOUSE_BUTTON_WHEEL_DOWN:
		return

	print("last_selected = %d, clicked_index = %d" % [last_selected, index])
	if last_selected == index:
		start_level(index)
	else:
		last_selected = index
		if last_selected == -1:
			play_button.disabled = true
		else:
			play_button.disabled = false





func _on_close_button_pressed() -> void:
	close.emit()


func _on_play_button_pressed() -> void:
	if last_selected != -1:
		start_level(last_selected)
