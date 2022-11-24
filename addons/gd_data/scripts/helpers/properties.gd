@tool
extends Object
class_name Properties


const TYPES: Array[String] = [
	"Text", 
	"Number", 
	"Bool", 
	"Color", 
	"File", 
	"Reference",
	"Object",
	"Region",
]

const FILE_TYPES: Dictionary = {
	"Image": ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"],
	"Audio": ["wav", "ogg", "mp3"],
	"3D": ["gltf", "glb", "dae", "escn", "fbx", "obj"],
	"GDScene": ["tscn"],
	"GDScript": ["gd"],
	"GDResource": ["tres"],
	"Any": [""],
}


static func get_control_settings(type: String):
	match type:
		"Text": return SettingsContainer.new()
		"Number": return SettingsContainer.new()
		"Bool": return SettingsContainer.new()
		"Color": return SettingsContainer.new()
		"File": return load("res://addons/gd_data/scenes/settings/file_settings_container.tscn").instantiate()
		"Reference": return load("res://addons/gd_data/scenes/settings/reference_settings_container.tscn").instantiate()
		"Object": return SettingsContainer.new()
		"Region": return SettingsContainer.new()
		_: push_error("Type '" + type + "' must be handled")


static func get_control_editor(type: String):
	match type:
		"Text": return load("res://addons/gd_data/scenes/editors/text_editor_container.tscn").instantiate()
		"Number": return load("res://addons/gd_data/scenes/editors/number_editor_container.tscn").instantiate()
		"Bool": return load("res://addons/gd_data/scenes/editors/bool_editor_container.tscn").instantiate()
		"Color": return load("res://addons/gd_data/scenes/editors/color_editor_container.tscn").instantiate()
		"File": return load("res://addons/gd_data/scenes/editors/file_editor_container.tscn").instantiate()
		"Reference": return load("res://addons/gd_data/scenes/editors/reference_editor_container.tscn").instantiate()
		"Object": return load("res://addons/gd_data/scenes/editors/object_editor_container.tscn").instantiate()
		"Region": return load("res://addons/gd_data/scenes/editors/region_editor_container.tscn").instantiate()
		_: push_error("Type '" + type + "' must be handled")


static func get_icon(control: Control, column: Column):
	match column.type:
		"Text": return control.get_theme_icon("String", "EditorIcons")
		"Number": return control.get_theme_icon("float", "EditorIcons")
		"Bool": return control.get_theme_icon("bool", "EditorIcons")
		"Color": return control.get_theme_icon("Color", "EditorIcons")
		"File": 
			var file_type = column.settings.file_type
			match file_type:
				"Image": return control.get_theme_icon("ImageTexture", "EditorIcons")
				"Audio": return control.get_theme_icon("AudioStream", "EditorIcons")
				"3D": return control.get_theme_icon("Texture3D", "EditorIcons")
				"GDScene": return control.get_theme_icon("PackedScene", "EditorIcons")
				"GDScript": return control.get_theme_icon("Script", "EditorIcons")
				"GDResource": return control.get_theme_icon("Object", "EditorIcons")
				"Any": return control.get_theme_icon("File", "EditorIcons")
				_: push_error("File type '" + file_type + "' must be handled")
		"Reference": return control.get_theme_icon("Instance", "EditorIcons")
		"Object": return control.get_theme_icon("MiniObject", "EditorIcons")
		"Region": return control.get_theme_icon("AnimatedTexture", "EditorIcons")
		_: push_error("Type '" + column.type + "' must be handled")


static func build_grid_cell(grid_tree: GridTree, item: TreeItem, grid_column_index: int, column: Column, value):
	match column.type:
		"Text": grid_tree.build_item_string(item, grid_column_index, value)
		"Number": grid_tree.build_item_number(item, grid_column_index, value)
		"Bool": grid_tree.build_item_bool(item, grid_column_index, value)
		"Color": grid_tree.build_item_color(item, grid_column_index, value)
		"File": grid_tree.build_item_file(item, grid_column_index, value, column.settings.file_type == "Image")
		"Reference": grid_tree.build_item_reference(item, grid_column_index, value)
		"Object": grid_tree.build_item_object(item, grid_column_index, value)
		"Region": grid_tree.build_item_region(item, grid_column_index, value)
		_: push_error("Type '" + column.type + "' must be handled")


static func get_settings(type: String):
	var settings
	match type:
		"Text":
			settings = {
				value = "",
				expression = get_expression(type, "")
			}
		"Number":
			settings = {
				value = 0,
				expression = get_expression(type, 0)
			}
		"Bool":
			settings = {
				value = false,
				expression = get_expression(type, false),
			}
		"Color":
			settings = {
				value = "ffffffff",
				expression = get_expression(type, "ffffffff"),
			}
		"File":
			settings = {
				value = "",
				expression = get_expression(type, ""),
				file_type = "Any",
				path_begins_with = "",
				file_begins_with = "",
			}
		"Reference":
			settings = {
				value = "",
				expression = get_expression(type, ""),
				sheet_key = "",
			}
		"Object":
			settings = {
				value = {},
				expression = get_expression(type, {}),
			}
		"Region":
			var value = { "frame": 0, "hor": 1, "ver": 1, "sx": 0, "sy": 0, "ox": 0, "oy": 0, "texture": "" }
			settings = {
				value = value,
				expression = get_expression(type, value),
			}
		_: push_error("Type '" + type + "' must be handled")
	return settings


static func get_expression(type: String, value):
	match type:
		"Text":
			return "\"" + value + "\""
		"Number":
			return str(value)
		"Bool":
			return str(value)
		"Color":
			return "\"" + str(value) + "\""
		"File":
			return "\"" + str(value) + "\""
		"Reference":
			return "\"" + str(value) + "\""
		"Object":
			return JSON.stringify(value, "", false)
		"Region":
			return JSON.stringify(value, "", false)
		_: push_error("Type '" + type + "' must be handled")
	return ""


static func validate_key(key: String, existing_keys: Array):
	var pattern = "^[a-zA-Z0-9_]+$"
	var regex = RegEx.new()
	regex.compile(pattern)
	
	if key.is_empty():
		return "Key must not be empty"
	elif not regex.search(key):
		return "Key must match '" + pattern + "'"
	elif key in existing_keys:
		return "Key already exists"
	return ""


static func validate_value(value, type: String, settings: Dictionary, sheets: Dictionary):
	match type:
		"Text":
			return _validate_text(value, settings)
		"Number":
			return _validate_number(value, settings)
		"Bool":
			return _validate_bool(value, settings)
		"Color":
			return _validate_color(value, settings)
		"File":
			return _validate_file(value, settings)
		"Reference":
			return _validate_reference(value, settings, sheets)
		"Object":
			return _validate_object(value, settings)
		"Region":
			return _validate_region(value, settings)
		_: push_error("Type '" + type + "' must be handled")
	return ""


static func _validate_text(value, settings: Dictionary):
	if not value is String: 
		return "Value must be a string"
	return ""


static func _validate_number(value, settings: Dictionary):
	if not (value is int or value is float): 
		return "Value must be a number"
	return ""


static func _validate_bool(value, settings: Dictionary):
	if not value is bool: 
		return "Value must be a boolean"
	return ""


static func _validate_color(value, settings: Dictionary):
	if not value is String: 
		return "Value must be a string"
	return ""


static func _validate_file(value, settings: Dictionary):
	if not value is String: 
		return "Value must be a string"
	if value.is_empty(): 
		return ""
	if not value.begins_with(settings.path_begins_with):
		return "File path must begins with '" + settings.path_begins_with + "'"
	if not value.split("/")[-1].begins_with(settings.file_begins_with):
		return "File name must begins with '" + settings.file_begins_with + "'"
	if settings.file_type != "Any" and not value.split(".")[-1] in FILE_TYPES[settings.file_type]:
		return "Extension not allowed"
	if not FileAccess.file_exists(value):
		return "File does not exists"
	return ""


static func _validate_reference(value, settings: Dictionary, sheets: Dictionary):
	if not value is String: 
		return "Value must be a string"
	if value.is_empty(): 
		return ""
	var keys = sheets[settings.sheet_key].lines.keys()
	if not (value in keys):
		return "Value must be a valid line key"
	return ""


static func _validate_object(value, settings: Dictionary):
	if not (value is Dictionary or value is Array): 
		return "Value must be an array or a dictionary"
	return ""


static func _validate_region(value, settings: Dictionary):
	if not (value is Dictionary or value is Array): 
		return "Value must be an array or a dictionary"
	var required = ["frame", "hor", "ver", "sx", "sy", "ox", "oy", "texture"]
	if not value.has_all(required): 
		return "Value must contains fields " + str(required)
	if value.frame < 0: return "Frame value must be gte 0"
	if value.frame >= value.hor * value.ver: return "Frame value must be lte " + str(value.hor * value.ver)
	if value.hor < 1: return "Horizontal value must be gte 1"
	if value.ver < 1: return "Vertical value must be gte 1"
	if value.sx < 0: return "SeparationX value must be gte 0"
	if value.sy < 0: return "SeparationY value must be gte 0"
	if value.ox < 0: return "OffsetX value must be gte 0"
	if value.oy < 0: return "OffsetY value must be gte 0"
	var error_message = _validate_image(value.texture)
	if not error_message.is_empty(): return error_message
	return ""


static func _validate_image(value):
	if not value is String: 
		return "Texture value must be a string"
	if value.is_empty(): 
		return ""
	if not value.split(".")[-1] in FILE_TYPES["Image"]:
		return "Extension not allowed for images"
	if not FileAccess.file_exists(value):
		return "File does not exists"
	return ""
