extends Area2D

signal reached_star

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_physics_process(false)
		AudioManager.play_sound("yay_crowd", 0.0, 1.0, true)
		reached_star.emit()
