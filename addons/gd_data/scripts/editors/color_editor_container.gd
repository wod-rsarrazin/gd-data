@tool
extends EditorContainer


@onready var value_button: ColorPickerButton = %ValueButton


func init_control():
	value_button.disabled = not column.editable
	value_button.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	value_button.color = Color(init_value)
	value_button.color_changed.connect(self.on_value_changed)


func on_value_changed(_value: Color):
	value_changed.emit(_value.to_html())


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_button.color = Color(value)
