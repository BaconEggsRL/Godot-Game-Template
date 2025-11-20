class_name StaticReflector
extends Node2D



@export var can_rotate:bool = false

@export var rotation_speed := 2.0

@onready var area: Area2D = $InteractArea

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
	# Do nothing else if in the editor
	if Engine.is_editor_hint():
		return
	
	# Do not allow rotation if not inside interact area
	if not player_inside:
		return
	if not can_rotate:
		return
	
	# Rotate right
	if Input.is_action_pressed("rotate_right"):
		rotation += rotation_speed * delta

	# Rotate left
	if Input.is_action_pressed("rotate_left"):
		rotation -= rotation_speed * delta
