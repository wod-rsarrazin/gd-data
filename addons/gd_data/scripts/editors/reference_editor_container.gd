@tool
extends EditorContainer


@onready var value_button: OptionButton = %ValueButton

var ref_line_keys: Array


func init_control():
	var ref_sheet = data.sheets[column.settings.sheet_key]
	ref_line_keys = data.get_lines_ordered(ref_sheet).map(func(x): return x.key)
	
	value_button.theme_type_variation = "EditorOptionButton"
	value_button.disabled = not column.editable
	value_button.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	value_button.item_selected.connect(self.on_value_changed)
	value_button.clear()
	for ref_line_key in ref_line_keys:
		value_button.add_item(ref_line_key)
	value_button.selected = ref_line_keys.find(init_value)


func on_value_changed(_value: int):
	value_changed.emit(ref_line_keys[_value])


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_button.selected = ref_line_keys.find(value)
