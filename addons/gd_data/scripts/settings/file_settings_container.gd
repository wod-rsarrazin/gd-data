@tool
extends SettingsContainer


@onready var file_type_button: OptionButton = %FileTypeButton
@onready var path_begins_with_edit: LineEdit = %PathBeginsWithEdit
@onready var file_begins_with_edit: LineEdit = %FileBeginsWithEdit


func init_control():
	var file_type_index = Properties.FILE_TYPES.keys().find(settings.file_type)
	file_type_button.item_selected.connect(self.on_file_type_changed)
	file_type_button.clear()
	for index in range(Properties.FILE_TYPES.size()):
		var file_type = Properties.FILE_TYPES.keys()[index]
		var extensions = str(Properties.FILE_TYPES[file_type]).replacen("[", "").replacen("]", "").replacen("\"", "")
		file_type_button.add_item(file_type)
		file_type_button.set_item_tooltip(index, extensions)
		index += 1
	file_type_button.selected = file_type_index
	
	path_begins_with_edit.text = settings.path_begins_with
	path_begins_with_edit.text_changed.connect(self.on_path_begins_with_changed)
	
	file_begins_with_edit.text = settings.file_begins_with
	file_begins_with_edit.text_changed.connect(self.on_file_begins_with_changed)


func on_file_type_changed(_file_type_index: int):
	settings.file_type = Properties.FILE_TYPES.keys()[_file_type_index]
	
	settings_updated.emit(settings)


func on_path_begins_with_changed(_path_begins_with: String):
	settings.path_begins_with = _path_begins_with
	
	settings_updated.emit(settings)


func on_file_begins_with_changed(_file_begins_with: String):
	settings.file_begins_with = _file_begins_with
	
	settings_updated.emit(settings)
