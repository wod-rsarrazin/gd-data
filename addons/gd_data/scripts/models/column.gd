extends Object
class_name Column


var key: String = ""
var type: String = ""
var index: int = 0
var editable: bool = true
var expression: String = ""
var column_observers: Array = []
var tag_observers: Array = []


func to_json():
	return {
		key = key,
		type = type,
		index = index,
		editable = editable,
		expression = expression,
		column_observers = column_observers,
		tag_observers = tag_observers
	}


static func from_json(json: Dictionary) -> Column:
	var column := Column.new()
	column.key = json.key
	column.type = json.type
	column.index = json.index
	column.editable = json.editable
	column.expression = json.expression
	column.column_observers = json.column_observers
	column.tag_observers = json.tag_observers
	return column
