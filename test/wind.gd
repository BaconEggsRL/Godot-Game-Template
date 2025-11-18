@tool
class_name Wind
extends Node2D

@export var recharge:bool = true
@export var recharge_dps:float = 10.0

@export var PUSH_FORCE:float = 100.0

@onready var rays: Node2D = $rays
@onready var ray_children: Array = rays.get_children()

@onready var wind_particle: GPUParticles2D = $wind_particle
const WIND_PARTICLE_TEX = preload("uid://d28aj12nurijg")
const WIND_PARTICLE_MAT = preload("uid://dvca1wuimr3ov")


var player:Player
var umbrella:Umbrella



@export var max_height:float = -500.0:  # from origin, ray target (local)
	set(value):
		max_height = value
		for ray:RayCast2D in ray_children:
			ray.target_position.y = value
			
var current_height:float = max_height
# origin is position of self.


func generate_wind_particles() -> void:
	var pos = wind_particle.position
	var rot = wind_particle.rotation
	wind_particle.free()
	
	var particles = GPUParticles2D.new()
	particles.texture = WIND_PARTICLE_TEX.duplicate(true)
	particles.visibility_rect = Rect2(-300, -300, 600, 600)
	particles.process_material = WIND_PARTICLE_MAT.duplicate(true)
	particles.position = pos
	particles.rotation = rot
	self.add_child(particles)
	
	wind_particle = particles



func check_ray_collisions(_delta) -> void:
	
	for ray:RayCast2D in ray_children:
		if ray.is_colliding():
			
			var collider = ray.get_collider()

			# if not umbrella, block/reduce height of air stream
			var ray_collision_height = max_height
			
			if collider.is_in_group("player_area"):
				if umbrella:
					if umbrella.is_disabled and umbrella.regen_after_zero == true:
						umbrella.respawn_umbrella()
						return
			
			if collider is not Umbrella:
				var ray_hit_global: Vector2 = ray.get_collision_point()
				var ray_hit_local = ray.to_local(ray_hit_global)
				ray_collision_height = ray_hit_local.y  # <-- local Y of the collision
				
			current_height = ray_collision_height

			if collider is Umbrella:
				# Only push if the player is BELOW the current height
				# var global_height = to_global(Vector2(0, current_height)).y
				var global_height = to_global(Vector2(0, current_height)).y

				if player.global_position.y > global_height:
					
					# player.wind_velocity = Vector2(0, -PUSH_FORCE)
					var wind_vel = Vector2(0, -PUSH_FORCE).rotated(self.rotation)
					print(wind_vel)
					if wind_vel.y < 0.1:
						wind_vel.x = wind_vel.x * 5
					player.wind_accel = wind_vel
					
					
					
					if recharge:
						umbrella.hp += recharge_dps * _delta
					else:
						player.wind_velocity = Vector2.ZERO
						player.wind_accel = Vector2.ZERO

				return  # Stop after first ray hit

	player.wind_velocity = Vector2.ZERO
	player.wind_accel = Vector2.ZERO


func _ready() -> void:
	if not Engine.is_editor_hint():
		player = get_tree().get_first_node_in_group("player")
		umbrella = get_tree().get_first_node_in_group("umbrella")
		generate_wind_particles()
	
func _process(_delta) -> void:
	if not Engine.is_editor_hint():
		check_ray_collisions(_delta)
