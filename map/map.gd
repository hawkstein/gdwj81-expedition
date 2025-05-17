extends Node2D

@onready var info_container: VBoxContainer = $InfoContainer
@onready var focus_label: Label = $InfoContainer/FocusLabel
@onready var location_info: Label = $InfoContainer/LocationInfo

var focused_location:Location = null
var focused_forest:Location.Forest = null

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
	focused_location = location
	focus_label.text = location.display_name + " Forest "+str(forest_index+1)
	focused_forest = location.forests[forest_index]
	location_info.text = "Discovered mushrooms: " + str(focused_forest.discovered_mushrooms.size())
