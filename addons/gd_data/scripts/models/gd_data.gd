@tool
extends Node
class_name GDData


var path: String
var sheets: Dictionary = {}
var loaded: bool = false
var evaluator: Evaluator = Evaluator.new()


signal any_changed()
signal values_changed()


func init_project(_path: String) -> bool:
	path = _path
	sheets.clear()
	loaded = true
	
	save_project()
	return true


func load_project(_json: Dictionary, _path: String) -> bool:
	path = _path
	sheets = from_json(_json)
	loaded = true
	print("Project loaded")
	return true


func save_project() -> void:
	var project_str = JSON.stringify(to_json(), "\t", false)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(project_str)
	print("Project saved")


func from_json(json: Dictionary) -> Dictionary:
	var sheets = {}
	for sheet_json in json.sheets.values():
		var sheet = GDSheet.from_json(sheet_json)
		sheets[sheet.key] = sheet
	
	return sheets


func to_json() -> Dictionary:
	var sheets_json = {}
	for sheet in sheets.values():
		sheets_json[sheet.key] = sheet.to_json()
	
	return { 
		sheets = sheets_json 
	}


# SHEETS
func can_create_sheet(key: String) -> String:
	# validate key
	var existing_keys = sheets.keys()
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	return ""


func create_sheet(key: String) -> UpdateResult:
	var error_message = can_create_sheet(key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	# build sheet
	var sheet := GDSheet.new()
	sheet.key = key
	sheet.index = sheets.size()
	sheets[key] = sheet
	
	any_changed.emit()
	return UpdateResult.ok()


func can_duplicate_sheet(key: String) -> String:
	# validate key
	var existing_keys = sheets.keys()
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	return ""


func duplicate_sheet(other_sheet: GDSheet, key: String) -> UpdateResult:
	var error_message = can_duplicate_sheet(key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var sheet := GDSheet.new()
	sheet.key = key
	sheet.index = sheets.size()
	sheet.lines = other_sheet.lines.duplicate(true)
	sheet.columns = other_sheet.columns.duplicate(true)
	sheet.tags = other_sheet.tags.duplicate(true)
	sheet.values = other_sheet.values.duplicate(true)
	sheet.groups = other_sheet.groups.duplicate(true)
	sheets[key] = sheet
	
	return UpdateResult.ok()


func can_remove_sheets(sheets_to_remove: Array) -> String:
	# check if removed sheet is not referenced in another sheet
	var keys = sheets_to_remove.map(func(x): return x.key)
	for sheet in sheets.values():
		if sheet not in sheets_to_remove:
			for column in sheet.columns.values():
				if column.type == "Reference" and column.settings.sheet_key in keys:
					return "Sheet '" + column.settings.sheet_key + "' is referenced in [sheet: '" + sheet.key + "', column: '" + column.key + "']"
	return ""


func remove_sheets(sheets_to_remove: Array) -> UpdateResult:
	var error_message = can_remove_sheets(sheets_to_remove)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	# remove from sheets
	for sheet in sheets_to_remove:
		sheets.erase(sheet.key)
	
	# update indexes
	var sheet_ordered = get_sheets_ordered()
	for index in range(sheet_ordered.size()):
		sheet_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_move_sheets(sheets_from: Array, sheet_to: GDSheet, shift: int) -> String:
	return ""


func move_sheets(sheets_from: Array, sheet_to: GDSheet, shift: int) -> UpdateResult:
	var error_message = can_move_sheets(sheets_from, sheet_to, shift)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	if sheet_to in sheets_from: 
		return UpdateResult.none()
	
	var sheets_ordered = get_sheets_ordered()
	for sheet_from in sheets_from:
		sheets_ordered.erase(sheet_from)
	
	var index_target = sheets_ordered.find(sheet_to)
	if index_target == sheets_ordered.size() - 1 and shift == 1:
		sheets_ordered.append_array(sheets_from)
	else:
		sheets_from.reverse()
		if shift == -1:
			for sheet_from in sheets_from:
				sheets_ordered.insert(index_target, sheet_from)
		else:
			for sheet_from in sheets_from:
				sheets_ordered.insert(index_target + 1, sheet_from)
	
	for index in range(sheets_ordered.size()):
		sheets_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_update_sheet(sheet: GDSheet, key: String) -> String:
	# validate key
	var existing_keys = sheets.keys()
	existing_keys.erase(sheet.key)
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	return ""


func update_sheet(sheet: GDSheet, new_key: String) -> UpdateResult:
	var error_message = can_update_sheet(sheet, new_key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var old_key = sheet.key
	
	if old_key == new_key:
		return UpdateResult.none()
	
	# update sheet key from column references
	for other_sheet in sheets.values():
		for other_column in other_sheet.columns.values():
			if other_column.type == "Reference" and other_column.settings.sheet_key == old_key:
				other_column.settings.sheet_key = new_key
	
	# update sheet from sheets
	sheets.erase(old_key)
	sheets[new_key] = sheet
	sheet.key = new_key
	
	any_changed.emit()
	return UpdateResult.ok()


# COLUMNS
func can_create_column(sheet: GDSheet, key: String, type: String, editable: bool, expression: String, settings: Dictionary) -> String:
	# validate key
	var existing_keys = sheet.columns.keys()
	var key_error_message = Properties.validate_key(key, existing_keys)
	if not key_error_message.is_empty():
		return key_error_message
	
	# validate expression
	var values = Helper.get_values_from_columns(sheet)
	var value = evaluator.evaluate(expression, values)
	if value == null:
		return "Error while evaluating expression: " + expression
	
	# validate value
	var value_error_message = Properties.validate_value(value, type, settings, self)
	if not value_error_message.is_empty():
		return value_error_message
	
	return ""


func create_column(sheet: GDSheet, key: String, type: String, editable: bool, expression: String, settings: Dictionary) -> UpdateResult:
	var error_message = can_create_column(sheet, key, type, editable, expression, settings)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	# force editable to false if any key was found
	var has_key_in_expression = Helper.is_any_key_in_expression(expression)
	if has_key_in_expression:
		editable = false
	
	# build column
	var column := GDColumn.new()
	column.key = key
	column.index = sheet.columns.size()
	column.type = type
	column.editable = editable
	column.expression = expression
	column.settings = settings
	sheet.columns[key] = column
	
	# add to observed column
	if has_key_in_expression:
		var observed_keys = Helper.find_keys_in_expression(expression)
		for observed_key in observed_keys:
			var observed: GDColumn = sheet.columns[observed_key]
			observed.column_observers.append(key)
	
	# init values and expressions for each lines
	for line in sheet.lines.values():
		_update_expression(sheet, line, column, expression)
	
	any_changed.emit()
	return UpdateResult.ok()


func can_duplicate_column(sheet: GDSheet, key: String) -> String:
	# validate key
	var existing_keys = sheet.columns.keys()
	var key_error_message = Properties.validate_key(key, existing_keys)
	if not key_error_message.is_empty():
		return key_error_message
	return ""


func duplicate_column(sheet: GDSheet, other_column: GDColumn, key: String) -> UpdateResult:
	var error_message = can_duplicate_column(sheet, key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var column := GDColumn.new()
	column.key = key
	column.index = sheet.columns.size()
	column.type = other_column.type
	column.editable = other_column.editable
	column.expression = other_column.expression
	column.settings = other_column.settings
	sheet.columns[key] = column
	
	# duplicate observers
	for col in sheet.columns.values():
		if other_column.key in col.column_observers:
			col.column_observers.append(key)
	
	# duplicate values for each line
	for line_values in sheet.values.values():
		var duplicated_value = line_values[other_column.key]
		if duplicated_value is Array or duplicated_value is Dictionary:
			line_values[key] = line_values[other_column.key].duplicate(true)
		else:
			line_values[key] = line_values[other_column.key]
	
	return UpdateResult.ok()


func can_remove_columns(sheet: GDSheet, columns: Array) -> String:
	var keys = columns.map(func(x): return x.key)
	for column in columns:
		# check if column is observed by another column
		for column_observer in column.column_observers:
			if column_observer not in keys:
				return "Column '" + column.key + "' is referenced in [sheet: '" + sheet.key + "', column: '" + column_observer + "']"
		# check if column is observed by a tag
		for tag_observer in column.tag_observers:
			return "Column '" + column.key + "' is referenced in [sheet: '" + sheet.key + "', tag: '" + tag_observer + "']"
	return ""


func remove_columns(sheet: GDSheet, columns: Array) -> UpdateResult:
	var error_message = can_remove_columns(sheet, columns)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	for column in columns:
		# remove from line values
		for line_values in sheet.values.values():
			line_values.erase(column.key)
		# remove from column observers
		for other_column in sheet.columns.values():
			other_column.column_observers.erase(column.key)
		# remove from columns
		sheet.columns.erase(column.key)
	
	# update indexes
	var columns_ordered = get_columns_ordered(sheet)
	for index in range(columns_ordered.size()):
		columns_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_move_columns(sheet: GDSheet, columns_from: Array, column_to: GDColumn, shift: int) -> String:
	return ""


func move_columns(sheet: GDSheet, columns_from: Array, column_to: GDColumn, shift: int) -> UpdateResult:
	var error_message = can_move_columns(sheet, columns_from, column_to, shift)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	if column_to in columns_from: 
		return UpdateResult.none()
	
	var columns_ordered = get_columns_ordered(sheet)
	for column_from in columns_from:
		columns_ordered.erase(column_from)
	
	var index_target = columns_ordered.find(column_to)
	if index_target == columns_ordered.size() - 1 and shift == 1:
		columns_ordered.append_array(columns_from)
	else:
		columns_from.reverse()
		if shift == -1:
			for column_from in columns_from:
				columns_ordered.insert(index_target, column_from)
		else:
			for column_from in columns_from:
				columns_ordered.insert(index_target + 1, column_from)
	
	for index in range(columns_ordered.size()):
		columns_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_update_column(sheet: GDSheet, column: GDColumn, key: String, type: String, editable: bool, expression: String, settings: Dictionary) -> String:
	# validate key
	var existing_keys = sheet.columns.keys()
	existing_keys.erase(column.key)
	var key_error_message = Properties.validate_key(key, existing_keys)
	if not key_error_message.is_empty():
		return key_error_message
	
	# validate expression
	var values = Helper.get_values_from_columns(sheet)
	values.erase(column.key)
	var value = evaluator.evaluate(expression, values)
	if value == null:
		return "Error while evaluating expression: " + expression
	
	# validate value
	var value_error_message = Properties.validate_value(value, type, settings, self)
	if not value_error_message.is_empty():
		return value_error_message
	
	# cannot change type if any column observe this column
	if not column.column_observers.is_empty() and column.type != type:
		return "Column '" + column.key + "' is referenced in [sheet: '" + sheet.key + "', columns: '" + str(column.column_observers) + "']"
	
	# check if there is no cyclic dependencies
	var observed_keys = Helper.find_keys_in_expression(expression)
	if has_cyclic_observers(sheet, column.key, observed_keys):
		return "Cyclic column observers found"
	
	return ""


func update_column(sheet: GDSheet, column: GDColumn, key: String, type: String, editable: bool, expression: String, settings: Dictionary) -> UpdateResult:
	var error_message = can_update_column(sheet, column, key, type, editable, expression, settings)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var old_key = column.key
	var old_type = column.type
	var old_editable = column.editable
	var old_expression = column.expression
	var old_settings = column.settings
	
	if old_key == key and old_type == type and old_editable == editable and old_expression == expression and old_settings.hash() == settings.hash(): 
		return UpdateResult.none()
	
	# force editable to false if any key was found
	var has_key_in_expression = Helper.is_any_key_in_expression(expression)
	if has_key_in_expression:
		editable = false
	
	column.key = key
	column.type = type
	column.editable = editable
	column.expression = expression
	column.settings = settings
	
	if old_key != key:
		sheet.columns[key] = sheet.columns[old_key]
		sheet.columns.erase(old_key)
		
		# update column key from column expressions
		for other_column in sheet.columns.values():
			other_column.expression = Helper.replace_key_in_expression(
				old_key, key,
				other_column.expression
			)
		
		# update column key from tag expressions
		for tag in sheet.tags.values():
			tag.filter_expression = Helper.replace_key_in_expression(
				old_key, key,
				tag.filter_expression
			)
	
	# reset column_observers
	for other_column in sheet.columns.values():
		other_column.column_observers.erase(old_key)
	
	var observed_keys = Helper.find_keys_in_expression(expression)
	for observed_key in observed_keys:
		var observed: GDColumn = sheet.columns[observed_key]
		observed.column_observers.append(key)
	
	# update line values
	for line in sheet.lines.values():
		if old_key != key:
			sheet.values[line.key][key] = sheet.values[line.key][old_key]
			sheet.values[line.key].erase(old_key)
		
		if not editable or old_type != type:
			_update_expression(sheet, line, column, expression)
		else:
			var value = sheet.values[line.key][key]
			var value_error_message = Properties.validate_value(value, type, settings, self)
			if not value_error_message.is_empty():
				_update_expression(sheet, line, column, expression)
	
	any_changed.emit()
	return UpdateResult.ok()


# LINES
func can_create_lines(sheet: GDSheet, key: String, count: int) -> String:
	# validate key
	var existing_keys = sheet.lines.keys()
	for i in range(count):
		var line_key = key + ("" if count == 1 else str(i))
		var error_message = Properties.validate_key(line_key, existing_keys)
		if not error_message.is_empty():
			return error_message
	return ""


func create_lines(sheet: GDSheet, key: String, count: int) -> UpdateResult:
	var error_message = can_create_lines(sheet, key, count)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var columns_ordered = get_columns_ordered_by_observers(sheet.columns.values())
	
	for i in range(count):
		var line = GDLine.new()
		line.key = key + ("" if count == 1 else str(i))
		line.index = sheet.lines.size()
		sheet.lines[line.key] = line
		
		sheet.values[line.key] = Helper.get_values_from_columns(sheet)
		
		for column in columns_ordered:
			_update_expression(sheet, line, column, column.expression)
		
		# update values depending on line key and index
		for column in sheet.columns.values():
			if Helper.is_key_in_expression("key", column.expression):
				_update_expression(sheet, line, column, column.expression)
			if Helper.is_key_in_expression("index", column.expression):
				_update_expression(sheet, line, column, column.expression)
	
	any_changed.emit()
	return UpdateResult.ok()


func can_duplicate_line(sheet: GDSheet, key: String) -> String:
	# validate key
	var existing_keys = sheet.lines.keys()
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	return ""


func duplicate_line(sheet: GDSheet, other_line: GDLine, key: String) -> UpdateResult:
	var error_message = can_duplicate_line(sheet, key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var line = GDLine.new()
	line.key = key
	line.index = sheet.lines.size()
	sheet.lines[line.key] = line
	
	# duplicate values
	sheet.values[line.key] = sheet.values[other_line.key].duplicate(true)
	
	# update values depending on line key or line index
	for column in sheet.columns.values():
		if Helper.is_key_in_expression("key", column.expression):
			_update_expression(sheet, line, column, column.expression)
		if Helper.is_key_in_expression("index", column.expression):
			_update_expression(sheet, line, column, column.expression)
	
	any_changed.emit()
	return UpdateResult.ok()


func can_remove_lines(sheet: GDSheet, lines: Array) -> String:
	return ""


func remove_lines(sheet: GDSheet, lines: Array) -> UpdateResult:
	var error_message = can_remove_lines(sheet, lines)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	for line in lines:
		for other_sheet in sheets.values():
			for other_column in other_sheet.columns.values():
				if other_column.type == "Reference" and other_column.settings.sheet_key == sheet.key:
					if other_column.expression == Properties.get_expression(other_column.type, line.key):
						other_column.expression = Properties.get_default_expression(other_column.type)

					for other_line in other_sheet.lines.values():
						var value = other_sheet.values[other_line.key][other_column.key]
						if value == line.key:
							_update_expression(other_sheet, other_line, other_column, other_column.expression)
		
		sheet.lines.erase(line.key)
		sheet.values.erase(line.key)
		for group in sheet.groups.values():
			group.erase(line.key)
	
	# update indexes
	var lines_ordered = get_lines_ordered(sheet)
	for index in range(lines_ordered.size()):
		lines_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_move_lines(sheet: GDSheet, lines_from: Array, line_to: GDLine, shift: int) -> String:
	return ""


func move_lines(sheet: GDSheet, lines_from: Array, line_to: GDLine, shift: int) -> UpdateResult:
	var error_message = can_move_lines(sheet, lines_from, line_to, shift)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	if line_to in lines_from: 
		return UpdateResult.none()
	
	var lines_ordered = get_lines_ordered(sheet)
	for line_from in lines_from:
		lines_ordered.erase(line_from)
	
	var index_target = lines_ordered.find(line_to)
	if index_target == lines_ordered.size() - 1 and shift == 1:
		lines_ordered.append_array(lines_from)
	else:
		lines_from.reverse()
		if shift == -1:
			for line_from in lines_from:
				lines_ordered.insert(index_target, line_from)
		else:
			for line_from in lines_from:
				lines_ordered.insert(index_target + 1, line_from)
	
	for index in range(lines_ordered.size()):
		var line = lines_ordered[index]
		
		if line.index != index:
			line.index = index
			
			# update values depending on line index
			for column in sheet.columns.values():
				if Helper.is_key_in_expression("index", column.expression):
					_update_expression(sheet, line, column, column.expression)
	
	any_changed.emit()
	return UpdateResult.ok()


func can_update_line(sheet: GDSheet, line: GDLine, key: String) -> String:
	# validate key
	var existing_keys = sheet.lines.keys()
	existing_keys.erase(line.key)
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	return ""


func update_line(sheet: GDSheet, line: GDLine, key: String) -> UpdateResult:
	var error_message = can_update_line(sheet, line, key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var old_key = line.key
	
	if old_key == key:
		return UpdateResult.none()
	
	# update line key in references
	for other_sheet in sheets.values():
		for other_column in other_sheet.columns.values():
			if other_column.type == "Reference" and other_column.settings.sheet_key == sheet.key:
				other_column.expression = Helper.replace_word_in_expression(old_key, key, other_column.expression)

				for other_line in other_sheet.lines.values():
					var value = other_sheet.values[other_line.key][other_column.key]
					if value == old_key:
						other_sheet.values[other_line.key][other_column.key] = key
	
	# update line values
	sheet.values[key] = sheet.values[old_key]
	sheet.values.erase(old_key)
	
	# update lines
	sheet.lines[key] = sheet.lines[old_key]
	sheet.lines.erase(old_key)
	
	# update groups
	for group in sheet.groups.values():
		if line.key in group:
			group.erase(old_key)
			group.append(key)
	
	line.key = key
	
	# update values depending on line key
	for column in sheet.columns.values():
		if Helper.is_key_in_expression("key", column.expression):
			_update_expression(sheet, line, column, column.expression)
	
	any_changed.emit()
	return UpdateResult.ok()


# TAGS
func can_create_tag(sheet: GDSheet, key: String, filter_expression: String) -> String:
	# validate key
	var existing_keys = sheet.tags.keys()
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	
	# validate expression
	var values = Helper.get_values_from_columns(sheet)
	var value = evaluator.evaluate(filter_expression, values)
	if value == null:
		return "Error while evaluating expression: " + filter_expression
	
	# validate value
	if not (value is bool):
		return "Expression must return a boolean value: " + filter_expression
	
	return ""


func create_tag(sheet: GDSheet, key: String, filter_expression: String) -> UpdateResult:
	var error_message = can_create_tag(sheet, key, filter_expression)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	# build tag
	var tag = GDTag.new()
	tag.key = key
	tag.index = sheet.tags.size()
	tag.filter_expression = filter_expression
	sheet.tags[tag.key] = tag
	sheet.groups[key] = []
	
	# build tag observers on columns
	var observed_keys = Helper.find_keys_in_expression(filter_expression)
	for observed_key in observed_keys:
		var observed: GDColumn = sheet.columns[observed_key]
		observed.tag_observers.append(key)
	
	# update groups from tag
	for line in sheet.lines.values():
		update_group(sheet, tag, line)
	
	any_changed.emit()
	return UpdateResult.ok()


func can_duplicate_tag(sheet: GDSheet, key: String) -> String:
	# validate key
	var existing_keys = sheet.tags.keys()
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	return ""


func duplicate_tag(sheet: GDSheet, other_tag: GDTag, key: String) -> UpdateResult:
	var error_message = can_duplicate_tag(sheet, key)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var tag = GDTag.new()
	tag.key = key
	tag.index = sheet.tags.size()
	tag.filter_expression = other_tag.filter_expression
	sheet.tags[tag.key] = tag
	
	# duplicate observers
	for column in sheet.columns.values():
		if other_tag.key in column.column_observers:
			column.column_observers.append(key)
	
	# duplicate group
	sheet.groups[key] = sheet.groups[other_tag.key].duplicate(true)
	
	any_changed.emit()
	return UpdateResult.ok()


func can_remove_tags(sheet: GDSheet, tags: Array) -> String:
	return ""


func remove_tags(sheet: GDSheet, tags: Array) -> UpdateResult:
	var error_message = can_remove_tags(sheet, tags)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	for tag in tags:
		# remove from tags
		sheet.tags.erase(tag.key)
		# remove from groups
		sheet.groups.erase(tag.key)
		# remove from column.tag_observers
		for column in sheet.columns.values():
			column.tag_observers.erase(tag.key)
	
	# update indexes
	var tags_ordered = get_tags_ordered(sheet)
	for index in range(tags_ordered.size()):
		tags_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_move_tags(sheet: GDSheet, tags_from: Array, tag_to: GDTag, shift: int) -> String:
	return ""


func move_tags(sheet: GDSheet, tags_from: Array, tag_to: GDTag, shift: int) -> UpdateResult:
	var error_message = can_move_tags(sheet, tags_from, tag_to, shift)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	if tag_to in tags_from: 
		return UpdateResult.none()
	
	var tags_ordered = get_tags_ordered(sheet)
	for tag_from in tags_from:
		tags_ordered.erase(tag_from)
	
	var index_target = tags_ordered.find(tag_to)
	if index_target == tags_ordered.size() - 1 and shift == 1:
		tags_ordered.append_array(tags_from)
	else:
		tags_from.reverse()
		if shift == -1:
			for tag_from in tags_from:
				tags_ordered.insert(index_target, tag_from)
		else:
			for tag_from in tags_from:
				tags_ordered.insert(index_target + 1, tag_from)
	
	for index in range(tags_ordered.size()):
		tags_ordered[index].index = index
	
	any_changed.emit()
	return UpdateResult.ok()


func can_update_tag(sheet: GDSheet, tag: GDTag, key: String, filter_expression: String) -> String:
	var existing_keys = sheet.tags.keys()
	existing_keys.erase(tag.key)
	var error_message = Properties.validate_key(key, existing_keys)
	if not error_message.is_empty():
		return error_message
	
	if tag.filter_expression != filter_expression:
		# validate expression
		var values = Helper.get_values_from_columns(sheet)
		var value = evaluator.evaluate(filter_expression, values)
		if value == null:
			return "Error while evaluating expression: " + filter_expression
	
		# validate value
		if not (value is bool):
			return "Expression must return a boolean value: " + filter_expression
	
	return ""


func update_tag(sheet: GDSheet, tag: GDTag, key: String, filter_expression: String) -> UpdateResult:
	var error_message = can_update_tag(sheet, tag, key, filter_expression)
	if not error_message.is_empty():
		return UpdateResult.ko(error_message)
	
	var old_key = tag.key
	var old_filter_expression = tag.filter_expression
	
	if old_key == key and old_filter_expression == filter_expression:
		return UpdateResult.none()
	
	tag.key = key
	tag.filter_expression = filter_expression
	
	# update columns observers
	for column in sheet.columns.values():
		column.tag_observers.erase(old_key)
	
	var observed_keys = Helper.find_keys_in_expression(filter_expression)
	for observed_key in observed_keys:
		var observed: GDColumn = sheet.columns[observed_key]
		observed.tag_observers.append(key)
	
	if old_key != key:
		# update tags
		sheet.tags[key] = sheet.tags[old_key]
		sheet.tags.erase(old_key)
		
		# update groups
		sheet.groups[key] = sheet.groups[old_key]
		sheet.groups.erase(old_key)
	
	if old_filter_expression != filter_expression:
		# update groups if filter expression has changed
		sheet.groups[key] = []
		for line in sheet.lines.values():
			update_group(sheet, tag, line)
	
	any_changed.emit()
	return UpdateResult.ok()


# COMPUTE
func on_file_moved(old_file: String, new_file: String):
	if not loaded: return
	
	for sheet in sheets.values():
		var columns_ordered = get_columns_ordered_by_observers(sheet.columns.values())
		
		for column in columns_ordered:
			# update column expression
			var old_column_expression = column.expression
			var new_column_expression = Helper.replace_word_in_expression(old_file, new_file, old_column_expression)
			if old_column_expression != new_column_expression:
				column.expression = new_column_expression
				
			for line in sheet.lines.values():
				# update value
				var value = sheet.values[line.key][column.key]
				if value is String and value == old_file:
					sheet.values[line.key][column.key] = new_file
				elif column.type == "Region" and value.texture == old_file:
					value.texture = new_file
		
		for tag in sheet.tags.values():
			# update filter expression
			var old_filter_expression = tag.filter_expression
			var new_filter_expression = Helper.replace_word_in_expression(old_file, new_file, old_filter_expression)
			if old_filter_expression != new_filter_expression:
				tag.filter_expression = new_filter_expression
				
				# update groups from tag
				for line in sheet.lines.values():
					update_group(sheet, tag, line)
	
	any_changed.emit()


func on_file_removed(file: String):
	on_file_moved(file, "")


func update_group(sheet: GDSheet, tag: GDTag, line: GDLine):
	sheet.groups[tag.key].erase(line.key)
	
	var values = Helper.get_values_from_line(sheet, line)
	var value = evaluator.evaluate(tag.filter_expression, values)
	if add_to_group == null:
		push_error("Error while evaluating expression: " + tag.filter_expression)
	elif value:
		sheet.groups[tag.key].append(line.key)


func update_values(sheet: GDSheet, lines: Array, column: GDColumn, value) -> void:
	var expression = Properties.get_expression(column.type, value)
	
	for line in lines:
		_update_expression(sheet, line, column, expression)
	
	any_changed.emit()
	values_changed.emit()


func update_values_as_default(sheet: GDSheet, lines: Array, columns: Array) -> void:
	var columns_ordered = get_columns_ordered_by_observers(columns)
	
	for line in lines:
		for column in columns_ordered:
			_update_expression(sheet, line, column, column.expression)
	
	any_changed.emit()
	values_changed.emit()


func _update_expression(sheet: GDSheet, line: GDLine, column: GDColumn, expression: String) -> void:
	var values = Helper.get_values_from_line(sheet, line)
	values.erase(column.key)
	
	var value = evaluator.evaluate(expression, values)
	if value == null:
		push_error("Error while evaluating expression: line [index: " + str(line.index) + ", key: " + line.key + "], column [index: " + str(column.index) + ", key: " + column.key + "]")
		return
	
	var error_message = Properties.validate_value(value, column.type, column.settings, self)
	if not error_message.is_empty():
		push_error(error_message + ": line [index: " + str(line.index) + ", key: " + line.key + "], column [index: " + str(column.index) + ", key: " + column.key + "]")
		return
	
	# update value
	sheet.values[line.key][column.key] = value
	
	# update groups
	for tag in sheet.tags.values():
		update_group(sheet, tag, line)
	
	# update observers values
	for observer in column.column_observers:
		var other_column: GDColumn = sheet.columns[observer]
		_update_expression(sheet, line, other_column, other_column.expression)


func has_cyclic_observers(sheet: GDSheet, observer: String, new_observers: Array):
	if observer in new_observers:
		return true
	else:
		var column: GDColumn = sheet.columns[observer]
		for other_observer in column.column_observers:
			if has_cyclic_observers(sheet, other_observer, new_observers):
				return true
	return false


# HELPERS
func get_sheets_ordered() -> Array[GDSheet]:
	var ordered: Array = sheets.values()
	ordered.sort_custom(func(a, b): return a.index < b.index)
	return ordered


func get_columns_ordered(sheet: GDSheet) -> Array[GDColumn]:
	var ordered: Array = sheet.columns.values()
	ordered.sort_custom(func(a, b): return a.index < b.index)
	return ordered


func get_columns_ordered_by_observers(columns: Array) -> Array[GDColumn]:
	var ordered: Array = columns.duplicate()
	ordered.sort_custom(func(a, b): return a.column_observers.find(b.key) == -1)
	ordered.reverse()
	return ordered


func get_lines_ordered(sheet: GDSheet) -> Array[GDLine]:
	var ordered: Array = sheet.lines.values()
	ordered.sort_custom(func(a, b): return a.index < b.index)
	return ordered


func get_tags_ordered(sheet: GDSheet) -> Array[GDTag]:
	var ordered: Array = sheet.tags.values()
	ordered.sort_custom(func(a, b): return a.index < b.index)
	return ordered
