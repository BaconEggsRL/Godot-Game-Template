extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var pause_menu_controller: PauseMenuController = $PauseMenuController


func _ready() -> void:
	animation_player.play("fade_in")


func _on_level_manager_toggle_pause_request() -> void:
	pause_menu_controller.toggle_pause()
