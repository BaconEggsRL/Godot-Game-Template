extends TabContainer
## Applies UI page up and page down inputs to tab switching.


func _ready() -> void:
	# call_deferred("_restore_last_tab")
	# await get_tree().process_frame
	tab_changed.connect(_on_tab_changed)

func _restore_last_tab() -> void:
	if get_tab_count() > 0:
		var last_tab := clampi(AppSettings.last_options_tab, 0, get_tab_count() - 1)
		current_tab = last_tab
		# _on_tab_changed(current_tab)

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
	AppSettings.last_options_tab = self.current_tab
