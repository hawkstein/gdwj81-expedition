extends Control
@onready var selection_border: Panel = $SelectionBorder
@onready var info_label: Label = $InfoLabel

signal button_pressed(goblin_uid:String)
signal button_hovered(goblin_uid:String)

var goblin_uid:int

func _ready() -> void:
	deselect()
	
func set_info(p_text:String) -> void:
	info_label.text = p_text
	
func select() -> void:
	selection_border.visible = true

func deselect() -> void:
	selection_border.visible = false

func _on_clear_button_pressed() -> void:
	button_pressed.emit(goblin_uid)

func _on_clear_button_mouse_entered() -> void:
	button_hovered.emit(goblin_uid)
