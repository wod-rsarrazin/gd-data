@tool
extends EditorContainer


@onready var sheet_option_button: OptionButton = %SheetOptionButton
@onready var line_option_button: OptionButton = %LineOptionButton

var sheet_keys: Array
var line_keys: Array


func init_control():
	# sheet key
	sheet_keys = data.get_sheets_ordered().map(func(x): return x.key)
	sheet_keys.insert(0, "")
	
	sheet_option_button.theme_type_variation = "EditorOptionButton"
	sheet_option_button.disabled = not column.editable
	sheet_option_button.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	sheet_option_button.item_selected.connect(self.on_sheet_value_changed)
	
	sheet_option_button.clear()
	for sheet_key in sheet_keys:
		sheet_option_button.add_item(sheet_key)
	sheet_option_button.selected = sheet_keys.find(init_value.sheet_key)
	
	# line key
	line_option_button.theme_type_variation = "EditorOptionButton"
	line_option_button.disabled = not column.editable
	line_option_button.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	line_option_button.item_selected.connect(self.on_line_value_changed)
	
	var sheet_key = init_value.sheet_key
	update_line_option(sheet_key)
	line_option_button.selected = line_keys.find(init_value.line_key)


func on_sheet_value_changed(_value: int):
	var sheet_key = sheet_keys[_value]
	if sheet_key.is_empty():
		init_value.line_key = ""
	
	update_line_option(sheet_key)
	
	line_option_button.selected = line_keys.find(init_value.line_key)
	if init_value.line_key not in line_keys:
		init_value.line_key = ""
	
	init_value.sheet_key = sheet_keys[_value]
	value_changed.emit(init_value)


func on_line_value_changed(_value: int):
	init_value.line_key = line_keys[_value]
	value_changed.emit(init_value)


func update_line_option(sheet_key: String):
	line_option_button.clear()
	if sheet_key.is_empty():
		line_keys = []
		line_option_button.disabled = true
		return
	
	var sheet = data.sheets[sheet_key]
	line_keys = data.get_lines_ordered(sheet).map(func(x): return x.key)
	line_keys.insert(0, "")
	
	for line_key in line_keys:
		line_option_button.add_item(line_key)
	
	line_option_button.disabled = false


func update_value_no_signal():
	init_value = sheet.values[lines[0].key][column.key]
	sheet_option_button.selected = sheet_keys.find(init_value.sheet_key)
	line_option_button.selected = line_keys.find(init_value.line_key)
	
	update_line_option(init_value.sheet_key)
	
	line_option_button.selected = line_keys.find(init_value.line_key)
	if init_value.line_key not in line_keys:
		init_value.line_key = ""
