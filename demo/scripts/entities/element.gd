extends GDDataResource
class_name Element


@export var name: String
@export var color: Color


func init_values(values_json: Dictionary):
	name = values_json.name
	color = Color(values_json.color)
