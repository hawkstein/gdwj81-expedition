extends Control
@onready var forage_button: Button = $ForageButton
@onready var buttons_h_flow_container: HFlowContainer = $ButtonsHFlowContainer
@onready var band_size_label: Label = $BandSizeLabel
@onready var validation_label: Label = $ValidationLabel
@onready var info_label: Label = $InfoLabel

const GOBLIN_BUTTON = preload("res://goblin_band/goblin_button.tscn")

func _ready() -> void:
	GameManager.band_selection_changed.connect(_on_selection_changed)
	forage_button.disabled = true
	set_band_size_label()
	validation_label.text = "Please select {0} goblins before foraging".format([GameManager.max_band])
	for goblin in GameManager.band:
		var button = GOBLIN_BUTTON.instantiate()
		buttons_h_flow_container.add_child(button)
		button.connect("button_pressed", _on_goblin_button_pressed)
		button.connect("button_hovered", _on_goblin_button_hovered)
		button.connect("button_blurred", _on_goblin_button_blurred)
		button.goblin_uid = goblin.goblin_uid
		if GameManager.selected_band.has(goblin.goblin_uid):
			button.select()
		var info_text = ""
		match goblin.type:
			Goblin.GoblinType.FORAGER:
				info_text = "Forager Lvl {0}".format([goblin.level])
			Goblin.GoblinType.SPECIALIST:
				info_text = "Specialist Lvl {0}".format([goblin.level])
			Goblin.GoblinType.SCOUT:
				info_text = "Scout Lvl {0}".format([goblin.level])
			Goblin.GoblinType.GUZZLER:
				info_text = "Guzzler Lvl {0}".format([goblin.level])
		button.set_info(info_text)

func _on_selection_changed() -> void:
	set_band_size_label()
	for button in buttons_h_flow_container.get_children():
		if GameManager.selected_band.has(button.goblin_uid):
			button.select()
		else:
			button.deselect()
	
	if GameManager.selected_band.size() == GameManager.max_band:
		forage_button.disabled = false
	else:
		forage_button.disabled = true
		
func set_band_size_label() -> void:
	band_size_label.text = "{0}/{1} goblins selected".format([GameManager.selected_band.size(), GameManager.max_band])

func _on_goblin_button_pressed(uid) -> void:
	GameManager.toggle_goblin_selection(uid)

func _on_goblin_button_hovered(uid) -> void:
	info_label.text = GameManager.get_goblin_info(uid)

func _on_goblin_button_blurred(_uid) -> void:
	info_label.text = ""

func _on_forage_button_pressed() -> void:
	SceneManager.change_scene("forage", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
