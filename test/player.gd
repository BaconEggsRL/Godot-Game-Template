class_name Player
extends CharacterBody2D

const CRATE_PUSH_FORCE = 100
const MAX_CRATE_VEL = 300

const WHEEL_PUSH_FORCE = 100
const MAX_WHEEL_VEL = 300


@export var hp:float = 50.0
@export var hp_bar:LifeBar
@export var umbrella_bar:LifeBar

@onready var umbrella: Umbrella = $umbrella


@export_range(0, 1200, 1.0) var speed:float = 1000 # 1200
@export_range(-1500, -200, 1.0) var jump_speed:float = -1500 # -1500
@export var gravity = 4000

@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.10

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

@onready var parent:Node = get_parent()
@onready var level:Node = parent.get_parent()


func _ready() -> void:
	umbrella_bar.setup(umbrella)
	
func _physics_process(delta):
	# Death check
	if self.hp <= 0.0:
		level.restart_pressed.emit()
		return
		
	# Umbrella
	if umbrella:
		# Rotate umbrella toward mouse
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - umbrella.global_position).angle()
		# var center = Vector2(1280/2.0, 720/2.0)
		# var dir = (mouse_pos - center).angle()
		
		# Check umbrella death
		umbrella.rotation = dir + PI/2
		if umbrella.hp <= 0.0:
			umbrella.queue_free.call_deferred()
			return
		
	################################
	
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

	# Check collision
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("crate") or collider.is_in_group("wheel") and collider is RigidBody2D:
			if abs(collider.get_linear_velocity().x) < MAX_CRATE_VEL:
				var normal = collision.get_normal()
				var PUSH_FORCE = CRATE_PUSH_FORCE if collider.is_in_group("crate") else WHEEL_PUSH_FORCE
				# Only push if the collision is mostly horizontal
				if abs(normal.x) > 0.7:
					var push = Vector2(-normal.x, 0) * PUSH_FORCE
					collider.apply_central_impulse(push)
				# collider.apply_central_impulse(normal * -PUSH_FORCE)
				
				

	move_and_slide()
	
	# Jump buffer + coyote time = jump
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		_do_jump()
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0


func _do_jump() -> void:
	velocity.y = jump_speed
