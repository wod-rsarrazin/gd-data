@tool
extends Object
class_name Properties


const TYPES: Array[String] = [
	"Text", 
	"Number", 
	"Bool", 
	"Color", 
	"File", 
	"Image", 
	"Audio", 
	"3D", 
	"Scene", 
	"Script", 
	"Resource", 
	"Reference",
	"Object",
	"Region",
]

const FILE_TYPES: Dictionary = {
	"Image": ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"],
	"Audio": ["wav", "ogg", "mp3"],
	"3D": ["gltf", "glb", "dae", "escn", "fbx", "obj"],
	"Scene": ["tscn"],
	"Script": ["gd"],
	"Resource": ["tres"]
}


static func get_control_settings(type: String):
	match type:
		"Text": return SettingsContainer.new()
		"Number": return SettingsContainer.new()
		"Bool": return SettingsContainer.new()
		"Color": return SettingsContainer.new()
		"File": return SettingsContainer.new()
		"Image": return SettingsContainer.new()
		"Audio": return SettingsContainer.new()
		"3D": return SettingsContainer.new()
		"Scene": return SettingsContainer.new()
		"Script": return SettingsContainer.new()
		"Resource": return SettingsContainer.new()
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
		"Image": return load("res://addons/gd_data/scenes/editors/image_editor_container.tscn").instantiate()
		"Audio": return load("res://addons/gd_data/scenes/editors/audio_editor_container.tscn").instantiate()
		"3D": return load("res://addons/gd_data/scenes/editors/3d_editor_container.tscn").instantiate()
		"Scene": return load("res://addons/gd_data/scenes/editors/scene_editor_container.tscn").instantiate()
		"Script": return load("res://addons/gd_data/scenes/editors/script_editor_container.tscn").instantiate()
		"Resource": return load("res://addons/gd_data/scenes/editors/resource_editor_container.tscn").instantiate()
		"Reference": return load("res://addons/gd_data/scenes/editors/reference_editor_container.tscn").instantiate()
		"Object": return load("res://addons/gd_data/scenes/editors/object_editor_container.tscn").instantiate()
		"Region": return load("res://addons/gd_data/scenes/editors/region_editor_container.tscn").instantiate()
		_: push_error("Type '" + type + "' must be handled")


static func get_icon(control: Control, type: String):
	match type:
		"Text": return control.get_theme_icon("String", "EditorIcons")
		"Number": return control.get_theme_icon("float", "EditorIcons")
		"Bool": return control.get_theme_icon("bool", "EditorIcons")
		"Color": return control.get_theme_icon("Color", "EditorIcons")
		"File": return control.get_theme_icon("File", "EditorIcons")
		"Image": return control.get_theme_icon("ImageTexture", "EditorIcons")
		"Audio": return control.get_theme_icon("AudioStream", "EditorIcons")
		"3D": return control.get_theme_icon("Texture3D", "EditorIcons")
		"Scene": return control.get_theme_icon("PackedScene", "EditorIcons")
		"Script": return control.get_theme_icon("Script", "EditorIcons")
		"Resource": return control.get_theme_icon("Object", "EditorIcons")
		"Reference": return control.get_theme_icon("Instance", "EditorIcons")
		"Object": return control.get_theme_icon("MiniObject", "EditorIcons")
		"Region": return control.get_theme_icon("AtlasTexture", "EditorIcons")
		_: push_error("Type '" + type + "' must be handled")


static func build_grid_cell(grid_drawer: GridDrawer, cell_rect: Rect2, column: Column, value):
	match column.type:
		"Text": grid_drawer.draw_text(cell_rect, value.replacen("\n", "\\n"))
		"Number": grid_drawer.draw_text(cell_rect, str(value))
		"Bool": grid_drawer.draw_check(cell_rect, value)
		"Color": grid_drawer.draw_rect_margin(cell_rect, value, 12)
		"File": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Image": grid_drawer.draw_image(cell_rect, value)
		"Audio": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"3D": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Scene": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Script": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Scene": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Resource": grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Reference": grid_drawer.draw_text(cell_rect, value)
		"Object": grid_drawer.draw_text(cell_rect, JSON.stringify(value, "", false))
		"Region": grid_drawer.draw_image_region(cell_rect, value.texture, value.hor, value.ver, value.frame, value.sx, value.sy, value.ox, value.oy)
		_: push_error("Type '" + column.type + "' must be handled")


static func get_default_value(type: String):
	match type:
		"Text": return ""
		"Number": return 0
		"Bool": return false
		"Color": return "ffffffff"
		"File": return ""
		"Image": return ""
		"Audio": return ""
		"3D": return ""
		"Scene": return ""
		"Script": return ""
		"Resource": return ""
		"Reference": return ""
		"Object": return {}
		"Region": return { "frame": 0, "hor": 1, "ver": 1, "sx": 0, "sy": 0, "ox": 0, "oy": 0, "texture": "" }
		_: push_error("Type '" + type + "' must be handled")


static func get_default_expression(type: String):
	var default_value = get_default_value(type)
	return get_expression(type, default_value)


static func get_expression(type: String, value):
	match type:
		"Text": return "\"" + value + "\""
		"Number": return str(value)
		"Bool": return str(value)
		"Color": return "\"" + str(value) + "\""
		"File": return "\"" + str(value) + "\""
		"Image": return "\"" + str(value) + "\""
		"Audio": return "\"" + str(value) + "\""
		"3D": return "\"" + str(value) + "\""
		"Scene": return "\"" + str(value) + "\""
		"Script": return "\"" + str(value) + "\""
		"Resource": return "\"" + str(value) + "\""
		"Reference": return "\"" + str(value) + "\""
		"Object": return JSON.stringify(value, "", false)
		"Region": return JSON.stringify(value, "", false)
		_: push_error("Type '" + type + "' must be handled")
	return ""


static func get_default_settings(type: String):
	match type:
		"Text": return {}
		"Number": return {}
		"Bool": return {}
		"Color": return {}
		"File": return {}
		"Image": return {}
		"Audio": return {}
		"3D": return {}
		"Scene": return {}
		"Script": return {}
		"Resource": return {}
		"Reference":
			return {
				sheet_key = "",
			}
		"Object": return {}
		"Region": return {}
		_: push_error("Type '" + type + "' must be handled")


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
		"Text": return _validate_text(value, settings)
		"Number": return _validate_number(value, settings)
		"Bool": return _validate_bool(value, settings)
		"Color": return _validate_color(value, settings)
		"File": return _validate_file(value, "")
		"Image": return _validate_file(value, "Image")
		"Audio": return _validate_file(value, "Audio")
		"3D": return _validate_file(value, "3D")
		"Scene": return _validate_file(value, "Scene")
		"Script": return _validate_file(value, "Script")
		"Resource": return _validate_file(value, "Resource")
		"Reference": return _validate_reference(value, settings, sheets)
		"Object": return _validate_object(value, settings)
		"Region": return _validate_region(value, settings)
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


static func _validate_file(value, file_type: String):
	if not value is String: 
		return "Value must be a string"
	if value.is_empty(): 
		return ""
	if not file_type.is_empty() and not value.split(".")[-1] in FILE_TYPES[file_type]:
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
	var error_message = _validate_file(value.texture, "Image")
	if not error_message.is_empty(): return error_message
	return ""
