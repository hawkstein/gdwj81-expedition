extends Control


func _on_win_button_pressed() -> void:
	SceneManager.change_scene("success", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())


func _on_lose_button_pressed() -> void:
	SceneManager.change_scene("game_over", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
