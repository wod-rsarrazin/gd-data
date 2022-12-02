@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var ok_button: Button = get_ok_button()


var key: String
var existing_keys: Array


signal button_ok_pressed(key: String)


func _ready():
	ok_button_text = "Duplicate"
	title = "Duplicate"
	ok_button.pressed.connect(self.on_button_ok_pressed)
	
	key_edit.text = key
	key_edit.text_changed.connect(self.on_key_text_changed)
	key_edit.caret_column = key.length()
	key_edit.grab_focus()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		on_button_ok_pressed()


func on_key_text_changed(text: String):
	key = text


func on_button_ok_pressed():
	if key in existing_keys:
		push_error("Key '" + key + "' already exists")
		return
	
	button_ok_pressed.emit(key)
	hide()
