class_name PhysicsButton
extends Area2D


@export var is_one_shot:bool = true
@onready var has_activated:bool = is_pressed

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var wind_toggle:Wind
@export var door_toggle:TrapDoor
@export var spotlight_toggle:Spotlight

var colliders := {}  # acts like a Set

var is_pressed:bool = false:
	set(value):
		is_pressed = value
		# do nothing if one shot repeat
		if has_activated and is_one_shot:
			return
		# do button action
		if wind_toggle:
			wind_toggle.enabled = not wind_toggle.enabled
		if door_toggle:
			door_toggle.enabled = is_pressed
		if spotlight_toggle:
			spotlight_toggle.is_on = not spotlight_toggle.is_on
			if spotlight_toggle.is_on:
				AudioManager.play_sound("light_switch", 0.0, 1.0, true)
			else:
				AudioManager.play_sound("light_switch", 0.0, 0.8, true)
		# confirm has activated
		if is_pressed == true:
			has_activated = true
		

func _on_body_entered(body: Node2D) -> void:
	if has_activated and is_one_shot:
		return
	colliders[body] = true  # add to set
	if not is_pressed:
		is_pressed = true
		anim.play("press")

func _on_body_exited(body: Node2D) -> void:
	if has_activated and is_one_shot:
		return
	colliders.erase(body)   # remove from set
	if colliders.is_empty():
		if is_pressed:
			is_pressed = false
			anim.play("press", -1, -1.0, true)
