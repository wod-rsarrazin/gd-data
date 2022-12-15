@tool
extends EditorContainer


@onready var value_spinbox: SpinBox = %ValueSpinBox
@onready var value_spinbox_edit: LineEdit = value_spinbox.get_line_edit()


func init_control():
	theme_type_variation = "DarkPanelContainer"
	
	value_spinbox.editable = column.editable
	value_spinbox.value = init_value
	value_spinbox.value_changed.connect(self.on_value_changed)
	
	value_spinbox_edit.theme_type_variation = "EditorLineEdit"
	value_spinbox_edit.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE


func on_value_changed(_value: float):
	value_changed.emit(_value)


func update_value_no_signal():
	value_spinbox.value_changed.disconnect(self.on_value_changed)
	
	var value = sheet.values[lines[0].key][column.key]
	value_spinbox.value = value
	
	value_spinbox.value_changed.connect(self.on_value_changed)
