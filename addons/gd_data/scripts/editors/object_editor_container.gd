@tool
extends EditorContainer


@onready var value_edit: CodeEdit = %ValueEdit
@onready var exec_button: Button = %ExecButton


func init_control():
	value_edit.editable = column.editable
	value_edit.text = JSON.stringify(init_value, "\t", false)
	value_edit.text_changed.connect(self.on_text_changed)
	
	exec_button.disabled = not column.editable
	exec_button.icon = get_theme_icon("Play", "EditorIcons")
	exec_button.pressed.connect(self.on_button_exec_pressed)
	
	on_text_changed()


func on_text_changed():
	var json = JSON.new()
	var error = json.parse(value_edit.text)
	if error == OK:
		exec_button.disabled = not column.editable or _to_str(init_value) == value_edit.text
	else:
		exec_button.disabled = true


func on_button_exec_pressed():
	init_value = _to_json(value_edit.text)
	on_text_changed()
	value_changed.emit(init_value)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_edit.text = JSON.stringify(value, "\t", false)


func _to_str(json):
	return JSON.stringify(json)


func _to_json(jsonStr: String):
	return JSON.parse_string(jsonStr)
