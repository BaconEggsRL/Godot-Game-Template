extends Area2D

var colliders := {}  # acts like a Set
var is_pressed:bool = false
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	colliders[body] = true  # add to set
	if not is_pressed:
		is_pressed = true
		anim.play("press")

func _on_body_exited(body: Node2D) -> void:
	colliders.erase(body)   # remove from set
	if colliders.is_empty():
		if is_pressed:
			is_pressed = false
			anim.play("press", -1, -1.0, true)
