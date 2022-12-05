extends Object
class_name Line


var key: String = ""
var index: int = 0


func to_json():
	return {
		key = key,
		index = index
	}


static func from_json(json: Dictionary) -> Line:
	var line := Line.new()
	line.key = json.key
	line.index = json.index
	return line
