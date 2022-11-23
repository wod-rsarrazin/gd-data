@tool
extends EditorContainer


@onready var file_dropper: FileDropper = %FileDropper


func init_control():
	file_dropper.disabled = not column.editable
	file_dropper.can_drop_file = self.can_drop_file
	file_dropper.file_dropped.connect(self.on_file_dropped)
	file_dropper.update_path(init_value)


func can_drop_file(file: String):
	var error_message = Properties.validate_value(file, column.type, column.settings, data.sheets)
	return not file.is_empty() and error_message.is_empty()


func on_file_dropped(path: String):
	value_changed.emit(path)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	file_dropper.update_path(value)
