extends Sprite2D

@export var max_offset: float = 8.0  # max distance from original position
@onready var original_offset: Vector2 = self.offset

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position

	# Limit movement distance
	if direction.length() > max_offset:
		direction = direction.normalized() * max_offset

	self.offset = original_offset + direction
