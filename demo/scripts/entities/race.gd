extends GDDataResource
class_name Race


@export var name: String


func init_values(values_json: Dictionary):
	name = values_json.name
