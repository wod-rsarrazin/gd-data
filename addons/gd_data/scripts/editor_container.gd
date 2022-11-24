@tool
extends VBoxContainer


@onready var editor_value_container: PanelContainer = %EditorValueContainer
@onready var editor_expression_edit: ExpressionEdit = %EditorExpressionEdit
@onready var editor_expression_button: Button = %EditorExpressionButton
@onready var editor_set_default_button: Button = %EditorSetDefaultButton

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
	editor_expression_edit.editable = false
	
	editor_set_default_button.icon = get_theme_icon("Clear", "EditorIcons")
	editor_set_default_button.tooltip_text = "Set cell value as default"
	
	editor_expression_button.icon = get_theme_icon("Play", "EditorIcons")
	editor_expression_button.visible = false


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
	
	editor_expression_edit.editable = column.editable
	editor_expression_edit.focus_mode = Control.FOCUS_CLICK if column.editable else Control.FOCUS_NONE
	editor_expression_edit.set_text(new_expression.replacen("\n", "\\n"))
	if not editor_expression_edit.text_changed.is_connected(self.on_editor_expression_changed):
		editor_expression_edit.text_changed.connect(self.on_editor_expression_changed)
	
	editor_set_default_button.pressed.connect(self.on_set_default_button_pressed)
	editor_set_default_button.disabled = not column.editable
	
	editor_expression_button.pressed.connect(self.on_expression_button_pressed)
	editor_expression_button.visible = column.editable
	editor_expression_button.disabled = old_expression == new_expression
	
	editor_expression_edit.visible = true
	editor_value_container.visible = true


func clear():
	if editor_set_default_button.pressed.is_connected(self.on_set_default_button_pressed):
		editor_set_default_button.pressed.disconnect(self.on_set_default_button_pressed)
	if editor_expression_button.pressed.is_connected(self.on_expression_button_pressed):
		editor_expression_button.pressed.disconnect(self.on_expression_button_pressed)
	
	for node in editor_value_container.get_children():
		editor_value_container.remove_child(node)
		node.queue_free()
	
	if editor_container != null:
		editor_container.queue_free()
	
	editor_expression_edit.set_text("")
	
	visible = false
	editor_expression_edit.visible = false
	editor_expression_button.visible = false
	editor_value_container.visible = false
	
	old_value = null
	new_value = null
	old_expression = null
	new_expression = null


func on_editor_value_changed(_value):
	new_value = _value
	data.set_new_expression_from_value(sheet, lines, columns[0], new_value)
	after_expression_updated()


func on_editor_expression_changed():
	new_expression = editor_expression_edit.text
	editor_expression_button.disabled = old_expression == new_expression


func on_expression_button_pressed():
	if Helper.is_any_key_in_expression(new_expression):
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
	
	editor_expression_button.disabled = old_expression == new_expression
	
	editor_expression_edit.set_text(new_expression.replacen("\n", "\\n"))
	if editor_container != null:
		editor_container.update_value_no_signal()
