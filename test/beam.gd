class_name Beam
extends Node2D

@export var dir := Vector2.UP
@export var max_distance := 2000.0
@export var max_bounces := 1

@onready var line := $Line2D
@onready var ray: RayCast2D = $RayCast2D

@export var offset := 0.1  # small step to avoid self-hit


func _ready():
	update_ray_direction()

# rotating ray
func update_ray_direction():
	ray.target_position = dir.normalized() * max_distance

func _process(_delta):
	cast_beam()


func cast_beam():
	# Clear old line
	line.clear_points()
	line.add_point(Vector2.ZERO)

	# Update ray direction every frame in case parent rotates
	update_ray_direction()

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
		reflected_dir = reflected_dir.rotated(dir.angle()/2.0)
		var next_start = hit_pos + reflected_dir * offset
		# draw reflected line segment (single bounce)
		line.add_point(to_local(next_start + reflected_dir * max_distance))
