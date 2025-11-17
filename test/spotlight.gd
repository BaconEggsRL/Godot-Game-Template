extends Node2D

@export var beam_dps := 10.0

@export var should_rotate:bool = false
@export_range(5.0, 30.0, 1.0) var rotate_amount:float = 5.0
@export_range(0.1, 2.0, 0.1) var rotate_time:float = 1.0

var active_reflectors := {}
@onready var light: PointLight2D = $PointLight2D
var light_tween:Tween

@onready var rays: Array = $rays.get_children()




func _ready() -> void:
	if should_rotate:
		add_rotation()


func add_rotation() -> void:
	light_tween = create_tween()
	light_tween.set_loops()
	light_tween.tween_property(self, "rotation_degrees", self.rotation_degrees + rotate_amount, rotate_time)
	light_tween.tween_property(self, "rotation_degrees", self.rotation_degrees - rotate_amount, rotate_time)


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
	for ray:RayCast2D in rays:
		
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
