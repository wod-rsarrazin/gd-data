@tool
extends ConfirmationDialog


@onready var key_edit: LineEdit = %KeyEdit
@onready var editable_checkbox: CheckBox = %EditableCheckBox
@onready var type_button: OptionButton = %TypeButton
@onready var expression_edit: CodeEdit = %ExpressionEdit
@onready var ok_button: Button = get_ok_button()

var data: GDData
var sheet: GDSheet
var column: GDColumn

var key: String
var type: String
var editable: bool
var expression: String

var evaluator: Evaluator = Evaluator.new()


signal button_create_pressed(key: String, type: String, editable: bool, expression: String)
signal button_update_pressed(key: String, type: String, editable: bool, expression: String)


func _ready():
	if column != null:
		ok_button_text = "Update"
		title = "Update column"
		ok_button.pressed.connect(self.on_button_update_pressed)
		
		key = column.key
		type = column.type
		editable = column.editable
		expression = column.expression
	else:
		ok_button_text = "Create"
		title = "Create column"
		ok_button.pressed.connect(self.on_button_create_pressed)
		
		key = ""
		type = "Text"
		editable = true
		expression = Properties.get_default_expression(type)
	
	key_edit.text = key
	key_edit.text_changed.connect(self.on_key_text_changed)
	key_edit.caret_column = key.length()
	key_edit.grab_focus()
	
	editable_checkbox.set_pressed_no_signal(editable)
	editable_checkbox.toggled.connect(self.on_editable_toggled)
	
	var type_index = Properties.TYPES.find(type)
	type_button.item_selected.connect(self.on_type_changed)
	type_button.clear()
	for type in Properties.TYPES:
		type_button.add_icon_item(Properties.get_icon(type_button, type), type)
	type_button.selected = type_index
	on_type_changed(type_index)


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if column != null:
			on_button_update_pressed()
		else:
			on_button_create_pressed()


func on_key_text_changed(text: String):
	key = text


func on_editable_toggled(_editable: bool):
	editable = _editable


func on_type_changed(value: int):
	type = Properties.TYPES[value]
	
	if column != null and column.type == type:
		expression = column.expression
	else:
		expression = Properties.get_default_expression(type)
	
	expression_edit.text = expression


func on_button_create_pressed():
	var values = Helper.get_values_from_columns(sheet)
	
	var value = evaluator.evaluate(expression_edit.text, values)
	if value == null:
		push_error("Error while evaluating expression: " + expression_edit.text)
		return
	
	expression = expression_edit.text
	
	var error_message = data.can_create_column(sheet, key, type, editable, expression)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_create_pressed.emit(key, type, editable, expression)
	
	hide()


func on_button_update_pressed():
	var values = Helper.get_values_from_columns(sheet)
	values.erase(column.key)
	
	var value = evaluator.evaluate(expression_edit.text, values)
	if value == null:
		push_error("Error while evaluating expression: " + expression_edit.text)
		return
	
	expression = expression_edit.text
	
	var error_message = data.can_update_column(sheet, column, key, type, editable, expression)
	if not error_message.is_empty():
		push_error(error_message)
		return
	
	button_update_pressed.emit(key, type, editable, expression)
	
	hide()
