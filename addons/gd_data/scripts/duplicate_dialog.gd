@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var ok_button: Button = get_ok_button()


var data: Data
var sheet: Sheet
var entity

var key: String


signal button_ok_pressed(key: String)


func _ready():
	ok_button_text = "Duplicate"
	title = "Duplicate"
	ok_button.pressed.connect(self.on_button_ok_pressed)
	
	key = entity.key
	
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
	var error_message = ""
	if entity is Sheet:
		error_message = data.can_duplicate_sheet(key)
	elif entity is Line:
		error_message = data.can_duplicate_line(sheet, key)
	elif entity is Column:
		error_message = data.can_duplicate_column(sheet, key)
	elif entity is Tag:
		error_message = data.can_duplicate_tag(sheet, key)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_ok_pressed.emit(key)
	hide()
