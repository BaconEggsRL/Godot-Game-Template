@tool
class_name Beam
extends Node2D

@export var active:bool = false :
	set(value):
		active = value
		if active:
			self.set_process_mode(Node.PROCESS_MODE_INHERIT)
			self.show()
		else:
			self.set_process_mode(Node.PROCESS_MODE_DISABLED)
			self.hide()

@export var beam_dps := 10.0

@export var dir := Vector2.UP
@export var max_distance := 2000.0
@export var max_bounces := 1

@onready var line: Line2D = $Line2D


@onready var lights: Node2D = $lights
@onready var rays: Node2D = $rays

@onready var light: PointLight2D = $lights/light
@onready var ray: RayCast2D = $rays/ray

@onready var bounce_light: PointLight2D = $lights/bounce_light
@onready var bounce_ray: RayCast2D = $rays/bounce_ray



@export var offset := 0.0  # small step to avoid self-hit

@onready var parent:Node2D = self.get_parent()


func _ready() -> void:
	pass
	
	
func _process(_delta):
	bounce_light.hide()
	bounce_ray.hide()
	cast_beam(_delta)


func cast_beam(_delta):
	# Clear old line
	line.clear_points()
	line.add_point(Vector2.ZERO)

	if not ray.is_colliding():
		# Nothing hit → draw full beam
		line.add_point(dir.normalized() * max_distance)
		return

	# We hit something
	var hit_pos = ray.get_collision_point()
	var hit_normal = ray.get_collision_normal()
	var collider = ray.get_collider()

	line.add_point(to_local(hit_pos))
	
	if collider:
		if collider.is_in_group("crumble_wall"):
			# print("crumble 1")
			collider.queue_free.call_deferred()
			
		if collider.is_in_group("player") and collider is Player:
			collider.hp -= beam_dps * _delta
		
		if collider.is_in_group("umbrella") and collider is Umbrella:
			collider.hp -= beam_dps * _delta


	# reflect if collider is a mirror/reflector
	if collider and collider.is_in_group("reflector"):
		var reflected_dir = dir.bounce(hit_normal).normalized()
		
		# rotate by global (parent)
		reflected_dir = reflected_dir.rotated(-self.global_rotation)
		
		var reflect_origin = hit_pos + reflected_dir * offset
		
		# update bounce ray
		bounce_ray.position = to_local(hit_pos)
		bounce_ray.global_rotation = reflected_dir.angle() + PI/2
		bounce_ray.force_raycast_update()
		
		# draw the bounce light
		bounce_light.position = to_local(hit_pos)
		bounce_light.global_rotation = reflected_dir.angle() + PI/2
		
		# draw the line
		var _bounce_hit_pos = reflect_origin + reflected_dir * max_distance
		var _bounce_hit_normal = bounce_ray.get_collision_normal()
		var _bounce_hit_collider = bounce_ray.get_collider()
		
		if not bounce_ray.is_colliding():
			# Nothing hit → draw full beam
			line.add_point(to_local(_bounce_hit_pos))
		else:
			_bounce_hit_pos = bounce_ray.get_collision_point()
			line.add_point(to_local(_bounce_hit_pos))


		if _bounce_hit_collider:
			if _bounce_hit_collider.is_in_group("crumble_wall"):
				# print("crumble 2")
				_bounce_hit_collider.queue_free.call_deferred()
				
			if _bounce_hit_collider.is_in_group("player") and _bounce_hit_collider is Player:
				_bounce_hit_collider.hp -= beam_dps * _delta

			if _bounce_hit_collider.is_in_group("umbrella") and _bounce_hit_collider is Umbrella:
				_bounce_hit_collider.hp -= beam_dps * _delta
				
				
		# show
		bounce_light.show()
		bounce_ray.show()
