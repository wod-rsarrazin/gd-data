@tool
extends ConfirmationDialog


@onready var sheet_tree: Tree = %SheetTree
@onready var code_edit: CodeEdit = %CodeEdit
@onready var copy_button: Button = %CopyButton


var data: GDData
var selected_sheet: GDSheet


func _ready():
	remove_button(get_cancel_button())
	
	copy_button.pressed.connect(self.on_copy_button_pressed)
	
	sheet_tree.item_selected.connect(self.on_item_selected)
	
	var root = sheet_tree.create_item()
	
	var data_item = sheet_tree.create_item(root)
	data_item.set_text(0, "LOADER")
	data_item.set_metadata(0, "LOADER  ")
	data_item.set_custom_color(0, Color.WHITE)
	
	var sheet_ordered = data.get_sheets_ordered()
	for sheet in sheet_ordered:
		var item = sheet_tree.create_item(root)
		item.set_text(0, sheet.key)
		item.set_metadata(0, sheet.key)
		if selected_sheet == sheet:
			item.select(0)
	
	if sheet_tree.get_selected() == null:
		root.get_child(0).select(0)


func on_copy_button_pressed():
	code_edit.select_all()
	code_edit.copy()


func on_item_selected():
	var item = sheet_tree.get_selected()
	
	var metadata = item.get_metadata(0)
	if metadata == "LOADER  ":
		var source = get_source_data()
		code_edit.text = source
	else:
		var sheet = data.sheets[metadata]
		var source = get_source_sheet(sheet)
		code_edit.text = source


func get_source_sheet(sheet: GDSheet):
	var source = ""
	source += "extends Resource\n"
	source += "class_name " + sheet.cname + "\n\n\n"
	
	source += "@export var key: String\n"
	source += "@export var index: int\n"
	for column in sheet.columns.values():
		var output_type = Properties.get_output_value_type(column, data.sheets)
		source += "@export var " + column.key + ": " + output_type + "\n"
	
	source += "\n\n"
	
	source += "func set_key(_value: String): key = _value\n"
	source += "func set_index(_value: int): index = _value\n"
	for column in sheet.columns.values():
		var input_type = Properties.get_input_value_type(column, data.sheets)
		var loader = Properties.get_output_value(column)
		source += "func set_" + column.key + "(_value: " + input_type + "): " + column.key + " = " + loader + "\n"
	
	return source


func get_source_data():
	var sheet_ordered = data.get_sheets_ordered()
	
	var source = ""
	source += "extends Node\n\n\n"
	source += "var _data: Dictionary\n\n\n"
	source += "func _ready():\n"
	source += "\t_data = GDDataLoader.new().load_data(\"" + data.path + "\", {\n"
	
	for sheet in sheet_ordered:
		source += "\t\t\"" + sheet.key + "\": " + sheet.cname + ",\n"
	
	source += "\t})\n\n"
	
	for sheet in sheet_ordered:
		source += "\n"
		source += "func " + sheet.key + "_get_value(key: String) -> " + sheet.cname + ": return _data." + sheet.key + ".values.get(key)\n"
		source += "func " + sheet.key + "_get_values() -> Array: return _data." + sheet.key + ".values.values()\n"
		source += "func " + sheet.key + "_get_keys() -> Array: return _data." + sheet.key + ".values.keys()\n"
		source += "func " + sheet.key + "_get_group(key: String) -> Array: return _data." + sheet.key + ".groups.get(key)\n"
	
	return source
