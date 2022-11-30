@tool
extends EditorContainer


@onready var value_checkbox: CheckBox = %ValueCheckBox


func init_control():
	value_checkbox.theme_type_variation = "EditorCheckBox"
	value_checkbox.disabled = not column.editable
	value_checkbox.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	value_checkbox.set_pressed_no_signal(init_value)
	value_checkbox.toggled.connect(self.on_value_changed)


func on_value_changed(_value: bool):
	value_changed.emit(_value)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_checkbox.set_pressed_no_signal(value)
