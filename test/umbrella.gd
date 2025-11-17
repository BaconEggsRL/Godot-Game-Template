class_name Umbrella
extends CharacterBody2D

signal hp_changed

@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var collision_shape: CollisionPolygon2D = $collision_shape


@export var hp:float = 25.0:
	set(value):
		hp = value
		hp_changed.emit(value)


func _physics_process(_delta):
	if hp <= 0.0:
		queue_free()
		return

	# Follow player
	var to_player = (player.global_position - self.global_position).normalized()
	velocity = player.velocity + to_player*200

	# Desired rotation toward mouse
	var mouse_pos = get_global_mouse_position()
	var desired_rotation = (mouse_pos - global_position).angle() + PI/2

	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#if not collision:
			#continue
		#var collider = collision.get_collider()
		#if not collider:
			#continue
		#
		#if collider is TileMapLayer:
			#var tilemap := collider as TileMapLayer
			#var tile_pos = tilemap.local_to_map(collision.get_position())
			#var data := tilemap.get_cell_tile_data(tile_pos)
#
			#if data and data.get_custom_data("type") == "spike":
				#AudioManager.play_sound("spike_pogo", 0.0, 1.0, true)
				#player.velocity.y -= 200

	# No collision, safe to rotate
	rotation = desired_rotation

	move_and_slide()
