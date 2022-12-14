@tool
extends EditorContainer


@onready var value_edit: TextEdit = %ValueEdit
@onready var exec_button: Button = %ExecButton


func init_control():
	value_edit.theme_type_variation = "EditorTextEdit"
	value_edit.text = init_value
	value_edit.editable = column.editable
	value_edit.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	value_edit.text_changed.connect(self.on_text_changed)
	
	exec_button.disabled = not column.editable
	exec_button.icon = get_theme_icon("Play", "EditorIcons")
	exec_button.pressed.connect(self.on_button_exec_pressed)
	
	on_text_changed()


func on_text_changed():
	exec_button.disabled = not column.editable or init_value == value_edit.text


func on_button_exec_pressed():
	init_value = value_edit.text
	on_text_changed()
	value_changed.emit(init_value)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_edit.text = value
