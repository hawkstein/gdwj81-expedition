extends Node
class_name Location

var display_name := ""
var forests: Array[Forest] = []
var connections := []
var maps := []
var starting_maps := []
var griffin_clue := true
var next_forest := 0
var has_griffen := false

var prices
# mushroom values and type of price

class Forest:
	var forest_name := ""
	var mushrooms:Array[Array]
	var has_griffen := false
	var discovered_mushrooms:Array[String] = []
	var discovered := false

func _init(p_display_name:String):
	display_name = p_display_name
	
func add_forest(mushroom_chances:Array[Array]) -> void:
	var forest = Forest.new()
	forest.forest_name = display_name + " " + str(forests.size()+1)
	forest.mushrooms = mushroom_chances
	forests.append(forest)
	
func add_mushroom_to_next_forest(chance:float, mushroom:String) -> void:
	var forest = forests[next_forest]
	forest.mushrooms.append([chance, mushroom])
	next_forest += 1
	if (next_forest >= forests.size()):
		next_forest = 0

func add_random_chance() -> void:
	var forest = forests.pick_random()
	var bonus_chance = forest.mushrooms.pick_random()
	bonus_chance[0] += 0.1
	
	var total_probability = 0.0;
	for m in forest.mushrooms:
		total_probability += m[0]
	assert(is_equal_approx(total_probability, 1.0), "Probability missing")
