extends Node2D

@export var rotation_speed := 2.0

@onready var head: StaticBody2D = $head
@onready var body: StaticBody2D = $body
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
	if not player_inside:
		return

	# Rotate right
	if Input.is_action_pressed("rotate_right"):
		head.rotation += rotation_speed * delta

	# Rotate left
	if Input.is_action_pressed("rotate_left"):
		head.rotation -= rotation_speed * delta
