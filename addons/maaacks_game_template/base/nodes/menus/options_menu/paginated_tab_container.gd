extends TabContainer
## Applies UI page up and page down inputs to tab switching.

func _unhandled_input(event : InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_page_down"):
		current_tab = (current_tab+1) % get_tab_count()
	elif event.is_action_pressed("ui_page_up"):
		if current_tab == 0:
			current_tab = get_tab_count()-1
		else:
			current_tab = current_tab-1


func _on_tab_changed(_tab: int) -> void:
	AudioManager.play_sound("tab_press", -6.0, 1.0, true)
