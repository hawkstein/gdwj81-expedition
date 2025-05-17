extends Control

func _on_start_button_pressed() -> void:
	SceneManager.change_scene("intro", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
