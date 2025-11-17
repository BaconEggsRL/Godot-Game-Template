class_name Wind
extends Node2D

@export var PUSH_FORCE:float = 100.0

@onready var rays: Node2D = $rays
@onready var ray_children: Array = rays.get_children()

@onready var player:Player = get_tree().get_first_node_in_group("player")


func check_collision() -> void:
	#if player.is_on_floor():
		#return
	for ray in ray_children:
		if ray.is_colliding():
			# var collider = ray.get_collider()
			# var normal: Vector2 = ray.get_collision_normal()
			# var _angle: float = normal.angle()  # in radians
			# var push = Vector2(0, -normal.y) * PUSH_FORCE
			var push = Vector2(0, -100)
			player.wind_velocity = push
			return
	player.wind_velocity = Vector2.ZERO


func _process(_delta) -> void:
	check_collision()
