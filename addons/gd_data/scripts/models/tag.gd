extends Object
class_name Tag


var key: String = ""
var index: int = 0
var filter_expression: String = ""


func to_json():
	return {
		key = key,
		index = index,
		filter_expression = filter_expression
	}


static func from_json(json: Dictionary) -> Tag:
	var tag := Tag.new()
	tag.key = json.key
	tag.index = json.index
	tag.filter_expression = json.filter_expression
	return tag
