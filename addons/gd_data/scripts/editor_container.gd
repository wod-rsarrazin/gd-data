@tool
extends VBoxContainer


@onready var editor_value_container: PanelContainer = %EditorValueContainer
@onready var editor_value_button: Button = %EditorValueButton
@onready var editor_code_edit: CodeEdit = %EditorCodeEdit
@onready var editor_code_button: Button = %EditorCodeButton
@onready var editor_set_default_button: Button = %EditorSetDefaultButton
@onready var editor_column_settings: HBoxContainer = %EditorColumnSettings

var editor_container: EditorContainer

var data: Data
var sheet: Sheet
var columns: Array
var lines: Array

var old_value
var new_value
var old_expression
var new_expression


func _ready():
	editor_code_edit.editable = false
	
	editor_set_default_button.icon = get_theme_icon("Clear", "EditorIcons")
	editor_set_default_button.tooltip_text = "Set cell value as default"
	
	editor_code_button.icon = get_theme_icon("Play", "EditorIcons")
	editor_code_button.visible = false
	editor_value_button.tooltip_text = "Update cell value"
	
	editor_value_button.icon = get_theme_icon("Play", "EditorIcons")
	editor_value_button.visible = false
	editor_value_button.tooltip_text = "Update cell value"


func on_selection_changed(_data: Data, _sheet: Sheet, _columns: Array, _lines: Array):
	data = _data
	sheet = _sheet
	columns = _columns
	lines = _lines
	
	clear()
	
	if sheet == null or columns.is_empty() or lines.is_empty():
		return
	
	if columns.size() > 1:
		on_multi_column_selected(columns, lines[0])
		get_parent().split_offset = 1000
	elif lines.size() >= 1:
		on_multi_line_selected(lines, columns[0])
	
	visible = true


func on_multi_column_selected(columns: Array, line: Line):
	editor_value_container.visible = false
	
	editor_set_default_button.pressed.connect(self.on_set_default_button_pressed)
	editor_set_default_button.disabled = false


func on_multi_line_selected(lines: Array, column: Column):
	var same_expressions = true
	
	var last_expression = sheet.expressions[lines[0].key][column.key]
	for i in range(1, lines.size()):
		if sheet.expressions[lines[i].key][column.key] != last_expression:
			same_expressions = false
	
	if same_expressions: # all selected cells have the same expression
		new_value = sheet.values[lines[0].key][column.key]
		new_expression = sheet.expressions[lines[0].key][column.key]
	else:
		var default_settings = Properties.get_settings(column.type)
		new_value = column.settings.value
		new_expression = column.settings.expression
	
	old_value = new_value
	old_expression = new_expression
	
	editor_container = Properties.get_control_editor(column.type)
	if editor_container != null:
		editor_container.data = data
		editor_container.sheet = sheet
		editor_container.column = column
		editor_container.lines = lines
		editor_container.init_value = new_value
		editor_container.value_changed.connect(self.on_editor_value_changed)
		editor_value_container.add_child(editor_container)
	
	editor_code_edit.editable = column.editable
	editor_code_edit.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	editor_code_edit.text = new_expression
	if not editor_code_edit.text_changed.is_connected(self.on_editor_code_changed):
		editor_code_edit.text_changed.connect(self.on_editor_code_changed)
	
	for column_observer in column.column_observers:
		var label = Label.new()
		label.theme_type_variation = "ChipLabel"
		label.text = column_observer
		editor_column_settings.add_child(label)
	
	editor_set_default_button.pressed.connect(self.on_set_default_button_pressed)
	editor_set_default_button.disabled = not column.editable
	
	editor_value_button.pressed.connect(self.on_value_button_pressed)
	editor_value_button.visible = column.editable
	editor_value_button.disabled = typeof(old_value) == typeof(new_value) and old_value == new_value
	
	editor_code_button.pressed.connect(self.on_code_button_pressed)
	editor_code_button.visible = column.editable
	editor_code_button.disabled = old_expression == new_expression
	
	editor_code_edit.visible = true
	editor_value_container.visible = true


func clear():
	if editor_set_default_button.pressed.is_connected(self.on_set_default_button_pressed):
		editor_set_default_button.pressed.disconnect(self.on_set_default_button_pressed)
	if editor_value_button.pressed.is_connected(self.on_value_button_pressed):
		editor_value_button.pressed.disconnect(self.on_value_button_pressed)
	if editor_code_button.pressed.is_connected(self.on_code_button_pressed):
		editor_code_button.pressed.disconnect(self.on_code_button_pressed)
	
	for node in editor_value_container.get_children():
		editor_value_container.remove_child(node)
		node.queue_free()
	
	for node in editor_column_settings.get_children():
		editor_column_settings.remove_child(node)
		node.queue_free()
	
	if editor_container != null:
		editor_container.queue_free()
	
	editor_code_edit.text = ""
	
	visible = false
	editor_code_edit.visible = false
	editor_code_button.visible = false
	editor_value_container.visible = false
	editor_value_button.visible = false
	
	old_value = null
	new_value = null
	old_expression = null
	new_expression = null


func on_editor_value_changed(_value):
	new_value = _value
	editor_value_button.disabled = typeof(old_value) == typeof(new_value) and old_value == new_value


func on_editor_code_changed():
	new_expression = editor_code_edit.text
	editor_code_button.disabled = old_expression == new_expression


func on_value_button_pressed():
	data.set_new_expression_from_value(sheet, lines, columns[0], new_value)
	after_expression_updated()


func on_code_button_pressed():
	if EvaluatorHelper.is_any_key_in_expression(new_expression):
		push_error("Cannot use values from cell editor")
		return
	
	data.set_new_expression(sheet, lines, columns[0], new_expression)
	after_expression_updated()


func on_set_default_button_pressed():
	data.set_default_expression(sheet, lines, columns)
	after_expression_updated()


func after_expression_updated():
	new_value = sheet.values[lines[0].key][columns[0].key]
	new_expression = sheet.expressions[lines[0].key][columns[0].key]
	old_value = new_value
	old_expression = new_expression
	
	editor_value_button.disabled = typeof(old_value) == typeof(new_value) and old_value == new_value
	editor_code_button.disabled = old_expression == new_expression
	
	editor_code_edit.text = new_expression
	if editor_container != null:
		editor_container.update_value_no_signal()
