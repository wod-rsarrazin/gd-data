extends Object
class_name Helper


static func is_any_key_in_expression(expression: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\bvalues.[a-zA-Z0-9_]+\\b")
	return regex.search(expression) != null


static func is_key_in_expression(key: String, expression: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\bvalues.[a-zA-Z0-9_]+\\b")
	
	var results = regex.search_all(expression)
	for result in results:
		if result.strings[0].replace("values.", "") == key: 
			return true
	
	return false


static func find_keys_in_expression(expression: String) -> Array[String]:
	var regex = RegEx.new()
	regex.compile("\\bvalues.[a-zA-Z0-9_]+\\b")
	
	var observers = []
	var results = regex.search_all(expression)
	for result in results:
		observers.append(result.strings[0].replace("values.", ""))
	
	observers.erase("key")
	observers.erase("index")
	return observers


static func replace_key_in_expression(old_key: String, new_key: String, expression: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\bvalues." + old_key + "\\b")
	
	return regex.sub(expression, "values." + new_key, true)


static func replace_word_in_expression(old_word: String, new_word: String, expression: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\b" + old_word + "\\b")
	
	return regex.sub(expression, new_word, true)


static func get_values_from_line(sheet: Sheet, line: Line):
	var values = sheet.values[line.key].duplicate(true)
	values["key"] = line.key
	values["index"] = line.index
	return values


static func get_values_from_columns(sheet: Sheet):
	var values = {
		key = "",
		index = 0
	}
	for column in sheet.columns.values():
		values[column.key] = column.settings.value
	return values


static func get_region_rect(image: Texture2D, frame: int, hor: int, ver: int, sx: int, sy: int, ox: int, oy: int) -> Rect2:
	frame = clamp(frame, 0, hor * ver - 1)
	
	var img_width = image.get_width()
	var img_height = image.get_height()
	var width = (img_width - ox - sx * (hor - 1)) / hor
	var height = (img_height - oy - sy * (ver - 1)) / ver
	var x = ox + (frame % hor * (width + sx))
	var y = oy + (frame / hor * (height + sy))

	return Rect2(x, y, width, height)
