extends Control
@onready var message_label: Label = $Message/MessageLabel
@onready var lets_go_button: Button = $LetsGoButton

var step := 1
const second_message := "A mushroom so rare...\nthat if you find it you'll be crowned king of the goblins?!"
const third_message := "Your goblin stink and grubby demeanor have won me over.\nWhere do we start?"

func _on_lets_go_button_pressed() -> void:
	match step:
		1:
			message_label.text = second_message
			step += 1
		2:
			message_label.text = third_message
			lets_go_button.text = "Let's go!"
			step += 1
		3:
			SceneManager.change_scene("map", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
