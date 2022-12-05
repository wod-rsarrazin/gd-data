extends GDDataResource
class_name Weapon


@export var name: String
@export var texture_frame: int
@export var texture: AtlasTexture
@export var rank: int
@export var level: int
@export var strength: int
@export var element: String


func init_values(values_json: Dictionary):
	name = values_json.name
	texture_frame = values_json.texture_frame
	texture = Helper.get_atlas_from_region(values_json.texture_region)
	rank = values_json.rank
	level = values_json.level
	strength = values_json.strength
	element = values_json.element.line_key
