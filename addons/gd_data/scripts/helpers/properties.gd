@tool
extends Object
class_name Properties


const TYPES: Array[String] = [
	"String", 
	"Integer", 
	"Float", 
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
	"Dictionary",
	"Array",
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
		"String": return SettingsContainer.new()
		"Integer": return SettingsContainer.new()
		"Float": return SettingsContainer.new()
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
		"Dictionary": return SettingsContainer.new()
		"Array": return SettingsContainer.new()
		"Region": return SettingsContainer.new()
		_: push_error("Type '" + type + "' must be handled")


static func get_control_editor(type: String):
	match type:
		"String": return load("res://addons/gd_data/scenes/editors/string_editor_container.tscn").instantiate()
		"Integer": return load("res://addons/gd_data/scenes/editors/integer_editor_container.tscn").instantiate()
		"Float": return load("res://addons/gd_data/scenes/editors/float_editor_container.tscn").instantiate()
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
		"Dictionary": return load("res://addons/gd_data/scenes/editors/dictionary_editor_container.tscn").instantiate()
		"Array": return load("res://addons/gd_data/scenes/editors/array_editor_container.tscn").instantiate()
		"Region": return load("res://addons/gd_data/scenes/editors/region_editor_container.tscn").instantiate()
		_: push_error("Type '" + type + "' must be handled")


static func get_icon(control: Control, type: String):
	match type:
		"String": return control.get_theme_icon("String", "EditorIcons")
		"Integer": return control.get_theme_icon("int", "EditorIcons")
		"Float": return control.get_theme_icon("float", "EditorIcons")
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
		"Dictionary": return control.get_theme_icon("Dictionary", "EditorIcons")
		"Array": return control.get_theme_icon("Array", "EditorIcons")
		"Region": return control.get_theme_icon("AtlasTexture", "EditorIcons")
		_: push_error("Type '" + type + "' must be handled")


static func build_grid_cell(grid_drawer: GridDrawer, cell_rect: Rect2, column: GDColumn, value):
	match column.type:
		"String": 
			grid_drawer.draw_text(cell_rect, value.replacen("\n", "\\n"))
		"Integer": 
			grid_drawer.draw_text(cell_rect, str(value))
		"Float": 
			grid_drawer.draw_text(cell_rect, str(value))
		"Bool": 
			grid_drawer.draw_check(cell_rect, value)
		"Color": 
			grid_drawer.draw_rect_margin(cell_rect, value, 12)
		"File": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Image": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_image(cell_rect, value)
		"Audio": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"3D": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Scene": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Script": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Scene": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Resource": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value.split("/")[-1])
		"Reference": 
			if value.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_text(cell_rect, value)
		"Dictionary": 
			grid_drawer.draw_text(cell_rect, JSON.stringify(value, "", false))
		"Array": 
			grid_drawer.draw_text(cell_rect, JSON.stringify(value, "", false))
		"Region": 
			if value.texture.is_empty(): grid_drawer.draw_text(cell_rect, "<none>")
			else: grid_drawer.draw_image_region(cell_rect, value.texture, value.hor, value.ver, value.frame, value.sx, value.sy, value.ox, value.oy)
		_: push_error("Type '" + column.type + "' must be handled")


static func get_default_value(type: String):
	match type:
		"String": return ""
		"Integer": return 0
		"Float": return 0.0
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
		"Dictionary": return {}
		"Array": return []
		"Region": return { "frame": 0, "hor": 1, "ver": 1, "sx": 0, "sy": 0, "ox": 0, "oy": 0, "texture": "" }
		_: push_error("Type '" + type + "' must be handled")


static func get_default_expression(type: String):
	var default_value = get_default_value(type)
	return get_expression(type, default_value)


static func get_expression(type: String, value):
	match type:
		"String": return "\"" + value + "\""
		"Integer": return str(value)
		"Float": return str(value) + ".0" if str(value).findn(".") == -1 else str(value)
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
		"Dictionary": return JSON.stringify(value, "", false)
		"Array": return JSON.stringify(value, "", false)
		"Region": return JSON.stringify(value, "", false)
		_: push_error("Type '" + type + "' must be handled")
	return ""


static func get_default_settings(type: String):
	match type:
		"String": return {}
		"Integer": return {}
		"Float": return {}
		"Bool": return {}
		"Color": return {}
		"File": return {}
		"Image": return {}
		"Audio": return {}
		"3D": return {}
		"Scene": return {}
		"Script": return {}
		"Resource": return {}
		"Reference": return { sheet_key = "" }
		"Dictionary": return {}
		"Array": return {}
		"Region": return {}
		_: push_error("Type '" + type + "' must be handled")


static func get_input_value_type(column: GDColumn, metadata: GDMetadata):
	match column.type:
		"String": return "String"
		"Integer": return "int"
		"Float": return "float"
		"Bool": return "bool"
		"Color": return "String"
		"File": return "String"
		"Image": return "String"
		"Audio": return "String"
		"3D": return "String"
		"Scene": return "String"
		"Script": return "String"
		"Resource": return "String"
		"Reference": return metadata.sheets_file_name[column.settings.sheet_key]
		"Dictionary": return "Dictionary"
		"Array": return "Array"
		"Region": return "Dictionary"
		_: push_error("Type '" + column.type + "' must be handled")


static func get_output_value_type(column: GDColumn, metadata: GDMetadata):
	match column.type:
		"String": return "String"
		"Integer": return "int"
		"Float": return "float"
		"Bool": return "bool"
		"Color": return "Color"
		"File": return "String"
		"Image": return "Texture2D"
		"Audio": return "AudioStream"
		"3D": return "ArrayMesh"
		"Scene": return "PackedScene"
		"Script": return "GDScript"
		"Resource": return "Resource"
		"Reference": return  metadata.sheets_file_name[column.settings.sheet_key]
		"Dictionary": return "Dictionary"
		"Array": return "Array"
		"Region": return "AtlasTexture"
		_: push_error("Type '" + column.type + "' must be handled")


static func get_output_value(column: GDColumn):
	match column.type:
		"String": return "_value"
		"Integer": return "_value"
		"Float": return "_value"
		"Bool": return "_value"
		"Color": return "Color(_value)"
		"File": return "_value"
		"Image": return "load(_value) if not _value.is_empty() else null"
		"Audio": return "load(_value) if not _value.is_empty() else null"
		"3D": return "load(_value) if not _value.is_empty() else null"
		"Scene": return "load(_value) if not _value.is_empty() else null"
		"Script": return "load(_value) if not _value.is_empty() else null"
		"Resource": return "load(_value) if not _value.is_empty() else null"
		"Reference": return "_value"
		"Dictionary": return "_value"
		"Array": return "_value"
		"Region": return "Helper.get_atlas_from_region(_value)"
		_: push_error("Type '" + column.type + "' must be handled")


static func validate_key(key: String, existing_keys: Array, prefix: String = "Key"):
	var pattern = "^[a-zA-Z0-9_]+$"
	var regex = RegEx.new()
	regex.compile(pattern)
	
	if key.is_empty():
		return prefix + " must not be empty"
	elif not regex.search(key):
		return prefix + " must match '" + pattern + "'"
	elif key in existing_keys:
		return prefix + " already exists"
	return ""


static func validate_value(value, type: String, settings: Dictionary, data: GDData):
	match type:
		"String": return _validate_string(value)
		"Integer": return _validate_integer(value)
		"Float": return _validate_float(value)
		"Bool": return _validate_bool(value)
		"Color": return _validate_color(value)
		"File": return _validate_file(value, "")
		"Image": return _validate_file(value, "Image")
		"Audio": return _validate_file(value, "Audio")
		"3D": return _validate_file(value, "3D")
		"Scene": return _validate_file(value, "Scene")
		"Script": return _validate_file(value, "Script")
		"Resource": return _validate_file(value, "Resource")
		"Reference": return _validate_reference(value, settings, data)
		"Dictionary": return _validate_dictionary(value)
		"Array": return _validate_array(value)
		"Region": return _validate_region(value)
		_: push_error("Type '" + type + "' must be handled")
	return ""


static func _validate_string(value):
	if not value is String: 
		return "Value must be a string"
	return ""


static func _validate_integer(value):
	if not value is int: 
		return "Value must be an integer"
	return ""


static func _validate_float(value):
	if not value is float: 
		return "Value must be a float"
	return ""


static func _validate_bool(value):
	if not value is bool: 
		return "Value must be a boolean"
	return ""


static func _validate_color(value):
	if not value is String: 
		return "Value must be a string"
	if not Color.html_is_valid(value):
		return "Color not valid"
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


static func _validate_reference(value, settings: Dictionary, data: GDData):
	if not value is String: 
		return "Value must be a string"
	if value.is_empty(): 
		return ""
	var keys = data.sheets[settings.sheet_key].lines.keys()
	if not (value in keys):
		return "Value must be a valid line key"
	return ""


static func _validate_array(value):
	if not value is Array: 
		return "Value must be an array"
	return ""


static func _validate_dictionary(value):
	if not value is Dictionary: 
		return "Value must be a dictionary"
	return ""


static func _validate_region(value):
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
