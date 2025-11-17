class_name LifeBar
extends ProgressBar

@export var entity:Node
var tween:Tween

func _ready() -> void:
	if entity:
		setup(entity)

func setup(node:Node) -> void:
	self.entity = node
	self.min_value = 0.0
	self.max_value = entity.hp
	entity.hp_changed.connect(_on_hp_changed)
	
func _on_hp_changed(new_value) -> void:
	# Kill existing tween
	if tween:
		tween.kill()
		
	# How big is the HP change?
	var delta = abs(new_value - value)
	var _range = max_value - min_value

	# Normalize change into 0.0 → 1.0
	var t := 0.0
	if _range > 0:
		t = delta / _range

	# Scale tween duration: small change = fast, big change = slow
	var max_time = 1.0
	var duration = min(max_time, t * max_time)  # max 0.5 sec
	
	tween = create_tween().set_ease(Tween.EASE_OUT)# .set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "value", new_value, duration)  # duration = 0.2 sec
	# self.value = new_value
