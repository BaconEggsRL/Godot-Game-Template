class_name TrapDoor
extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var left_collision: CollisionShape2D = $pivot_left/left/left_collision
@onready var right_collision: CollisionShape2D = $pivot_right/right/right_collision


@export var enabled:bool = false:  # closed if false
	set(value):
		enabled = value
		if enabled:
			open_door()
		else:
			close_door()
			
func _ready() -> void:
	if enabled:  # door open
		set_collision(false)
	else:  # door closed
		set_collision(true)

func open_door() -> void:
	anim.play("open")
	# anim.animation_finished.connect(set_collision.bind(false), CONNECT_ONE_SHOT)
	set_collision(false)

func close_door() -> void:
	anim.play("open", -1, 1.0, true)
	# anim.animation_finished.connect(set_collision.bind(true), CONNECT_ONE_SHOT)
	set_collision(true)

func set_collision(collision:bool) -> void:
	left_collision.disabled = not collision
	right_collision.disabled = not collision
