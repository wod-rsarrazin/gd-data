extends Node
class_name GDData


func _load(_path: String):
	var file = FileAccess.open(_path, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)


func load_data(_path: String, class_mapper: Dictionary):
	var json = _load(_path)
	
	var data: Dictionary
	
	var validated = true
	if validated:
		for sheet_json in json.sheets.values():
			data[sheet_json.key] = {
				values = {},
				groups = {}
			}
		
		for sheet_json in json.sheets.values():
			data[sheet_json.key].groups = sheet_json.groups
			
			for line_json in sheet_json.lines.values():
				var line_values = sheet_json.values[line_json.key]
				var object_class = class_mapper.get(sheet_json.key)
				if object_class == null:
					printerr("Class not found in mapper for sheet '" + sheet_json.key + "'")
				else:
					var object = _build_object_typed(sheet_json, line_json, line_values, object_class)
					data[sheet_json.key].values[line_json.key] = object
	
	return data


func _build_object_typed(sheet_json: Dictionary, line_json: Dictionary, line_values: Dictionary, object_class):
	var object_json = line_values.duplicate()
	object_json["index"] = line_json.index
	object_json["key"] = line_json.key
	
	var object = object_class.new()
	object.from_gd_data(object_json)
	return object
