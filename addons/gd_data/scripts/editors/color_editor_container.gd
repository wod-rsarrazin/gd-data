@tool
extends EditorContainer


@onready var value_button: ColorPickerButton = %ValueButton
@onready var exec_button: Button = %ExecButton


func init_control():
	value_button.disabled = not column.editable
	value_button.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	value_button.color = Color(init_value)
	value_button.color_changed.connect(self.on_color_changed)
	
	exec_button.disabled = not column.editable
	exec_button.icon = get_theme_icon("Play", "EditorIcons")
	exec_button.pressed.connect(self.on_button_exec_pressed)
	
	on_color_changed(init_value)


func on_color_changed(_value: Color):
	exec_button.disabled = not column.editable or init_value == _value.to_html(true)


func on_button_exec_pressed():
	init_value = value_button.color.to_html()
	on_color_changed(init_value)
	value_changed.emit(init_value)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	value_button.color = Color(value)
