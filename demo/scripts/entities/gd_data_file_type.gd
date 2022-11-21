extends Resource
class_name GDDataFileTypes


@export var index: int
@export var key: String


func from_gd_data(json: Dictionary):
	index = json.index
	key = json.key
	# get other fields
