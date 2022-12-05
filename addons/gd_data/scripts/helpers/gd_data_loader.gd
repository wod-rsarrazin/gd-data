extends Node
class_name GDDataLoader


func _load(_path: String):
	var file = FileAccess.open(_path, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)


func load_data(_path: String, class_mapper: Dictionary):
	var json = _load(_path)
	
	var data: Dictionary
	for sheet_json in json.sheets.values():
		data[sheet_json.key] = {
			values = {},
			groups = {}
		}
	
	for sheet_json in json.sheets.values():
		data[sheet_json.key].groups = sheet_json.groups
		
		for line_json in sheet_json.lines.values():
			var values_json = sheet_json.values[line_json.key]
			var object_class = class_mapper.get(sheet_json.key)
			if object_class == null:
				printerr("Class not found in mapper for sheet '" + sheet_json.key + "'")
			else:
				var object = _build_object_typed(values_json, line_json, object_class)
				data[sheet_json.key].values[line_json.key] = object
	
	return data


func _build_object_typed(values_json: Dictionary, line_json: Dictionary, object_class):
	var object: GDDataResource = object_class.new()
	object.init_values(values_json)
	object.init_line(line_json)
	return object
