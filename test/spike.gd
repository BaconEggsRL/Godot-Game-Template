extends Area2D

signal hit_spike

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# body.hp = 0.0
		AudioManager.play_sound("spike_splatt", 0.0, 1.0, true)
		hit_spike.emit()
