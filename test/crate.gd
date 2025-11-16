@tool
class_name Crate
extends RigidBody2D

@onready var light_occluder_2d := $LightOccluder2D
@onready var sprite_2d := $Sprite2D

var _is_glass := false

@export var is_glass: bool:
	set(value):
		_is_glass = value
		_update_glass()
	get:
		return _is_glass

func _update_glass() -> void:
	# Only run if nodes are ready (works in-editor and runtime)
	if not is_inside_tree():
		return
	if light_occluder_2d == null or sprite_2d == null:
		return
	
	light_occluder_2d.visible = not _is_glass
	sprite_2d.self_modulate.a = 0.5 if is_glass else 1.0
	
	if _is_glass:
		set_collision_layer_value(4, false)  # normal layer off
		set_collision_layer_value(7, true)   # glass layer on
	else:
		set_collision_layer_value(7, false)
		set_collision_layer_value(4, true)


func _ready():
	_update_glass()
