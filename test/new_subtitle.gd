extends Button

@export var speed:float = 100.0

@onready var left: TextureRect = $left
@onready var right: TextureRect = $right


func _process(delta) -> void:
	right.rotation_degrees += delta * speed
	left.rotation_degrees += delta * -speed
