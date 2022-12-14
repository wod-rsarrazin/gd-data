@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var export_class_name_edit: LineEdit = %ExportClassNameEdit
@onready var ok_button: Button = get_ok_button()

var data: GDData
var sheet: GDSheet

var key: String
var export_class_name: String


signal button_create_pressed(key: String, export_class_name: String)
signal button_update_pressed(key: String, export_class_name: String)


func _ready():
	if sheet != null:
		ok_button_text = "Update"
		title = "Update sheet"
		ok_button.pressed.connect(self.on_button_update_pressed)
		
		key = sheet.key
		export_class_name = sheet.export_class_name
	else:
		ok_button_text = "Create"
		title = "Create sheet"
		ok_button.pressed.connect(self.on_button_create_pressed)
		
		key = ""
		export_class_name = ""
	
	key_edit.text = key
	key_edit.text_changed.connect(self.on_key_text_changed)
	key_edit.caret_column = key.length()
	key_edit.grab_focus()
	
	export_class_name_edit.text = export_class_name
	export_class_name_edit.text_changed.connect(self.on_export_class_name_text_changed)


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if sheet != null:
			on_button_update_pressed()
		else:
			on_button_create_pressed()


func on_key_text_changed(text: String):
	key = text


func on_export_class_name_text_changed(text: String):
	export_class_name = text


func on_button_create_pressed():
	var error_message = data.can_create_sheet(key, export_class_name)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_create_pressed.emit(key, export_class_name)
	hide()


func on_button_update_pressed():
	var error_message = data.can_update_sheet(sheet, key, export_class_name)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_update_pressed.emit(key, export_class_name)
	hide()
