class_name Umbrella
extends CharacterBody2D

signal hp_changed


const CRATE_PUSH_FORCE = 100
const MAX_CRATE_VEL = 300

const WHEEL_PUSH_FORCE = 100
const MAX_WHEEL_VEL = 300


var touching_spike := false

@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var collision_shape: CollisionPolygon2D = $collision_shape

@export var pogo_damage:float = 5.0

@export var hp:float = 25.0:
	set(value):
		hp = value
		hp_changed.emit(value)



# How fast the umbrella tries to follow the player
var follow_speed := 50.0
# Maximum distance umbrella can be from player
var max_follow_distance := 4.0


func _physics_process(_delta):
	if hp <= 0.0:
		queue_free()
		return

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

	if pogo_now:
		# print("pogo!")
		self.hp -= pogo_damage
		player._do_pogo()
