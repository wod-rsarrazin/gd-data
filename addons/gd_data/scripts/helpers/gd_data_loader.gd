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
			var object_class = class_mapper.get(sheet_json.key)
			
			if object_class == null:
				printerr("Class not found in mapper for sheet '" + sheet_json.key + "'")
			else:
				var object = object_class.new()
				data[sheet_json.key].values[line_json.key] = object
	
	for sheet_json in json.sheets.values():
		for line_json in sheet_json.lines.values():
			var object = data[sheet_json.key].values[line_json.key]
			var values = sheet_json.values[line_json.key]
			
			object.set_key(line_json.key)
			object.set_index(line_json.index)
			
			for column_json in sheet_json.columns.values():
				var value = values[column_json.key]
				
				var method = "set_" + column_json.key
				if not object.has_method(method):
					printerr("Method " + method + " not found (sheet: " + sheet_json.key + ", column: " + column_json.key + ")")
				else:
					if column_json.type == "Reference":
						var object_ref = null
						if not value.is_empty():
							object_ref = data[column_json.settings.sheet_key].values[value]
						
						object.call(method, object_ref)
					else:
						object.call(method, value)
	
	return data
