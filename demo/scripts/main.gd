extends Node2D


@onready var loader = %Loader


func _ready():
	var hero_0: Hero = loader.heroes_get_value("hero_0")
	print(hero_0.key)
	
	var heroes: Array[Hero] = loader.heroes_get_values()
	print(heroes)
	
	var hero_keys: Array[String] = loader.heroes_get_keys()
	print(hero_keys)
	
	var is_human_is_true: Array[String] = loader.heroes_get_group("is_human_is_true")
	print(is_human_is_true)
