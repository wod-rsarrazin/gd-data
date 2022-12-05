extends Object
class_name Sheet


var key: String = ""
var index: int = 0
var lines: Dictionary = {}
var columns: Dictionary = {}
var tags: Dictionary = {}
var values: Dictionary = {}
var groups: Dictionary = {}


func to_json():
	var columns_json: Dictionary = {}
	for column in columns.values():
		columns_json[column.key] = column.to_json()
	
	var lines_json: Dictionary = {}
	for line in lines.values():
		lines_json[line.key] = line.to_json()
	
	var tags_json: Dictionary = {}
	for tag in tags.values():
		tags_json[tag.key] = tag.to_json()
	
	return {
		key = key,
		index = index,
		columns = columns_json,
		lines = lines_json,
		tags = tags_json,
		values = values,
		groups = groups
	}


static func from_json(json: Dictionary) -> Sheet:
	var sheet := Sheet.new()
	sheet.key = json.key
	sheet.index = json.index
	sheet.values = json.values
	sheet.groups = json.groups
	
	for column_json in json.columns.values():
		var column = Column.from_json(column_json)
		sheet.columns[column.key] = column
	
	for line_json in json.lines.values():
		var line = Line.from_json(line_json)
		sheet.lines[line.key] = line
	
	for tag_json in json.tags.values():
		var tag = Tag.from_json(tag_json)
		sheet.tags[tag.key] = tag
	
	return sheet
