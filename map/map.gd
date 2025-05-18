extends Node2D

@onready var info_container: VBoxContainer = $InfoContainer
@onready var focus_label: Label = $InfoContainer/FocusLabel
@onready var location_info: Label = $InfoContainer/LocationInfo

var focused_location_index := -1
var focused_forest_index := -1

func _ready() -> void:
	info_container.visible = false
	# adjust the forests and the villages based on game data 
	for location_index in range(GameManager.locations.size()):
		var location = GameManager.locations[location_index]
		var location_node = get_node(location.display_name)
		if location_node:
			for i in range(0, location.forests.size()):
				var forest_node = get_node(location.display_name+"/Forest "+str(i+1))
				forest_node.connect("pressed", func(): handle_forest_pressed(location_index, i))
				if forest_node:
					forest_node.visible = location.forests[i].discovered

func handle_forest_pressed(location_index:int, forest_index:int) -> void:
	info_container.visible = true
	var location = GameManager.locations[location_index]
	focused_location_index = location_index
	focus_label.text = location.display_name + " Forest "+str(forest_index+1)
	var focused_forest = location.forests[forest_index]
	focused_forest_index = forest_index
	location_info.text = "Discovered mushrooms: " + str(focused_forest.discovered_mushrooms.size())


func _on_action_button_pressed() -> void:
	GameManager.select_forest(focused_location_index, focused_forest_index)
	SceneManager.change_scene("band", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
