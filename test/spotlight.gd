extends Node2D

@onready var ray: RayCast2D = $RayCast2D
var active_reflectors := {}

@onready var light: PointLight2D = $PointLight2D

var light_tween:Tween

func _ready() -> void:
	light_tween = create_tween()
	light_tween.set_loops()
	light_tween.tween_property(self, "rotation_degrees", 30.0, 1.0)
	light_tween.tween_property(self, "rotation_degrees", -30.0, 1.0)


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
	var collider = ray.get_collider()

	if collider:
		var r = collider.get_parent()
		if not has_reflector(r):
			add_reflector(r)
	else:
		clear_reflectors()
