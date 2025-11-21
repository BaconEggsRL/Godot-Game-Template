class_name Umbrella
extends CharacterBody2D

signal hp_changed


@onready var angle_ray: RayCast2D = $angle_ray

@export var auto_regen:bool = false
# regen_after_zero:
# if auto_regen is enabled, will regen after delay even after hitting 0 hp
# if auto_regen is disabled, will still regen on shadow wind.
@export var regen_after_zero:bool = false  


const CRATE_PUSH_FORCE = 100
const MAX_CRATE_VEL = 300

const WHEEL_PUSH_FORCE = 100
const MAX_WHEEL_VEL = 300

const UMBRELLA_OCCLUDER_POLYGON = preload("uid://yq81xoefu4c5")
@onready var umbrella_occluder: LightOccluder2D = $umbrella_occluder

var is_immune:bool = false

@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var collision_shape: CollisionPolygon2D = $collision_shape

@onready var sprite: Sprite2D = $sprite
@onready var mat := sprite.material

var touching_spike := false
@export var pogo_damage:float = 5.0

# How fast the umbrella tries to follow the player
var follow_speed := 50.0
# Maximum distance umbrella can be from player
var max_follow_distance := 4.0

var time_since_damage := 0.0
@export var regen_rate: float = 10.0
@export var regen_delay: float = 1.0

const max_hp = 25.0
@export var hp:float = max_hp: set = set_hp

@export var downtime_duration: float = 1.0      # how long to stay disabled
@export var respawn_safe_delay: float = 1.0     # delay after last hit before respawn

var is_disabled: bool = false
var downtime_timer: float = 0.0



func respawn_umbrella() -> void:
	if is_disabled == false:
		return
		
	is_disabled = false
	# hp = max_hp
	# update_decay(1.0)

	# Restore collision
	collision_shape.disabled = false

	# Restore occluder
	if not umbrella_occluder:
		umbrella_occluder = LightOccluder2D.new()
		umbrella_occluder.occluder = UMBRELLA_OCCLUDER_POLYGON
		add_child(umbrella_occluder)
	
	# Show sprite
	sprite.visible = true
	
	# Disable player area detect shadow wind
	player.player_area_shape.disabled = true
	

func disable_umbrella() -> void:
	if is_disabled == true:
		return
		
	is_disabled = true
	downtime_timer = downtime_duration

	# Stop collisions
	collision_shape.disabled = true

	# Remove occluder
	if umbrella_occluder:
		umbrella_occluder.queue_free()
		umbrella_occluder = null

	# Hide sprite
	sprite.visible = false
	
	# Enable player area detect shadow wind
	player.player_area_shape.disabled = false


func set_hp(value: float) -> void:
	if is_immune:
		return
		
	var last_hp = hp
	hp = clamp(max(value, 0.0), 0.0, max_hp)
	
	if hp < last_hp:  # took damage
		time_since_damage = 0.0   # reset timer when damaged
		
	update_decay(hp/max_hp)
	hp_changed.emit(hp)
	
	# Trigger downtime if HP hits zero
	if hp <= 0.0 and not is_disabled:
		disable_umbrella()


func handle_regen(delta: float) -> void:
	if is_disabled:
		return
	
	time_since_damage += delta
	
	if auto_regen == false:
		return
	
	# Not enough time passed → no regen
	if time_since_damage < regen_delay:
		return

	# Regen until full
	if hp < max_hp:
		set_hp(hp + regen_rate * delta)
		
		
		
func update_decay(decay_ratio:float) -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", decay_ratio)
	

func _ready() -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", 1.0)

func _physics_process(delta):
	if not regen_after_zero:
		if hp <= 0.0:
			queue_free()
			return
		
	# Handle downtime
	if auto_regen and regen_after_zero:
		if is_disabled:
			downtime_timer -= delta

			# Only respawn if downtime finished AND time since last damage is enough
			if downtime_timer <= 0.0 and player.time_since_damage >= respawn_safe_delay:
				respawn_umbrella()
	
	
	handle_regen(delta)
	
	# Follow player
	var to_player = (player.global_position - self.global_position)
	var distance = to_player.length()
	var dir = to_player.normalized()
	# velocity = player.velocity + to_player.normalized()*100
	# var target_velocity = (player.global_position - global_position) * 4
	# velocity = velocity.lerp(target_velocity, 0.2)
	
	# Only move faster if we're too far
	var target_velocity = Vector2.ZERO
	if distance > max_follow_distance:
		# Move toward player with smooth damping
		target_velocity = dir * follow_speed * distance
	
	# Also add player velocity so it feels connected
	velocity = velocity.lerp(player.velocity + target_velocity, 0.2)
	
	

	# Desired rotation toward mouse
	var mouse_pos = get_global_mouse_position()
	var desired_rotation = (mouse_pos - global_position).angle() + PI/2

	
	var pogo_now := false
	var spike_hit_this_frame := false
	var spike_collision_normal := Vector2.ZERO
	

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if not collision:
			continue
			
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var tilemap := collider as TileMapLayer
			var tile_pos = tilemap.local_to_map(collision.get_position())
			var data := tilemap.get_cell_tile_data(tile_pos)

			if data and data.get_custom_data("type") == "spike":
				var normal := collision.get_normal()
				print("normal: %s" % normal)
				spike_collision_normal = normal
				#var angle := rad_to_deg(collision.get_angle(Vector2.RIGHT))
				#var vel := collision.get_collider_velocity()
				#var norm_angle := rad_to_deg(normal.angle())
				#collision.get_collider_velocity()
				# (0, -1) from above
				# (-1, 0) from the left
				# (-0.8, -0.6) from left corner
				# (0.8, -0.6) from right corner
				# (1, 0) from the right
		
				spike_hit_this_frame = true
				break
			
		#if collider.is_in_group("crate") or collider.is_in_group("wheel") and collider is RigidBody2D:
			#if abs(collider.get_linear_velocity().x) < MAX_CRATE_VEL:
				#var normal = collision.get_normal()
				#var PUSH_FORCE = CRATE_PUSH_FORCE if collider.is_in_group("crate") else WHEEL_PUSH_FORCE
				## Only push if the collision is mostly horizontal
				#if abs(normal.x) > 0.7:
					#var push = Vector2(-normal.x, 0) * PUSH_FORCE
					#collider.apply_central_impulse(push)
				## collider.apply_central_impulse(normal * -PUSH_FORCE)


	# No collision, safe to rotate
	rotation = desired_rotation

	move_and_slide()
	
	# Rising edge = just touched spike now
	pogo_now = spike_hit_this_frame and not touching_spike

	touching_spike = spike_hit_this_frame  # remember for next frame

	if pogo_now and not is_disabled:
		# print("pogo!")
		self.hp -= pogo_damage
		var pointing_vector := Vector2.UP.rotated(self.rotation)
		# var pointing_angle := rad_to_deg(pointing_vector.angle())
		player._do_pogo(spike_collision_normal, pointing_vector)
