extends Area2D

signal reached_star

@onready var sprite_2d: Sprite2D = $Sprite2D

var rot_tween:Tween
var rot_ang:float = 15
var rot_dur:float = 1.0

var scale_tween:Tween
var scale_mod:float = 0.2
var scale_diff:Vector2 = Vector2.ONE * scale_mod
var scale_dur:float = rot_dur


func _ready() -> void:
	#rot_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#rot_tween.tween_property(self, "rotation_degrees", -rot_ang, rot_dur)
	#rot_tween.tween_property(self, "rotation_degrees", 0.0, rot_dur)
	# self.rotation_degrees = -rot_ang
	rot_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	rot_tween.tween_property(self, "rotation_degrees", -rot_ang, rot_dur)
	rot_tween.tween_property(self, "rotation_degrees", rot_ang, rot_dur)
	
	#sprite_2d.scale = Vector2.ONE + scale_diff
	#scale_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#scale_tween.tween_property(sprite_2d, "scale", Vector2.ONE, scale_dur/2.0)
	#scale_tween.tween_property(sprite_2d, "scale", Vector2.ONE + scale_diff, scale_dur/2.0)
	
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_physics_process(false)
		
		var umbrella = body.get_parent().get_node_or_null("umbrella")
		if umbrella:
			umbrella.set_physics_process(false)
		
		AudioManager.play_sound("yay_crowd", 0.0, 1.0, true)
		reached_star.emit()
