@tool
extends EditorContainer


@onready var value_edit: CodeEdit = %ValueEdit


func init_control():
	value_edit.editable = column.editable
	value_edit.text = JSON.stringify(init_value, "\t", false)
	value_edit.text_changed.connect(self.on_value_changed)


func on_value_changed():
	var json = JSON.new()
	var error = json.parse(value_edit.text)
	if error == 0:
		value_changed.emit(json.data)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_edit.text = JSON.stringify(value, "\t", false)
