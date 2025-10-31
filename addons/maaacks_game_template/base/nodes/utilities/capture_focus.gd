extends Control
## Node that captures UI focus when switching menus.
##
## This script assists with capturing UI focus when
## opening, closing, or switching between menus.
## When attached to a node, it will check if it was changed to visible
## and if it should grab focus. If both are true, it will capture focus
## on the first eligible node in its scene tree.

## Hierarchical depth to search in the scene tree for a focusable control node.
@export var search_depth : int = 1
## If true, always capture focus when made visible.
@export var enabled : bool = false
## If true, capture focus if nothing currently is in focus.
@export var null_focus_enabled : bool = true
## If true, capture focus if there is a joypad detected.
@export var joypad_enabled : bool = true
## If true, capture focus if the mouse is hidden.
@export var mouse_hidden_enabled : bool = true

## Locks focus
@export var lock : bool = false :
	set(value):
		var value_changed : bool = lock != value
		lock = value
		if value_changed and not lock:
			update_focus()

func _focus_first_search(control_node : Control, levels : int = 1) -> bool:
	if control_node == null or !control_node.is_visible_in_tree():
		return false
	if control_node.focus_mode == FOCUS_ALL:
		# control_node.grab_focus()
		if control_node is ItemList:
			control_node.select(0)
		return true
	if levels < 1:
		return false
	var children = control_node.get_children()
	for child in children:
		if _focus_first_search(child, levels - 1):
			return true
	return false

func focus_first() -> void:
	_focus_first_search(self, search_depth)

func update_focus() -> void:
	if lock : return
	if _is_visible_and_should_capture():
		focus_first()

func _should_capture_focus() -> bool:
	return enabled or \
	(get_viewport().gui_get_focus_owner() == null and null_focus_enabled) or \
	(Input.get_connected_joypads().size() > 0 and joypad_enabled) or \
	(Input.mouse_mode not in [Input.MOUSE_MODE_VISIBLE, Input.MOUSE_MODE_CONFINED] and mouse_hidden_enabled)

func _is_visible_and_should_capture() -> bool:
	return is_visible_in_tree() and _should_capture_focus()

func _on_visibility_changed() -> void:
	call_deferred("update_focus")

#############################################################

# Customize these values
var tween_dict = {}
@export var hover_scale := Vector2(1.2, 1.2)
var normal_scale := Vector2(1, 1)
@export var duration := 0.4


func _ready() -> void:
	if is_inside_tree():
		update_focus()
		connect("visibility_changed", _on_visibility_changed)
		for btn in self.get_children():
			# print(btn)
			if btn is Button:
				#if btn.is_in_group("no_tween"):
					#continue
				var tween = create_tween()
				tween.kill()
				tween_dict[btn.name] = tween
				btn.mouse_entered.connect(_on_btn_mouse_hover.bind(btn, true))
				btn.mouse_exited.connect(_on_btn_mouse_hover.bind(btn, false))
				btn.pressed.connect(_on_btn_pressed.bind(btn))
			

func _on_btn_mouse_hover(btn:Button, hover:bool) -> void:
	btn.pivot_offset.x = btn.size.x / 2.0
	btn.pivot_offset.y = btn.size.y / 2.0
	var tween:Tween
	if tween_dict.has(btn.name):
		tween = tween_dict[btn.name]
		tween.kill()
	var target_scale = hover_scale if hover else normal_scale
	var ease = Tween.EASE_OUT if hover else Tween.EASE_OUT
	tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(ease)
	tween.tween_property(btn, "scale", target_scale, duration)
	if hover:
		AudioManager.play_sound("btn_hover", 0.0, 1.0, true)
		# AudioManager.play_sound("short_click.wav", 0.0, 1.0, true)
		pass


func _on_btn_pressed(btn:Button) -> void:
	AudioManager.play_sound("btn_press", 0.0, 1.0, true)
