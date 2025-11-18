@tool
class_name Wind
extends Node2D

@export var recharge:bool = true
@export var recharge_dps:float = 10.0

@export var PUSH_FORCE:float = 100.0

@onready var rays: Node2D = $rays
@onready var ray_children: Array = rays.get_children()

@onready var player:Player = get_tree().get_first_node_in_group("player")
@onready var umbrella:Umbrella = get_tree().get_first_node_in_group("umbrella")



@export var max_height:float = -500.0:  # from origin, ray target (local)
	set(value):
		max_height = value
		for ray:RayCast2D in ray_children:
			ray.target_position.y = value
			
var current_height:float = max_height
# origin is position of self.


func check_ray_collisions(_delta) -> void:
	
	for ray:RayCast2D in ray_children:
		if ray.is_colliding():
			
			var collider = ray.get_collider()

			# if not umbrella, block/reduce height of air stream
			var ray_collision_height = max_height
			
			if collider is not Umbrella:
				var ray_hit_global: Vector2 = ray.get_collision_point()
				var ray_hit_local = ray.to_local(ray_hit_global)
				ray_collision_height = ray_hit_local.y  # <-- global Y of the collision
				
			current_height = ray_collision_height
			# print(current_height)
			

			# Only push if the player is BELOW the current height
			var global_height = ray.to_global(Vector2(0, current_height)).y

			if player.global_position.y > global_height:
				
				player.wind_velocity = Vector2(0, -PUSH_FORCE)
				if recharge:
					umbrella.hp += recharge_dps * _delta
				else:
					player.wind_velocity = Vector2.ZERO

			return  # Stop after first ray hit

	player.wind_velocity = Vector2.ZERO


func _process(_delta) -> void:
	if Engine.is_editor_hint():
		return
	check_ray_collisions(_delta)
	pass
