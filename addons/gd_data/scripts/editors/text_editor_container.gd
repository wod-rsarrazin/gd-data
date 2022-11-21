@tool
extends EditorContainer


@onready var value_edit: TextEdit = %ValueEdit


func init_control():
	value_edit.text = init_value
	value_edit.editable = column.editable
	value_edit.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	value_edit.text_changed.connect(self.on_value_changed)


func on_value_changed():
	var value = value_edit.text
	value_changed.emit(value)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_edit.text = value
