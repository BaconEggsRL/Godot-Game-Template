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

@onready var bounce_light_2: PointLight2D = $lights/bounce_light_2
@onready var bounce_ray_2: RayCast2D = $rays/bounce_ray_2

@onready var bounce_light_3: PointLight2D = $lights/bounce_light_3
@onready var bounce_ray_3: RayCast2D = $rays/bounce_ray_3




@export var offset := 0.0  # small step to avoid self-hit

@onready var parent:Node2D = self.get_parent()


func _ready() -> void:
	pass
	
	
func _process(_delta):
	if Engine.is_editor_hint():
		return
		
	if bounce_light:
		bounce_light.hide()
	if bounce_ray:
		bounce_ray.hide()
	
	if bounce_light_2:
		bounce_light_2.hide()
	if bounce_ray_2:
		bounce_ray_2.hide()
	
	cast_beam(_delta)



func handle_crumble(collider, _delta) -> void:
	# collider.queue_free.call_deferred()
	if collider is CrumbleWall:
		# collider.hp -= beam_dps * _delta
		collider.take_light_damage(beam_dps, _delta)
	
	









func get_first_hit_data(_ray:RayCast2D, delta:float) -> Dictionary:
	# --- FIRST HIT ---
	var hit_pos := _ray.get_collision_point()
	var hit_normal := _ray.get_collision_normal()
	var collider := _ray.get_collider()

	line.add_point(to_local(hit_pos))
	
	if collider:
		apply_damage_collider(collider, delta)
		
	return {
		"hit_pos":hit_pos,
		"hit_normal":hit_normal,
		"collider":collider,
		"dir":Vector2.UP.rotated(self.global_rotation),  # global pointing dir of rotating_reflector
		"origin":Vector2.ZERO,
	}


func apply_damage_collider(collider:Object, delta:float) -> void:
	if collider:
		if collider.is_in_group("crumble_wall"):
			# print("crumble 1")
			handle_crumble(collider, delta)
			
		if collider.is_in_group("player") and collider is Player:
			collider.hp -= beam_dps * delta
		
		if collider.is_in_group("umbrella") and collider is Umbrella:
			collider.hp -= beam_dps * delta


func get_reflect_data(hit_data:Dictionary, _bounce_ray:RayCast2D, _bounce_light:PointLight2D, delta:float) -> Dictionary:
	if hit_data.is_empty():
		return {}
	
	var hit_pos = hit_data.hit_pos
	var hit_normal = hit_data.hit_normal
	var collider = hit_data.collider
	
	if not collider:
		return {}
	
	if not collider.is_in_group("static_reflector"):
		return {}
	
	# --- FIRST REFLECTION ---
	# dir is the normal, unrotated local reflection direction for the rotating_reflector object.
	# if the reflector is not rotated, this is Vector2.UP
	# var global_dir = dir.rotated(self.global_rotation)
	var reflected_dir = hit_data.dir.bounce(hit_normal).normalized()
	
	########
	# var reflected_dir = dir.bounce(hit_normal).normalized()
	# rotate by global (parent)
	# reflected_dir = reflected_dir.rotated(-self.global_rotation)
	#######
	
	# offset is 0.0, might be able to just remove--supposed to avoid self-hit
	var reflect_origin = hit_pos #+ (reflected_dir * offset)
	
	# update bounce ray
	_bounce_ray.position = to_local(hit_pos)
	_bounce_ray.global_rotation = reflected_dir.angle() + PI/2
	_bounce_ray.force_raycast_update()
	
	# draw the bounce light
	_bounce_light.position = to_local(hit_pos)
	_bounce_light.global_rotation = reflected_dir.angle() + PI/2
	
	# show bounce light
	_bounce_light.show()
	_bounce_ray.show()
	
	###########################################
	# --- SECOND HIT ---
	return get_bounce_hit_data(_bounce_ray, reflect_origin, reflected_dir, delta)



func get_bounce_hit_data(_bounce_ray:RayCast2D, reflect_origin:Vector2, reflected_dir:Vector2, delta:float) -> Dictionary:
	var _bounce_hit_pos = reflect_origin + (reflected_dir * max_distance)
	var _bounce_hit_normal = _bounce_ray.get_collision_normal()
	var _bounce_hit_collider = _bounce_ray.get_collider()
	
	if not _bounce_ray.is_colliding():
		# Nothing hit → draw full beam
		line.add_point(to_local(_bounce_hit_pos))
	else:
		_bounce_hit_pos = _bounce_ray.get_collision_point()
		line.add_point(to_local(_bounce_hit_pos))

	if _bounce_hit_collider:
		apply_damage_collider(_bounce_hit_collider, delta)
	
	return {
		"hit_pos":_bounce_hit_pos, 
		"hit_normal":_bounce_hit_normal, 
		"collider":_bounce_hit_collider,
		"dir": reflected_dir,
		"origin": reflect_origin,
	}





func cast_beam(delta):
	# Clear old line
	line.clear_points()
	line.add_point(Vector2.ZERO)

	if not ray.is_colliding():
		# Nothing hit → draw full beam
		line.add_point(dir.normalized() * max_distance)
		return

	# --- FIRST HIT ---
	var _hit_data := get_first_hit_data(ray, delta)
	var _reflect_data := get_reflect_data(_hit_data, bounce_ray, bounce_light, delta)
	var _reflect_data_2 := get_reflect_data(_reflect_data, bounce_ray_2, bounce_light_2, delta)
	
	# var bounce_hit_data := get_bounce_hit_data(bounce_ray)
	




func _cast_beam(_delta):
	# Clear old line
	line.clear_points()
	line.add_point(Vector2.ZERO)

	if not ray.is_colliding():
		# Nothing hit → draw full beam
		line.add_point(dir.normalized() * max_distance)
		return

	# --- FIRST HIT ---
	var hit_pos = ray.get_collision_point()
	var hit_normal = ray.get_collision_normal()
	var collider = ray.get_collider()

	line.add_point(to_local(hit_pos))
	
	if collider:
		if collider.is_in_group("crumble_wall"):
			# print("crumble 1")
			handle_crumble(collider, _delta)
			
		if collider.is_in_group("player") and collider is Player:
			collider.hp -= beam_dps * _delta
		
		if collider.is_in_group("umbrella") and collider is Umbrella:
			collider.hp -= beam_dps * _delta

	#########################################
	# --- FIRST REFLECTION ---
	if collider and collider.is_in_group("static_reflector"):
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
		
		
		
		# --- SECOND HIT ---
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
				handle_crumble(_bounce_hit_collider, _delta)
				
			if _bounce_hit_collider.is_in_group("player") and _bounce_hit_collider is Player:
				_bounce_hit_collider.hp -= beam_dps * _delta

			if _bounce_hit_collider.is_in_group("umbrella") and _bounce_hit_collider is Umbrella:
				_bounce_hit_collider.hp -= beam_dps * _delta
			
			
		# --- SECOND REFLECTION ---
		if _bounce_hit_collider and _bounce_hit_collider.is_in_group("static_reflector"):
			
			var second_reflected_dir = reflected_dir.bounce(_bounce_hit_normal).normalized()
		
			# rotate by global (parent)
			# second_reflected_dir = second_reflected_dir.rotated(-self.global_rotation)
			
			var second_reflect_origin = _bounce_hit_pos + second_reflected_dir * offset
			
			# update bounce ray
			bounce_ray_2.position = to_local(_bounce_hit_pos)
			bounce_ray_2.global_rotation = second_reflected_dir.angle() + PI/2
			bounce_ray_2.force_raycast_update()
			
			# draw the bounce light
			bounce_light_2.position = to_local(_bounce_hit_pos)
			bounce_light_2.global_rotation = second_reflected_dir.angle() + PI/2
			
			
			# --- THIRD HIT ---
			var _bounce_hit_pos_2 = second_reflect_origin + second_reflected_dir * max_distance
			var _bounce_hit_normal_2 = bounce_ray_2.get_collision_normal()
			var _bounce_hit_collider_2 = bounce_ray_2.get_collider()
			
			if not bounce_ray_2.is_colliding():
				# Nothing hit → draw full beam
				line.add_point(to_local(_bounce_hit_pos_2))
			else:
				_bounce_hit_pos_2 = bounce_ray_2.get_collision_point()
				line.add_point(to_local(_bounce_hit_pos_2))

			if _bounce_hit_collider_2:
				if _bounce_hit_collider_2.is_in_group("crumble_wall"):
					# print("crumble 2")
					handle_crumble(_bounce_hit_collider_2, _delta)
					
				if _bounce_hit_collider_2.is_in_group("player") and _bounce_hit_collider_2 is Player:
					_bounce_hit_collider_2.hp -= beam_dps * _delta

				if _bounce_hit_collider_2.is_in_group("umbrella") and _bounce_hit_collider_2 is Umbrella:
					_bounce_hit_collider_2.hp -= beam_dps * _delta
			
			
			bounce_light_2.show()
			bounce_ray_2.show()
			
			
			
				
		# show
		bounce_light.show()
		bounce_ray.show()
