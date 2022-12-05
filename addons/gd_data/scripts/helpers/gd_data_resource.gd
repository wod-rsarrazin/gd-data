extends Resource
class_name GDDataResource


var _line: Line

var key: String: 
	get: return _line.key

var index: int:
	get: return _line.index


func init_values(values_json: Dictionary):
	push_error("Function 'init_values' must be overriden")


func init_line(line_json: Dictionary):
	_line = Line.from_json(line_json)
