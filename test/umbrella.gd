class_name Umbrella
extends Area2D

signal hp_changed

@export var hp:float = 25.0:
	set(value):
		hp = value
		hp_changed.emit(value)
