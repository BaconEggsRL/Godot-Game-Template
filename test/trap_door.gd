class_name TrapDoor
extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var left_collision: CollisionShape2D = $pivot_left/left/left_collision
@onready var right_collision: CollisionShape2D = $pivot_right/right/right_collision

@export var anim_speed:float = 1.0


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
	var reverse := false
	anim.play("open", -1, anim_speed, reverse)
	set_collision(false)
	#if not anim.animation_finished.is_connected(_on_opened):
		#anim.animation_finished.connect(_on_opened, CONNECT_ONE_SHOT)

func close_door() -> void:
	var reverse := true
	anim.play("open", -1, -1.0 * anim_speed, reverse)
	# set_collision(true)
	if not anim.animation_finished.is_connected(_on_closed):
		anim.animation_finished.connect(_on_closed, CONNECT_ONE_SHOT)

func set_collision(collision:bool) -> void:
	left_collision.disabled = not collision
	right_collision.disabled = not collision

func _on_closed(_anim_name:String) -> void:
	set_collision(true)

func _on_opened(_anim_name:String) -> void:
	set_collision(false)
