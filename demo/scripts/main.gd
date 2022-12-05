extends Node2D


func _ready():
	var data = GDDataLoader.new().load_data("res://Demo/demo.json", {
		"heroes": Hero,
		"races": Race,
		"weapons": Weapon,
		"elements": Element,
		"gd_data_cycles": GDDataCycle,
		"gd_data_regions": GDDataRegion,
		"gd_data_types": GDDataType,
		"gd_data_file_types": GDDataFileType,
	})
	
	var heroes = data.heroes.values
	var races = data.races.values
	var weapons = data.weapons.values
	var elements = data.elements.values
	
	var heroes_ordered: Array = heroes.values()
	heroes_ordered.sort_custom(func(a, b): return a.index < b.index)
	
	var races_ordered: Array = races.values()
	races_ordered.sort_custom(func(a, b): return a.index < b.index)
	
	var weapons_ordered: Array = weapons.values()
	weapons_ordered.sort_custom(func(a, b): return a.index < b.index)
	
	var elements_ordered: Array = elements.values()
	elements_ordered.sort_custom(func(a, b): return a.index < b.index)
	
	print("\n---Heroes")
	for hero in heroes_ordered: 
		print(hero.key + ": " + str(hero.index))
	
	print("\n---Races")
	for race in races_ordered: 
		print(race.key + ": " + str(race.index))
	
	print("\n---Weapons")
	for weapon in weapons_ordered: 
		print(weapon.key + ": " + str(weapon.index))
	
	print("\n---Elements")
	for element in elements_ordered: 
		print(element.key + ": " + str(element.index))

	print("\n---Heroes groups")
	print(data.heroes.groups)

	print("\n---Weapons groups")
	print(data.weapons.groups)
