@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var filter_expression_edit: CodeEdit = %FilterExpressionEdit
@onready var ok_button: Button = get_ok_button()

var data: GDData
var sheet: GDSheet
var tag: GDTag

var key: String
var filter_expression: String

var evaluator: Evaluator = Evaluator.new()


signal button_create_pressed(key: String, filter_expression: String)
signal button_update_pressed(key: String, filter_expression: String)


func _ready():
	if tag != null: 
		ok_button_text = "Update"
		title = "Update tag"
		ok_button.pressed.connect(self.on_button_update_pressed)
		
		key = tag.key
		filter_expression = tag.filter_expression
	else:
		ok_button_text = "Create"
		title = "Create tag"
		ok_button.pressed.connect(self.on_button_create_pressed)
		
		key = ""
		filter_expression = "true"
	
	key_edit.text = key
	key_edit.text_changed.connect(self.on_key_text_changed)
	key_edit.caret_column = key.length()
	key_edit.grab_focus()
	
	filter_expression_edit.text = filter_expression


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if tag != null:
			on_button_update_pressed()
		else:
			on_button_create_pressed()


func on_key_text_changed(text: String):
	key = text


func on_button_create_pressed():
	var error_message = data.can_create_tag(sheet, key, filter_expression)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	filter_expression = filter_expression_edit.text
	
	button_create_pressed.emit(key, filter_expression)
	
	hide()


func on_button_update_pressed():
	var error_message = data.can_update_tag(sheet, tag, key, filter_expression)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	filter_expression = filter_expression_edit.text
	
	button_update_pressed.emit(key, filter_expression)
	
	hide()
