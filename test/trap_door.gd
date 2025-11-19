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
	set_collision(false)

func close_door() -> void:
	var reverse := true
	anim.play("open", -1, -1.0, reverse)
	# set_collision(true)
	anim.animation_finished.connect(_on_closed, CONNECT_ONE_SHOT)

func set_collision(collision:bool) -> void:
	left_collision.disabled = not collision
	right_collision.disabled = not collision

func _on_closed(_anim_name:String) -> void:
	set_collision(true)
