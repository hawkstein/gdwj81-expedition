extends Control

func _on_start_button_pressed() -> void:
	SceneManager.change_scene("map", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
