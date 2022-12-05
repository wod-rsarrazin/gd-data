extends GDDataResource
class_name Hero


@export var name: String
@export var race: String
@export var is_human: bool
@export var level: int
@export var strength: float
@export var texture: Texture
@export var color: Color


func init_values(values_json: Dictionary):
	name = values_json.name
	race = values_json.race.line_key
	is_human = values_json.is_human
	level = values_json.level
	strength = values_json.strength
	texture = null if values_json.texture.is_empty() else load(values_json.texture)
	color = Color(values_json.color)
