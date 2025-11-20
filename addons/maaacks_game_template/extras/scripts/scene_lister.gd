@tool
extends Node
class_name SceneLister

@export var files : Array[String]

@export_dir var directory : String = "res://scenes/game_scene/levels":
	set(value):
		directory = value
		if Engine.is_editor_hint():
			_refresh_files()

func _refresh_files():
	var dir_access = DirAccess.open(directory)
	if not dir_access: return
	files.clear()
	for file in dir_access.get_files():
		if file.ends_with(".tscn"):
			files.append(directory + "/" + file)
