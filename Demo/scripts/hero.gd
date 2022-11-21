extends Resource
class_name Hero


@export var index: int
@export var key: String
@export var name: String
@export var race: String
@export var is_human: bool
@export var level: int
@export var strength: float
@export var texture: Texture
@export var color: Color


func from_gd_data(json: Dictionary):
	index = json.index
	key = json.key
	name = json.name
	race = json.race
	is_human = json.is_human
	level = json.level
	strength = json.strength
	texture = null if json.texture.is_empty() else load(json.texture)
	color = Color(json.color)
