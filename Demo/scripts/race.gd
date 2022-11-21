extends Resource
class_name Race


@export var index: int
@export var key: String
@export var name: String


func from_gd_data(json: Dictionary):
	index = json.index
	key = json.key
	name = json.name
