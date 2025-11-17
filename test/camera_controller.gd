extends Camera2D

@export var player: Node2D

@export var max_mouse_offset_x: float = 360.0
@export var max_mouse_offset_y: float = 360.0

@export var smooth_factor: float = 8.0

func _process(delta):
	if not player:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport_rect().size
	var screen_center = viewport_size * 0.5

	# Normalize -1..1
	var offset_norm = (mouse_pos - screen_center) / screen_center
	offset_norm = offset_norm.clamp(Vector2(-1, -1), Vector2(1, 1))

	# Apply X/Y offset caps
	var mouse_offset = Vector2(
		offset_norm.x * max_mouse_offset_x,
		offset_norm.y * max_mouse_offset_y
	)

	# Desired camera target
	var target = player.global_position + mouse_offset

	# 💥 Clamp to Camera2D limits
	target.x = clamp(target.x, limit_left + screen_center.x, limit_right - screen_center.x)
	target.y = clamp(target.y, limit_top + screen_center.y, limit_bottom - screen_center.y)

	# Smooth movement
	global_position = global_position.lerp(target, delta * smooth_factor)
