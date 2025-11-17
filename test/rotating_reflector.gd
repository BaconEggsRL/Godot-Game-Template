@tool
class_name RotatingReflector
extends Node2D

@export var rotate_torque := 50.0

@export var wheels: Node2D

@export var active:bool = false :
	set(value):
		active = value
		beam.active = active

@export var has_wheels:bool = false :
	set(value):
		has_wheels = value
		for c in self.get_children():
			if c is RigidBody2D:
				c.freeze = false if has_wheels else true
		if wheels:
			for c in wheels.get_children():
				if c is RigidBody2D:
					c.freeze = false if has_wheels else true

@export var rotation_speed := 2.0

@onready var head: RigidBody2D = $head
@onready var body: RigidBody2D = $body

@onready var area: Area2D = $head/InteractArea


@onready var beam: Beam = $head/beam




var player_inside := false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(_body):
	if _body.is_in_group("player"):
		player_inside = true


func _on_body_exited(_body):
	if _body.is_in_group("player"):
		player_inside = false


func _process(delta):
	# Player inside toggle active
	if not player_inside:
		active = false
		return
	else:
		active = true
	
	# Light hitting head toggle active

	
	# Do nothing else if in the editor
	if Engine.is_editor_hint():
		return
	
	# Do not allow rotation if not inside interact area
	if not player_inside:
		return
		
	# Rotate right
	if Input.is_action_pressed("rotate_right"):
		head.rotation += rotation_speed * delta

	# Rotate left
	if Input.is_action_pressed("rotate_left"):
		head.rotation -= rotation_speed * delta
