extends ProgressBar

@export var player:Player

func _ready() -> void:
	self.min_value = 0.0
	self.max_value = player.hp
	
func _process(_delta) -> void:
	self.value = player.hp
