class_name Player
extends CharacterBody2D

signal dead

const CRATE_PUSH_FORCE = 100
const MAX_CRATE_VEL = 300

const WHEEL_PUSH_FORCE = 100
const MAX_WHEEL_VEL = 300

signal hp_changed

@export var auto_regen:bool = true

const max_hp = 25.0
@export var hp:float = max_hp: set = set_hp
@export var regen_rate: float = 5.0      # HP per second
@export var regen_delay: float = 1.0     # Seconds after last damage before regen starts

@export_range(0, 1200, 1.0) var speed:float = 1000 # 1200
@export_range(-1500, -200, 1.0) var jump_speed:float = -1500 # -1500
@export var gravity = 4000

@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.10

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

@onready var parent:Node = get_parent()
@onready var level:Node = parent.get_parent()

@onready var player_area: Area2D = $player_area
@onready var player_area_shape: CollisionShape2D = $player_area/CollisionShape2D


var wind_velocity := Vector2.ZERO
var wind_accel := Vector2.ZERO

var is_dying:bool = false
var time_since_damage := 0.0



func handle_regen(delta: float) -> void:
	time_since_damage += delta
	
	# Don't regen if dead
	if hp <= 0.0:
		return
	
	if auto_regen == false:
		return
	
	# Not enough time passed → no regen
	if time_since_damage < regen_delay:
		return

	# Regen until full
	if hp < max_hp:  # or max_hp if you define one
		set_hp(hp + regen_rate * delta)



func set_hp(value: float) -> void:
	var last_hp = hp
	hp = max(value, 0.0)
	
	if hp < last_hp:  # took damage
		time_since_damage = 0.0   # reset timer when damaged

	hp_changed.emit(hp)
	
	if not is_dying:
		if hp <= 0.0:
			dead.emit()
			is_dying = true
		
		
func _ready() -> void:
	player_area_shape.disabled = true
	pass


func _physics_process(delta):
	# Death check
	#if self.hp <= 0.0:
		## await get_tree().process_frame
		#level.restart_pressed.emit()
		#return
		
	# Umbrella
	#if umbrella:
		#pass
		# Rotate umbrella toward mouse
		# var mouse_pos = get_global_mouse_position()
		# var dir = (mouse_pos - umbrella.global_position).angle()
		# var center = Vector2(1280/2.0, 720/2.0)
		# var dir = (mouse_pos - center).angle()
		# umbrella.rotation = dir + PI/2
		
		# Check umbrella death
		#if umbrella.hp <= 0.0:
			#umbrella.queue_free.call_deferred()
			#return
		
	################################
	
	handle_regen(delta)
	
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

	# Apply modifier velocities
	# velocity += wind_velocity
	wind_velocity += wind_accel * delta
	velocity += wind_velocity

	# Check collision
	for i in get_slide_collision_count():
		
		var collision = get_slide_collision(i)
		
		if not collision:
			continue
			
		var collider = collision.get_collider()
		
		if not collider:
			continue
		

		if collider is TileMapLayer:
			var tilemap := collider as TileMapLayer
			var tile_pos = tilemap.local_to_map(collision.get_position())
			var data := tilemap.get_cell_tile_data(tile_pos)

			if data and data.get_custom_data("type") == "spike":
				dead.emit()
				return

			
		if (collider.is_in_group("crate") or collider.is_in_group("wheel")) and collider is RigidBody2D:
			if abs(collider.get_linear_velocity().x) < MAX_CRATE_VEL:
				var normal = collision.get_normal()
				var PUSH_FORCE = CRATE_PUSH_FORCE if collider.is_in_group("crate") else WHEEL_PUSH_FORCE
				# Only push if the collision is mostly horizontal
				# if abs(normal.x) > 0.7:
				var push = Vector2(-normal.x, -normal.y) * PUSH_FORCE
				collider.apply_central_impulse(push)
				# collider.apply_central_impulse(normal * -PUSH_FORCE)
				
				

	move_and_slide()
	
	# Jump buffer + coyote time = jump
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		_do_jump()
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0


func _do_jump(_jump_speed:float = jump_speed) -> void:
	# var pitch = 1.05
	# AudioManager.play_sound("jump_pop", 0.0, pitch, true)
	velocity.y = _jump_speed

func _do_pogo(_jump_speed:float = jump_speed) -> void:
	# var pitch = randf_range(0.9, 1.1)
	var pitch = 1.0
	AudioManager.play_sound("spike_pogo", 0.0, pitch, true)
	velocity.y = _jump_speed
