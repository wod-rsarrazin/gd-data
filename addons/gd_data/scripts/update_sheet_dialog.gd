@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var ok_button: Button = get_ok_button()

var data: GDData
var sheet: GDSheet

var key: String


signal button_create_pressed(key: String)
signal button_update_pressed(key: String)


func _ready():
	if sheet != null:
		ok_button_text = "Update"
		title = "Update sheet"
		ok_button.pressed.connect(self.on_button_update_pressed)
		
		key = sheet.key
	else:
		ok_button_text = "Create"
		title = "Create sheet"
		ok_button.pressed.connect(self.on_button_create_pressed)
		
		key = ""
	
	key_edit.text = key
	key_edit.text_changed.connect(self.on_key_text_changed)
	key_edit.caret_column = key.length()
	key_edit.grab_focus()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if sheet != null:
			on_button_update_pressed()
		else:
			on_button_create_pressed()


func on_key_text_changed(text: String):
	key = text


func on_button_create_pressed():
	var error_message = data.can_create_sheet(key)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_create_pressed.emit(key)
	hide()


func on_button_update_pressed():
	var error_message = data.can_update_sheet(sheet, key)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_update_pressed.emit(key)
	hide()
