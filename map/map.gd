extends Node2D

@onready var info_container: VBoxContainer = $InfoContainer
@onready var focus_label: Label = $InfoContainer/FocusLabel
@onready var location_info: Label = $InfoContainer/LocationInfo
@onready var action_button: Button = $InfoContainer/ActionButton
@onready var tutorial: Control = $Tutorial

var focused_location_index := -1
var focused_forest_index := -1

func _ready() -> void:
	info_container.visible = false
	match GameManager.current_state:
		GameManager.State.FORAGING:
			action_button.text = "Forage"
		GameManager.State.TRADING:
			action_button.text = "Trade"
			
	if GameManager.tutorials.get(GameManager.Tutorial.MAP):
		tutorial.visible = true
		GameManager.tutorials.set(GameManager.Tutorial.MAP, false)
	# adjust the forests and the villages based on game data 
	for location_index in range(GameManager.locations.size()):
		var location = GameManager.locations[location_index]
		var location_node = get_node(location.display_name)
		var village_node = location_node.get_node("Village")
		village_node.connect("pressed", func(): handle_village_pressed(location.display_name))
		if location_node:
			for i in range(0, location.forests.size()):
				var forest_node = get_node(location.display_name+"/Forest "+str(i+1))
				forest_node.connect("pressed", func(): handle_forest_pressed(location_index, i))
				if forest_node:
					forest_node.visible = location.forests[i].discovered

func handle_forest_pressed(location_index:int, forest_index:int) -> void:
	info_container.visible = true
	match GameManager.current_state:
		GameManager.State.FORAGING:
			action_button.visible = true
		GameManager.State.TRADING:
			action_button.visible = false
	var location = GameManager.locations[location_index]
	focused_location_index = location_index
	focus_label.text = location.display_name + " Forest "+str(forest_index+1)
	var focused_forest = location.forests[forest_index]
	focused_forest_index = forest_index
	location_info.text = "Discovered mushrooms: " + str(focused_forest.discovered_mushrooms.size())

func handle_village_pressed(village_name:String) -> void:
	focus_label.text = village_name
	var location = GameManager.locationsDict[village_name]
	var price_text = ""
	for price in location.prices:
		var value = location.prices[price]
		if value > 0:
			price_text += "{0} - {1}\n".format([price, value])
	info_container.visible = true
	info_container.visible = true
	match GameManager.current_state:
		GameManager.State.FORAGING:
			action_button.visible = false
		GameManager.State.TRADING:
			action_button.visible = true
	if not location.hasKnownForests():
		action_button.visible = false
	location_info.text = price_text

func _on_action_button_pressed() -> void:
	match GameManager.current_state:
		GameManager.State.FORAGING:
			GameManager.select_forest(focused_location_index, focused_forest_index)
			SceneManager.change_scene("band", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
		GameManager.State.TRADING:
			print("goto trading scene")


func _on_close_button_pressed() -> void:
	tutorial.visible = false
