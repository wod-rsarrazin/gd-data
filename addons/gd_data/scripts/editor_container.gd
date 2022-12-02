@tool
extends VBoxContainer


@onready var editor_value_container: PanelContainer = %EditorValueContainer
@onready var raw_expression_edit: ExpressionEdit = %RawExpressionEdit
@onready var default_expression_edit: ExpressionEdit = %DefaultExpressionEdit
@onready var default_button: Button = %DefaultButton
@onready var editor_separator: HSeparator = %EditorSeparator

var editor_container: EditorContainer

var data: Data
var sheet: Sheet
var columns: Array
var lines: Array

var old_value
var new_value


func _ready():
	raw_expression_edit.editable = false
	default_expression_edit.editable = false
	
	default_button.icon = get_theme_icon("Clear", "EditorIcons")
	default_button.pressed.connect(self.on_set_default_button_pressed)


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
	# editor value
	for node in editor_value_container.get_children():
		editor_value_container.remove_child(node)
		node.queue_free()
	editor_value_container.visible = false
	
	# raw expression
	default_expression_edit.set_text("")
	default_expression_edit.visible = false
	
	# default expression
	default_expression_edit.set_text("")
	default_expression_edit.visible = false
	
	# separator
	editor_separator.visible = false
	
	# default button
	default_button.disabled = false


func on_multi_line_selected(lines: Array, column: Column):
	new_value = sheet.values[lines[0].key][column.key]
	old_value = new_value
	
	# editor value
	editor_container = Properties.get_control_editor(column.type)
	if editor_container != null:
		editor_container.data = data
		editor_container.sheet = sheet
		editor_container.column = column
		editor_container.lines = lines
		editor_container.init_value = new_value
		editor_container.value_changed.connect(self.on_editor_value_changed)
		editor_value_container.add_child(editor_container)
	editor_value_container.visible = true
	
	# raw expression
	var raw_expression = Properties.get_expression(column.type, new_value)
	raw_expression_edit.set_text(raw_expression)
	raw_expression_edit.visible = true
	
	# default expression
	default_expression_edit.set_text(column.expression)
	default_expression_edit.visible = true
	
	# separator
	editor_separator.visible = true
	
	# default button
	default_button.disabled = not column.editable


func clear():
	for node in editor_value_container.get_children():
		editor_value_container.remove_child(node)
		node.queue_free()
	
	raw_expression_edit.set_text("")
	default_expression_edit.set_text("")
	raw_expression_edit.visible = false
	default_expression_edit.visible = false
	editor_value_container.visible = false
	
	editor_container = null
	old_value = null
	new_value = null
	visible = false


func on_editor_value_changed(_value):
	data.update_values(sheet, lines, columns[0], _value)
	
	new_value = sheet.values[lines[0].key][columns[0].key]
	old_value = new_value
	editor_container.update_value_no_signal()
	
	var raw_expression = Properties.get_expression(columns[0].type, new_value)
	raw_expression_edit.set_text(raw_expression)


func on_set_default_button_pressed():
	data.update_values_as_default(sheet, lines, columns)
	
	new_value = sheet.values[lines[0].key][columns[0].key]
	old_value = new_value
	if editor_container != null:
		editor_container.update_value_no_signal()
	
	var raw_expression = Properties.get_expression(columns[0].type, new_value)
	raw_expression_edit.set_text(raw_expression)
