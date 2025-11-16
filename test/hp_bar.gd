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
	
func _process(_delta) -> void:
	if entity:
		self.value = entity.hp
