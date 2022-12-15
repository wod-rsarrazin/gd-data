extends Object
class_name GDSheet


var key: String = ""
var cname: String = ""
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
		cname = cname,
		columns = columns_json,
		lines = lines_json,
		tags = tags_json,
		values = values,
		groups = groups
	}


static func from_json(json: Dictionary) -> GDSheet:
	var sheet := GDSheet.new()
	sheet.key = json.key
	sheet.index = json.index
	sheet.cname = json.cname
	sheet.values = json.values
	sheet.groups = json.groups
	
	for column_json in json.columns.values():
		var column = GDColumn.from_json(column_json)
		sheet.columns[column.key] = column
	
	for line_json in json.lines.values():
		var line = GDLine.from_json(line_json)
		sheet.lines[line.key] = line
	
	for tag_json in json.tags.values():
		var tag = GDTag.from_json(tag_json)
		sheet.tags[tag.key] = tag
	
	return sheet
