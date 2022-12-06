extends Object
class_name GDColumn


var key: String = ""
var type: String = ""
var index: int = 0
var editable: bool = true
var expression: String = ""
var settings: Dictionary = {}
var column_observers: Array = []
var tag_observers: Array = []


func to_json():
	return {
		key = key,
		type = type,
		index = index,
		editable = editable,
		expression = expression,
		settings = settings,
		column_observers = column_observers,
		tag_observers = tag_observers
	}


static func from_json(json: Dictionary) -> GDColumn:
	var column := GDColumn.new()
	column.key = json.key
	column.type = json.type
	column.index = json.index
	column.editable = json.editable
	column.expression = json.expression
	column.settings = json.settings
	column.column_observers = json.column_observers
	column.tag_observers = json.tag_observers
	return column
