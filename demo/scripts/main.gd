extends Node2D


func _ready():
	var data = GDData.new().load_data("res://Demo/demo.json", {
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
	
	print("\n---Heroes")
	var heroes_ordered: Array = heroes.values()
	heroes_ordered.sort_custom(func(a, b): return a.index < b.index)
	
	for hero in heroes_ordered:
		var hero_race: Race = races[hero.race]
		print(hero.key + ": " + hero_race.key)
	
	print("\n---Races")
	for race_key in races:
		var race: Race = races[race_key]
		print(race.key)

	print("\n---Heroes groups")
	print(data.heroes.groups)

	print("\n---Races groups")
	print(data.races.groups)
