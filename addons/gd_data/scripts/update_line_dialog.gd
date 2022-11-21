@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var count_container: HBoxContainer = %CountContainer
@onready var count_spinbox: SpinBox = %CountSpinBox
@onready var ok_button: Button = get_ok_button()

var data: Data
var sheet: Sheet
var line: Line

var key: String
var count: int = 1


signal button_create_pressed(key: String, count: int)
signal button_update_pressed(key: String, count: int)


func _ready():
	if line != null: 
		ok_button_text = "Update"
		title = "Update line"
		ok_button.pressed.connect(self.on_button_update_pressed)
		
		key = line.key
	else:
		ok_button_text = "Create"
		title = "Create line"
		ok_button.pressed.connect(self.on_button_create_pressed)
		
		key = ""
	
	key_edit.text = key
	key_edit.text_changed.connect(self.on_key_text_changed)
	key_edit.caret_column = key.length()
	key_edit.grab_focus()
	
	if line != null: 
		count_container.visible = false
	else:
		count_spinbox.value_changed.connect(self.on_count_value_changed)


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if line != null:
			on_button_update_pressed()
		else:
			on_button_create_pressed()


func on_key_text_changed(text: String):
	key = text


func on_count_value_changed(value: int):
	count = value


func on_button_create_pressed():
	var error_message = data.can_create_lines(sheet, key, count)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_create_pressed.emit(key, count)
	
	hide()


func on_button_update_pressed():
	var error_message = data.can_update_line(sheet, line, key)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_update_pressed.emit(key, count)
	
	hide()
