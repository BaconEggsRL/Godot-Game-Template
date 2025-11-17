@tool
class_name Spotlight
extends Node2D


@onready var rays: Node2D = $rays
@onready var ray_children: Array = rays.get_children()

@onready var light: PointLight2D = $light


@export_range(0.0, 512.0, 1.0) var offset:float = 128.0:
	set(value):
		offset = value
		update_light()

@export var beam_dps := 10.0

@export var preview_rotate:bool = false:
	set(value):
		preview_rotate = value
		if value:
			start_preview_rotation()
		else:
			stop_preview_rotation()
		


@export var should_rotate:bool = false
@export var reverse_order:bool = false
@export_range(5.0, 30.0, 1.0) var rotate_amount:float = 5.0
@export_range(0.1, 2.0, 0.1) var rotate_time:float = 1.0

var active_reflectors := {}
var light_tween:Tween

var starting_rotation:float





func _ready() -> void:
	update_light()
	start_preview_rotation()


func update_light() -> void:
	if light:
		light.offset.y = offset
		rays.position.y = -offset - 64.0


func start_preview_rotation() -> void:
	if Engine.is_editor_hint():
		if not preview_rotate:
			return
		else:
			starting_rotation = self.rotation_degrees
	if should_rotate:
		add_rotation()


func stop_preview_rotation() -> void:
	if light_tween:
		light_tween.kill()
	self.rotation_degrees = starting_rotation



func add_rotation() -> void:
	light_tween = create_tween()
	light_tween.set_loops()
	if not reverse_order:
		light_tween.tween_property(self, "rotation_degrees", self.rotation_degrees + rotate_amount, rotate_time)
		light_tween.tween_property(self, "rotation_degrees", self.rotation_degrees - rotate_amount, rotate_time)
	else:
		light_tween.tween_property(self, "rotation_degrees", self.rotation_degrees - rotate_amount, rotate_time)
		light_tween.tween_property(self, "rotation_degrees", self.rotation_degrees + rotate_amount, rotate_time)
	


func add_reflector(r: Node) -> void:
	active_reflectors[r] = true  # Key is the reflector, value is dummy
	r.active = true

func has_reflector(r: Node) -> bool:
	return active_reflectors.has(r)

func remove_reflector(r: Node) -> void:
	active_reflectors.erase(r)
	r.active = false

func clear_reflectors() -> void:
	for r in active_reflectors:
		remove_reflector(r)
	

func _physics_process(_delta):
	for ray:RayCast2D in ray_children:
		
		var collider = ray.get_collider()

		if collider:

			if collider.is_in_group("reflector_head"):
				var r = collider.get_parent()
				if not has_reflector(r):
					add_reflector(r)
			
			if collider.is_in_group("player") and collider is Player:
				collider.hp -= beam_dps * _delta

			if collider.is_in_group("umbrella") and collider is Umbrella:
				collider.hp -= beam_dps * _delta
			
		else:
			clear_reflectors()
