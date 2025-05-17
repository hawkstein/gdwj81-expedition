extends Node

var location_names := ["Goblinestone","Grubham", "Stinkton","Shroomburg","Near Lichen","Far Lichen"]
var edges := [[1,2],[1,3],[2,4],[2,5],[3,4],[3,6],[4,5],[4,6]] # [location_index, location_index]
var mushroom_names := ["Big Ol' Conecaps","Witches Teats","Stinky Todgers","Dragon Saddles","Ogre's Puffball", \
"Fairy Redcaps","Lil' Gnomecaps","The Unicorn","Funeral Bell","Wizard's Inkcap","Elvish Ear", \
"King's Cup","Brittlestem","Bolete", "Shank","Polypore", "Gill", "Deathcap"]

var days_left := 30
var locations := []
var useless_shrooms := []

func _ready() -> void:
	initialise_game()
	
func initialise_game() -> void:
	#print("initialising locations")
	mushroom_names.shuffle()
	for location_name in location_names:
		var location = Location.new(location_name)
		locations.append(location)
	
	# setup mushrooms in their home locations
	var slice_pos := 0
	for location in locations:
		var local_mushrooms = mushroom_names.slice(slice_pos, slice_pos + 3)
		var size = local_mushrooms.size()
		for i in range(size):
			var secondary = local_mushrooms[(i + 1) % size]
			var tertiary = local_mushrooms[(i + 2) % size]
			var chances:Array[Array] = [[0.3, local_mushrooms[i]], [ 0.2, secondary ], [ 0.1, tertiary ]]
			location.add_forest(chances)
		slice_pos += 3
	
	# distribute around the rest of the locations
	slice_pos = 0
	var picker_array = create_pick_array()
	for location in locations:
		var local_mushrooms = mushroom_names.slice(slice_pos, slice_pos + 3)
		for shroom in local_mushrooms:
			if picker_array.size() <= 0:
				picker_array = create_pick_array()
			var target = picker_array.pop_back()
			locations[target].add_mushroom_to_next_forest(0.2, shroom)
		slice_pos += 3
		
	slice_pos = 0
	picker_array = create_pick_array()
	for location in locations:
		var local_mushrooms = mushroom_names.slice(slice_pos, slice_pos + 3)
		for shroom in local_mushrooms:
			if picker_array.size() <= 0:
				picker_array = create_pick_array()
			var target = picker_array.pop_back()
			locations[target].add_mushroom_to_next_forest(0.1, shroom)
		slice_pos += 3
	
	for location_index in range(locations.size()):
		locations[location_index].add_random_chance()
		locations[location_index].connections = get_connected_villages(location_index)
	
	# decide what mushrooms have no value this game
	while useless_shrooms.size() < 6:
		var potentially_useless = mushroom_names.slice(3)
		var pick = potentially_useless.pick_random()
		if not useless_shrooms.has(pick):
			useless_shrooms.append(pick)
	
#	open up the first two forests at Goblinestone and 1st map
	var goblinestone = locations[0]
	goblinestone.forests[0].discovered = true
	var second_forest = randi_range(1, 2)
	goblinestone.forests[second_forest].discovered = true
	var missing_forest = 3 - second_forest
	goblinestone.maps.append([0, missing_forest]) #[location_index, forest_index]
	
#	add maps to locations
	for location in locations:
		
#	setup prices for each location based on distance
#	add market mods
#	pick where the griffen is located, replace 0.1 probability
	

func create_pick_array() -> Array[int]:
	var picker:Array[int] = []
	for i in range(location_names.size()):
		picker.append(i)
	picker.shuffle()
	return picker

func get_connected_villages(start:int) -> Array:
	var connections = edges.filter(func(edge:Array): return edge.filter(func(node:int): return node == start).size() > 0)
	var villages = connections.map(func(edge:Array): return edge.filter(func(node:int): return node != start)[0])
	return villages
	
func distance_between_locations(start:int, target:int) -> int:
	#BFS for days travel between locations
	if start == target:
		return 0
	
	var queue = []
	queue.append([start, 0])  #[location_index, distance]
	var visited = {start: true}
	var queue_index = 0

	while queue_index < queue.size():
		var current = queue[queue_index]
		var node = current[0]
		var distance = current[1]
		queue_index += 1

		# Check neighbors
		for neighbor in locations[node].connections:
			if neighbor == target:
				return distance + 1
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append([neighbor, distance + 1])
	return -1
	
func print_locations():
	print("useless shrooms")
	print(useless_shrooms)
	print("\n")
	
	for location in locations:
		print(location.display_name)
		for forest in location.forests:
			print("  ", forest.forest_name)
			for chance in forest.mushrooms:
				print("    ", chance[0], " - ", chance[1])
