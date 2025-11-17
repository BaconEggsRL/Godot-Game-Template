class_name LifeBar
extends ProgressBar

@export var entity:Node

func _ready() -> void:
	if entity:
		setup(entity)

func setup(node:Node) -> void:
	self.entity = node
	self.min_value = 0.0
	self.max_value = entity.hp
	entity.hp_changed.connect(_on_hp_changed)
	
func _on_hp_changed(new_value) -> void:
	self.value = new_value
