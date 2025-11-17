@tool
class_name LevelBorders
extends Node2D

@onready var ground_collider: CollisionShape2D = $ground/ground_collider
@onready var ceiling_collider: CollisionShape2D = $ceiling/ceiling_collider
@onready var left_collider: CollisionShape2D = $left/left_collider
@onready var right_collider: CollisionShape2D = $right/right_collider

@onready var ground: StaticBody2D = $ground
@onready var ceiling: StaticBody2D = $ceiling
@onready var left: StaticBody2D = $left
@onready var right: StaticBody2D = $right

# backing variables
var _ground_enabled: bool = true
var _ceiling_enabled: bool = true
var _left_enabled: bool = true
var _right_enabled: bool = true

@export var ground_enabled: bool:
	get: return _ground_enabled
	set(value):
		_ground_enabled = value
		if ground_collider:  # ensure it's ready
			ground_collider.disabled = not value
			ground.visible = value

@export var ceiling_enabled: bool:
	get: return _ceiling_enabled
	set(value):
		_ceiling_enabled = value
		if ceiling_collider:
			ceiling_collider.disabled = not value
			ceiling.visible = value

@export var left_enabled: bool:
	get: return _left_enabled
	set(value):
		_left_enabled = value
		if left_collider:
			left_collider.disabled = not value
			left.visible = value

@export var right_enabled: bool:
	get: return _right_enabled
	set(value):
		_right_enabled = value
		if right_collider:
			right_collider.disabled = not value
			right.visible = value

func _ready():
	# make sure all colliders match export values
	ground_enabled = _ground_enabled
	ceiling_enabled = _ceiling_enabled
	left_enabled = _left_enabled
	right_enabled = _right_enabled
