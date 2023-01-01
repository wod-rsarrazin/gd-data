@tool
extends ConfirmationDialog


@onready var sheet_tree: Tree = %SheetTree
@onready var code_edit: CodeEdit = %CodeEdit
@onready var export_dir_edit: LineEdit = %ExportDirEdit
@onready var export_dir_button: Button = %ExportDirButton
@onready var file_name_edit: LineEdit = %FileNameEdit
@onready var file_name_update_button: Button = %FileNameUpdateButton


var data: GDData
var selected_sheet: GDSheet


func _ready():
	if data == null: return
	
	remove_button(get_cancel_button())
	get_ok_button().pressed.connect(self._on_ok_button_pressed)
	
	file_name_update_button.icon = get_theme_icon("Reload", "EditorIcons")
	export_dir_button.icon = get_theme_icon("EditorFileDialog", "EditorIcons")
	
	export_dir_edit.text = data.metadata.export_directory
	
	export_dir_button.pressed.connect(self._on_export_dir_button_pressed)
	file_name_update_button.pressed.connect(self._on_file_name_update_button_pressed)
	sheet_tree.item_selected.connect(self._on_item_selected)
	
	var root = sheet_tree.create_item()
	
	var loader_item = sheet_tree.create_item(root)
	loader_item.set_text(0, "LOADER")
	loader_item.set_metadata(0, "LOADER  ")
	loader_item.set_custom_color(0, Color.WHITE)
	
	var sheet_ordered = data.get_sheets_ordered()
	for sheet in sheet_ordered:
		var item = sheet_tree.create_item(root)
		item.set_text(0, sheet.key)
		item.set_metadata(0, sheet.key)
		if selected_sheet == sheet:
			item.select(0)
	
	if sheet_tree.get_selected() == null:
		root.get_child(0).select(0)


func _on_ok_button_pressed():
	var path = data.metadata.export_directory + "/" + data.metadata.loader_file_name + ".gd"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(get_source_loader())
	
	for sheet in data.sheets.values():
		path = data.metadata.export_directory + "/" + data.metadata.sheets_file_name[sheet.key] + ".gd"
		file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(get_source_sheet(sheet))


func _on_export_dir_button_pressed():
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.dir_selected.connect(self._on_directory_selected)
	add_child(dialog)
	
	dialog.popup_centered_ratio(0.4)


func _on_directory_selected(path: String):
	export_dir_edit.text = path
	
	data.update_metadata_directory(path)


func _on_file_name_update_button_pressed():
	var item = sheet_tree.get_selected()
	
	var metadata = item.get_metadata(0)
	if metadata != "LOADER  ":
		var sheet = data.sheets[metadata]
		data.update_metadata_file_name(sheet, file_name_edit.text)
		
		var source = get_source_sheet(sheet)
		code_edit.text = source
	else:
		data.update_metadata_loader_file_name(file_name_edit.text)


func _on_item_selected():
	var item = sheet_tree.get_selected()
	
	var metadata = item.get_metadata(0)
	if metadata == "LOADER  ":
		var source = get_source_loader()
		code_edit.text = source
		file_name_edit.text = data.metadata.loader_file_name
	else:
		var sheet = data.sheets[metadata]
		var source = get_source_sheet(sheet)
		code_edit.text = source
		file_name_edit.text = data.metadata.sheets_file_name[sheet.key]


func get_source_sheet(sheet: GDSheet):
	var source = "# Auto generated by plugin GDData\n"
	source += "extends Resource\n"
	source += "class_name " + data.metadata.sheets_file_name[sheet.key] + "\n\n\n"
	
	source += "@export var key: String\n"
	source += "@export var index: int\n"
	for column in sheet.columns.values():
		var output_type = Properties.get_output_value_type(column, data.metadata)
		source += "@export var " + column.key + ": " + output_type + "\n"
	
	source += "\n\n"
	
	source += "func set_key(_value: String): key = _value\n"
	source += "func set_index(_value: int): index = _value\n"
	for column in sheet.columns.values():
		var input_type = Properties.get_input_value_type(column, data.metadata)
		var loader = Properties.get_output_value(column)
		source += "func set_" + column.key + "(_value: " + input_type + "): " + column.key + " = " + loader + "\n"
	
	return source


func get_source_loader():
	var sheet_ordered = data.get_sheets_ordered()
	
	var source = "# Auto generated by plugin GDData\n"
	source += "extends Node\n\n\n"
	source += "var _data: Dictionary\n\n\n"
	source += "func _ready():\n"
	source += "\t_data = GDDataLoader.new().load_data(\"" + data.path + "\", {\n"
	
	for sheet in sheet_ordered:
		source += "\t\t\"" + sheet.key + "\": " + data.metadata.sheets_file_name[sheet.key] + ",\n"
	
	source += "\t})\n\n"
	
	for sheet in sheet_ordered:
		source += "\n"
		source += "func " + sheet.key + "_get_value(key: String) -> " + data.metadata.sheets_file_name[sheet.key] + ": return _data." + sheet.key + ".values.get(key)\n"
		source += "func " + sheet.key + "_get_values() -> Array: return _data." + sheet.key + ".values.values()\n"
		source += "func " + sheet.key + "_get_keys() -> Array: return _data." + sheet.key + ".values.keys()\n"
		source += "func " + sheet.key + "_get_group(key: String) -> Array: return _data." + sheet.key + ".groups.get(key)\n"
	
	return source