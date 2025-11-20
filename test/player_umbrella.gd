extends Node2D


@export var is_immune:bool = false

@onready var player: Player = $player
@onready var umbrella: Umbrella = $umbrella

func _ready() -> void:
	if is_immune:
		player.is_immune = true
		umbrella.is_immune = true
