@tool
extends EditorContainer
class_name FileEditorContainer


@onready var file_dropper: FileDropper = %FileDropper
@onready var texture_rect: TextureRect = %TextureRect


func init_control():
	file_dropper.theme_type_variation = "EditorFileDropper"
	file_dropper.disabled = not column.editable
	file_dropper.can_drop_file = self.can_drop_file
	file_dropper.file_dropped.connect(self.on_file_dropped)
	
	update_value_no_signal()


func can_drop_file(file: String):
	var error_message = Properties.validate_value(file, column.type, column.settings, data)
	return not file.is_empty() and error_message.is_empty()


func on_file_dropped(path: String):
	value_changed.emit(path)
	
	update_value_no_signal()


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	
	if value.split(".")[-1]:
		texture_rect.texture = get_theme_icon("File", "EditorIcons")
	else:
		texture_rect.texture = null
