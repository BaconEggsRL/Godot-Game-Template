class_name Beam
extends Node2D

@export var dir := Vector2.UP
@export var max_distance := 2000.0
@export var max_bounces := 1

@onready var line: Line2D = $Line2D


@onready var lights: Node2D = $lights
@onready var rays: Node2D = $rays

@onready var light: PointLight2D = $lights/light
@onready var ray: RayCast2D = $rays/ray

@onready var bounce_light: PointLight2D = $lights/bounce_light



@export var offset := 0.0  # small step to avoid self-hit

@onready var parent:Node2D = self.get_parent()



#func _ready():
	#update_ray_direction()

# rotating ray
#func update_ray_direction():
	#ray.target_position = dir.normalized() * max_distance

func _process(_delta):
	bounce_light.hide()
	cast_beam()


func cast_beam():
	# Clear old line
	line.clear_points()
	line.add_point(Vector2.ZERO)

	# Update ray direction every frame in case parent rotates
	# update_ray_direction()

	if not ray.is_colliding():
		# Nothing hit → draw full beam
		line.add_point(dir.normalized() * max_distance)
		return

	# We hit something
	var hit_pos = ray.get_collision_point()
	var hit_normal = ray.get_collision_normal()
	var collider = ray.get_collider()

	line.add_point(to_local(hit_pos))

	# reflect if collider is a mirror/reflector
	if collider and collider.is_in_group("reflector"):
		var reflected_dir = dir.bounce(hit_normal).normalized()
		
		# rotate by global (parent)
		reflected_dir = reflected_dir.rotated(-self.global_rotation)
		
		var reflect_origin = hit_pos + reflected_dir * offset

		# draw reflected line segment (single bounce)
		var local_reflect_point = to_local(reflect_origin + reflected_dir * max_distance)
		line.add_point(local_reflect_point)
		# draw the light
		bounce_light.position = to_local(hit_pos)
		bounce_light.rotation = (local_reflect_point).angle() - PI/2 + PI

		bounce_light.show()
