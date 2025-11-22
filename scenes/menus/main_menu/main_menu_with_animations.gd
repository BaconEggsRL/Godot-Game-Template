extends MainMenu
## Main menu extension that adds options and animates the title and menu fading in.
## The scene adds a 'Continue' button if a game is in progress.
## The animation can be skipped by the player with any input.

## Optional scene to open when the player clicks a 'Level Select' button.
@export var level_select_packed_scene: PackedScene
## If true, have the player confirm before starting a new game if a game is in progress.
@export var confirm_new_game : bool = true

var animation_state_machine : AnimationNodeStateMachinePlayback

@onready var continue_game_button = %ContinueGameButton
@onready var level_select_button = %LevelSelectButton
@onready var new_game_confirmation = %NewGameConfirmation

@onready var sub_title_label: Label = $MenuContainer/SubTitleMargin/SubTitleContainer/SubTitleLabel


var main_subtitle := "DECAYING LIGHTS"
var subtitles:Array[String] = [
	# "DECAYING LIGHTS",
	####################
	
	"FEATURING LIGHT-DRIVEN ANXIETY",
	"CITY BLOB LIFE",
	"NOW WITH RAIN",
	"WHY ARE THERE SPIKES EVERYWHERE?",
	"CHILL BEATS TO RELAX/STUDY TO",
	"DARK ACADEMIA UWU BLOB",
	"STAR-CROSSED LOVERS",
	"SUBTITLE SIMULATOR"
	
	# "BLINDING LIGHTS",
	# "POGO POWER",
	# "CIRCLE PARKOUR",
	# "UMBRELLA PLATFORMER",
	# "LOFI VIBES",
	
	# "My Childhood Friend Still Loves This Idol I Like, \nAnd Now She Is A Serial Killer!",
	#"dark academia uwu blob",
	#"My corpo blob get fried by lights",
	#"Corpo blob gets blinded by nightlights",
	#"corpo blob fears batman",
	#"star-crossed lovers",
]


func set_subtitle_text() -> void:
	var game_won := GameState.get_game_won()
	var subtitles_unique := GameState.get_subtitles_unique()
	
	if not game_won:
		sub_title_label.text = main_subtitle
		return
	
	if subtitles_unique.is_empty():
		subtitles_unique = subtitles.duplicate()
	
	subtitles_unique.shuffle()
	var sub = subtitles_unique.pop_front()
	
	sub_title_label.text = sub
	
	GameState.set_subtitles_unique(subtitles_unique)



func load_game_scene() -> void:
	GameState.start_game()
	super.load_game_scene()

func new_game() -> void:
	if confirm_new_game and GameState.get_levels_reached() > 0:
		new_game_confirmation.show()
	else:
		GameState.reset()
		load_game_scene()

func intro_done() -> void:
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro() -> bool:
	return animation_state_machine.get_current_node() == "Intro"

func _event_skips_intro(event : InputEvent) -> bool:
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu : PackedScene) -> Node:
	animation_state_machine.travel("OpenSubMenu")
	return super._open_sub_menu(menu)

func _close_sub_menu() -> void:
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

func _input(event : InputEvent) -> void:
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)

func _show_level_select_if_set() -> void: 
	if level_select_packed_scene == null: return
	if GameState.get_levels_reached() <= 1 : return
	level_select_button.show()

func _show_continue_if_set() -> void:
	if GameState.get_current_level_path().is_empty(): return
	continue_game_button.show()

func _ready() -> void:
	super._ready()
	_show_level_select_if_set()
	_show_continue_if_set()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	set_subtitle_text()

func _on_continue_game_button_pressed() -> void:
	GameState.continue_game()
	load_game_scene()

func _on_level_select_button_pressed() -> void:
	var level_select_scene := _open_sub_menu(level_select_packed_scene)
	if level_select_scene.has_signal("level_selected"):
		level_select_scene.connect("level_selected", load_game_scene)
	if level_select_scene.has_signal("close"):
		level_select_scene.connect("close", _close_sub_menu)

func _on_new_game_confirmation_confirmed() -> void:
	GameState.reset()
	load_game_scene()


func _on_new_subtitle_pressed() -> void:
	set_subtitle_text()
