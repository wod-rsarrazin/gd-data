extends Object
class_name GDMetadata


var export_directory: String = ""
var loader_file_name: String = "Data"
var sheets_file_name: Dictionary = {}


func to_json():
	return {
		export_directory = export_directory,
		loader_file_name = loader_file_name,
		sheets_file_name = sheets_file_name
	}


static func from_json(json: Dictionary) -> GDMetadata:
	var export := GDMetadata.new()
	export.export_directory = json.export_directory
	export.loader_file_name = json.loader_file_name
	export.sheets_file_name = json.sheets_file_name
	return export
