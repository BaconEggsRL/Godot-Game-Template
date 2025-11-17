@tool
class_name Spotlight
extends Node2D


@onready var rays: Node2D = $rays
@onready var ray_children: Array = rays.get_children()

@onready var light: PointLight2D = $light


@export var preview_flicker:bool = false:
	set(value):
		preview_flicker = value
		if value:
			start_preview_flicker()
		else:
			stop_preview_flicker()
			
@export var should_flicker:bool = false
@export var flicker_time:float = 1.0
@onready var flicker_timer: Timer = $FlickerTimer



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





func enable_light() -> void:
	light.enabled = true
	for ray:RayCast2D in ray_children:
		ray.enabled = true

func disable_light() -> void:
	for ray:RayCast2D in ray_children:
		ray.enabled = false
	light.enabled = false

func toggle_light() -> void:
	if light.enabled == true:
		disable_light()
	else:
		enable_light()



func _ready() -> void:
	update_light()
	start_preview_rotation()
	start_preview_flicker()


func update_light() -> void:
	if light:
		light.offset.y = offset
		rays.position.y = -offset - 64.0


func start_preview_flicker() -> void:
	if Engine.is_editor_hint():
		if not preview_flicker:
			return
		else:
			flicker_timer.wait_time = self.flicker_time
	if should_flicker:
		add_flicker()
	
func stop_preview_flicker() -> void:
	flicker_timer.stop()
	light.enabled = true
	
	
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


func add_flicker() -> void:
	flicker_timer.start()


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
	var hit_reflectors := {}  # Keep track of reflectors hit this frame

	for ray: RayCast2D in ray_children:
		if not ray.enabled:
			continue
		
		var collider = ray.get_collider()
		if collider and collider.is_in_group("reflector_head"):
			var r = collider.get_parent()
			hit_reflectors[r] = true  # mark as hit

			if not has_reflector(r):
				add_reflector(r)
		
		# Damage stuff
		if collider:
			if collider.is_in_group("player") and collider is Player:
				collider.hp -= beam_dps * _delta
			if collider.is_in_group("umbrella") and collider is Umbrella:
				collider.hp -= beam_dps * _delta
	
	# Remove reflectors that are no longer hit
	for r in active_reflectors.keys():
		if not hit_reflectors.has(r):
			remove_reflector(r)


func _on_flicker_timer_timeout() -> void:
	toggle_light()
	if should_flicker:
		flicker_timer.start()
