extends Control
@onready var output: Label = $Output
@onready var hours_label: Label = $HoursLabel
@onready var keep_button: Button = $KeepButton
@onready var discard_button: Button = $DiscardButton
@onready var stash_info_label: Label = $StashInfoLabel
@onready var trade_button: Button = $TradeButton

var forest:Location.Forest
var goblins:Array[Goblin] 
var time_taken := 0.0
var queue = []
var next
var stash = {}

func _ready() -> void:
	forest = GameManager.get_selected_forest()
	goblins = GameManager.get_selected_band()
	queue_goblins()
	
func queue_goblins() -> void:
	for gobbo in goblins:
		match gobbo.type:
			Goblin.GoblinType.FORAGER:
				queue_forager()

func queue_forager() -> void:
	var finish_time = snappedf(time_taken + 1.8 + randf_range(0, 0.4), 0.25)
	# TODO: add queue time based on level
	if (finish_time > 9.0):
		return
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
	queue.append({ "finish_time":finish_time, "mushroom":f_name, "type":Goblin.GoblinType.FORAGER })
	queue.sort_custom(func(a,b): return a.finish_time < b.finish_time)

func _on_start_timer_timeout() -> void:
	keep_button.disabled = false
	discard_button.disabled = false
	pop_queue()
	
func pop_queue() -> void:
	next = queue.pop_front()
	if next.finish_time > time_taken:
		time_taken = next.finish_time
	var hours_left = 9 - time_taken
	hours_label.text = "{0} hours left in the day".format([hours_left])
	var known = GameManager.check_mushroom_discovery(next.mushroom)
	if known:
		output.text = "Found some {0}!".format([next.mushroom])
	else:
		output.text = "Found an unknown mushroom!\n\nWe think it's {0}".format([next.mushroom])
	match next.type:
			Goblin.GoblinType.FORAGER:
				queue_forager()

func check_finished_then_pop() -> void:
	if not queue.is_empty():
		pop_queue()
	else:
		output.text = "The day has ended!"
		hours_label.text = "0 hours left in the day"
		keep_button.visible = false
		discard_button.visible = false
		trade_button.visible = true

func _on_keep_button_pressed() -> void:
	stash.set(next.mushroom, stash.get_or_add(next.mushroom, 0) + 1)
	var stash_text = ""
	for shroom in stash:
		stash_text += "{0} : {1}\n".format([shroom, stash[shroom]])
	stash_info_label.text = stash_text
	next = null
	output.text = ""
	check_finished_then_pop()


func _on_discard_button_pressed() -> void:
	next = null
	output.text = ""
	check_finished_then_pop()


func _on_trade_button_pressed() -> void:
	SceneManager.change_scene("map", SceneManager.create_options(), SceneManager.create_options(),SceneManager.create_general_options())
