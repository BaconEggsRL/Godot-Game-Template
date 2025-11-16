extends Area2D

signal reached_star

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		reached_star.emit()
