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

# @onready var scroll_container: ScrollContainer = $Control/ScrollContainer
@export var scroll_container: SmoothScrollContainer

var hold_dir := 0        # -1 = up, +1 = down, 0 = none
var hold_delay := 0.0    # time until next repeat
const INITIAL_REPEAT := 0.35   # delay before repeat starts
const HOLD_REPEAT := 0.06      # repeat speed while holding

var first_move:bool = false
var time_since_last_press:float = 0.0



func select_level_index(index:int) -> void:
	# print(index)
	if level_paths.is_empty():
		return

	if last_selected == index:
		return
	
	last_selected = index
	level_buttons_container.select(index, true)
	play_button.disabled = false
	
	AudioManager.play_sound("tab_press", -6.0, 1.0, true)
	time_since_last_press = 0.0
	
	# --- KEEP SELECTED ITEM VISIBLE ---
	# scroll_container.ensure_control_visible(child_node)
	# var v_scroll = scroll_container.get_v_scroll_bar()
	# v_scroll.set_value_no_signal(0.5)

#
func _process(delta: float) -> void:
	time_since_last_press += delta
	
	if hold_dir == 0:
		return

	hold_delay -= delta
	if hold_delay <= 0.0 and time_since_last_press > HOLD_REPEAT: #and hold_dir != 0:
		# print("process proc")
		move_selection(hold_dir)
		hold_delay = HOLD_REPEAT


func move_selection(dir: int) -> void:
	if last_selected == -1:
		select_level_index(0)
		return

	var target = clamp(last_selected + dir, 0, level_paths.size() - 1)
	select_level_index(target)


func _unhandled_input(event: InputEvent) -> void:

		
	# Accept key activation
	if event.is_action_pressed("ui_accept") and last_selected != -1:
		start_level(last_selected)
		return

	# --- Holding DOWN ---
	if event.is_action_pressed("move_down"):
		# print("move down")
		if time_since_last_press > HOLD_REPEAT:
			move_selection(+1)
		hold_delay = INITIAL_REPEAT
		hold_dir = +1
		# hold_delay = 0.0  # first move will happen immediately in _process
		return
	if event.is_action_released("move_down"):
		if hold_dir == +1:
			hold_dir = 0
		return

	# --- Holding UP ---
	if event.is_action_pressed("move_up"):
		# print("move up")
		if time_since_last_press > HOLD_REPEAT:
			move_selection(-1)
		hold_delay = INITIAL_REPEAT
		hold_dir = -1
		# hold_delay = 0.0  # first move will happen immediately in _process
		return
	if event.is_action_released("move_up"):
		if hold_dir == -1:
			hold_dir = 0
		return




func _ready() -> void:
	add_levels_to_container()
	select_level_index(0)
	
	
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
