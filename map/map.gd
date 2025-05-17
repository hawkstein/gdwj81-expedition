extends Node2D

func _on_temp_rival_button_pressed() -> void:
	SceneManager.change_scene("rival", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
