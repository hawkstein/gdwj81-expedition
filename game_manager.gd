extends Node

var location_names := ["Goblinestone","Grubham", "Stinkton","Shroomburg","Near Lichen","Far Lichen"]
var edges := [[0,1],[0,2],[1,3],[1,4],[2,3],[2,5],[3,4],[3,5]] # [location_index, location_index]
var mushroom_names := ["Big Ol' Conecaps","Witches Teats","Stinky Todgers","Dragon Saddles","Giant's Puffball", \
"Fairy Redcaps","Lil' Gnomecaps","The Unicorn","Funeral Bell","Wizard's Inkcap","Elvish Ear", \
"King's Cup","Bone Brittlestem","Dwarven Bolete", "Thieve's Shank","Cursed Polypore", "Kraken Gill", "Dark Deathcap"]

var days_left := 30
var locations:Array[Location] = []
var useless_shrooms := []
var home_locations: Dictionary

func _ready() -> void:
	initialise_game()
	
func initialise_game() -> void:
	days_left = 30
	mushroom_names.shuffle()
	locations = []
	for location_name in location_names:
		var location = Location.new(location_name)
		locations.append(location)
	
	distribute_mushrooms()
	
	for location_index in range(locations.size()):
		locations[location_index].connections = get_connected_villages(location_index)
	
	# decide what mushrooms have no value this game
	useless_shrooms = []
	while useless_shrooms.size() < 6:
		var potentially_useless = mushroom_names.slice(3)
		var pick = potentially_useless.pick_random()
		if not useless_shrooms.has(pick):
			useless_shrooms.append(pick)
	
	setup_maps()
	setup_prices()
		
#	TODO: add market mods

	pick_griffen_location()

	#print("useless shrooms")
	#print(useless_shrooms)
	#print("\n")
	#print_locations()
	#print_prices()
	
func distribute_mushrooms() -> void:
	# setup mushrooms in their home locations
	home_locations = {}
	var slice_pos := 0
	var temp_i := 0
	for location in locations:
		var local_mushrooms = mushroom_names.slice(slice_pos, slice_pos + 3)
		for mushroom in local_mushrooms:
			home_locations.set(mushroom, temp_i)
		var size = local_mushrooms.size()
		for i in range(size):
			var secondary = local_mushrooms[(i + 1) % size]
			var tertiary = local_mushrooms[(i + 2) % size]
			var chances:Array[Array] = [[0.3, local_mushrooms[i]], [ 0.2, secondary ], [ 0.1, tertiary ]]
			location.add_forest(chances)
		slice_pos += 3
		temp_i += 1
	
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
		
	for location in locations:
		location.add_random_chance()

func setup_maps() -> void:
	# open up the first two forests at Goblinestone and 1st map
	var goblinestone = locations[0]
	goblinestone.forests[0].discovered = true
	var second_forest = randi_range(1, 2)
	goblinestone.forests[second_forest].discovered = true
	var missing_forest = 3 - second_forest
	goblinestone.maps.append_array([[0, missing_forest], [1, 0], [2, 0]])
	
#	add maps to all locations
	var distribution := [] 
	for i in range(1, locations.size()):
		var location = locations[i]
		var forests = [0,1,2]
		if i == 1 or i == 2:
			#removing two that were added to Goblinestone
			forests = [1,2]
		forests.shuffle()
		location.maps.append([i, forests.pop_back()])
		location.starting_maps.append([i,forests.pop_back()])
		if forests.size() > 0:
			location.starting_maps.append([i,forests.pop_back()])
		distribution.append_array(location.starting_maps)
	
	for i in range(1, locations.size()):
		for _i in range(2):
			if distribution.size() > 0:
				var random_pick = randi_range(0, distribution.size() - 1)
				var map = distribution.pop_at(random_pick)
				while map and map.has(i):
					random_pick = randi_range(0, distribution.size() - 1)
					map = distribution.pop_at(random_pick)
				locations[i].maps.append(map)


func setup_prices() -> void:
	for i in range(locations.size()):
		var location = locations[i]
		for mushroom in mushroom_names:
			if useless_shrooms.has(mushroom):
				location.prices.set(mushroom, 0)
			else:
				var distance = distance_between_locations(i, home_locations.get(mushroom))
				#print(i," ", home_locations.get(mushroom)," ", distance)
				var gold = get_price(distance)
				location.prices.set(mushroom, gold)

func pick_griffen_location() -> void:
	var location_index = randi_range(1, locations.size() - 1)
	var forest_index = randi_range(0, 2)
	var forest = locations[location_index].forests[forest_index]
	forest.has_griffen = true
	for location in locations:
		var griffen_map = location.maps.find([location_index, forest_index])
		if griffen_map >= 0:
			location.maps.remove_at(griffen_map)
		print(location.maps)
	

func get_price(distance:int) -> int:
		match distance:
			0:
				return 3
			1:
				return 5
			2:
				return 8
			_:
				return 666

func create_pick_array(start_index:int = 0) -> Array[int]:
	var picker:Array[int] = []
	for i in range(start_index, location_names.size()):
		picker.append(i)
	picker.shuffle()
	return picker

func get_connected_villages(start:int) -> Array:
	var connections = edges.filter(func(edge:Array): return edge.filter(func(node:int): return node == start).size() > 0)
	var villages = connections.map(func(edge:Array): return edge.filter(func(node:int): return node != start)[0])
	return villages
	
func distance_between_locations(start:int, target:int) -> int:
	# this is a very hacky distance calc that only works for this small map
	if start == target:
		return 0
	for neighbor in locations[start].connections:
		if neighbor == target:
			return 1
	return 2
	
func print_locations():
	for location in locations:
		print(location.display_name)
		for forest in location.forests:
			print("  ", forest.forest_name)
			for chance in forest.mushrooms:
				print("    ", chance[0], " - ", chance[1])
		for map in location.maps:
			print("  ", map)

func print_prices():	
	for location in locations:
		print(location.display_name)
		for price in location.prices:
			print(price, " ", location.prices[price])
