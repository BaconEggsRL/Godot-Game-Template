class_name Player
extends CharacterBody2D

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000

@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.10

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0


func _physics_process(delta):
	# Coyote timer
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

	# Jump buffer
	if Input.is_action_just_pressed("move_up"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)
		
	# Add gravity every frame
	velocity.y += gravity * delta

	# Input affects x axis only
	velocity.x = Input.get_axis("move_left", "move_right") * speed

	move_and_slide()
	
	# Jump buffer + coyote time = jump
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		_do_jump()
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0


func _do_jump() -> void:
	velocity.y = jump_speed
