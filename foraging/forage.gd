extends Control
@onready var output: Label = $Output
@onready var hours_label: Label = $HoursLabel

# get mushroom info for this forest
# get the selected band of goblins
# roll the dice for the goblins
# queue their output into the interface
# roll again when output is reviewed
# if output is past the time limit, discard & sleep goblin
# if all goblins asleep or if baskets are full then finish

var forest:Location.Forest
var goblins:Array[Goblin] 
var time_taken := 0.0
var queue = []
#var count = {}

func _ready() -> void:
	forest = GameManager.get_selected_forest()
	goblins = GameManager.get_selected_band()
	queue_goblins()
	
func queue_goblins() -> void:
	for gobbo in goblins:
		match gobbo.type:
			Goblin.GoblinType.FORAGER:
				queue_forager(time_taken)

func queue_forager(start_time:float) -> void:
	# are there any unidentified shrooms
	var mushrooms = forest.mushrooms.duplicate(true)
	var unidentified = mushrooms.filter(func(chance:Array): return not GameManager.identified_mushrooms.has(chance[1]))
	var identified = mushrooms.filter(func(chance:Array): return GameManager.identified_mushrooms.has(chance[1]))
	
	var chance_redistribution := 0.0
	if unidentified.size() > 0 and identified.size() > 0:
		for i in range(unidentified.size()):
			var u_shroom = unidentified[i]
			chance_redistribution += u_shroom[0]/2
			u_shroom[0] = u_shroom[0]/2
		print(unidentified)
		print("chance redistribution: {0}".format([chance_redistribution]))
		var split = chance_redistribution / identified.size()
		for known in identified:
			known[0] += split
	var samples = unidentified.duplicate(true)
	samples.append_array(identified)
	samples.sort_custom(func(a:Array,b:Array): return a[0] > b[0])
	
	# create probability and find the mushroom
	var accumulated_probability := 0.0
	var probabilities:Array[float] = []
	for sample in samples:
		accumulated_probability += sample[0]
		probabilities.append(accumulated_probability)
	
	assert(is_equal_approx(accumulated_probability, 1.0),"Probs did not add up")
	var roll = randf_range(0, 1.0)
	var result = probabilities.bsearch(roll)
	var found_shroom = samples[result]
	var f_name = found_shroom[1]
	#count.set(f_name, count.get_or_add(f_name, 0) + 1)
	var finish_time = snappedf(time_taken + 1.8 + randf_range(0, 0.4), 0.25)
	queue.append({ "finish_time":finish_time, "mushroom":f_name, "goblin":Goblin.GoblinType.FORAGER })
	# add queue time based on level

func _on_start_timer_timeout() -> void:
	pop_queue()
	
func pop_queue() -> void:
	var next = queue.pop_front()
	time_taken += next.finish_time
	var hours_left = 9 - time_taken
	hours_label.text = "{0} hours left in the day".format([hours_left])
	output.text = "Found some {0}!".format([next.mushroom])
