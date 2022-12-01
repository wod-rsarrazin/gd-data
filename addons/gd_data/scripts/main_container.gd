@tool
extends VBoxContainer


@onready var import_button: Button = %ImportButton
@onready var export_button: Button = %ExportButton
@onready var project_path_label: Label = %ProjectPathLabel
@onready var autosave_button: CheckButton = %AutosaveButton
@onready var version_label: Label = %VersionLabel

@onready var project_container: HSplitContainer = %ProjectContainer

@onready var search_sheet_edit: LineEdit = %SearchSheetEdit
@onready var create_sheet_button: Button = %CreateSheetButton
@onready var remove_sheet_button: Button = %RemoveSheetButton
@onready var update_sheet_button: Button = %UpdateSheetButton

@onready var search_column_edit: LineEdit = %SearchColumnEdit
@onready var create_column_button: Button = %CreateColumnButton
@onready var remove_column_button: Button = %RemoveColumnButton
@onready var update_column_button: Button = %UpdateColumnButton

@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var create_line_button: Button = %CreateLineButton
@onready var remove_line_button: Button = %RemoveLineButton
@onready var update_line_button: Button = %UpdateLineButton

@onready var search_tag_edit: LineEdit = %SearchTagEdit
@onready var create_tag_button: Button = %CreateTagButton
@onready var remove_tag_button: Button = %RemoveTagButton
@onready var update_tag_button: Button = %UpdateTagButton

@onready var sheet_tree: Tree = %SheetTree
@onready var column_tree: Tree = %ColumnTree
@onready var line_tree: Tree = %LineTree
@onready var tag_tree: Tree = %TagTree

@onready var filter_expression_button: Button = %FilterExpressionButton
@onready var filter_expression_edit: CodeEdit = %FilterExpressionEdit
@onready var sheet_grid_drawer: SheetGridDrawer = %SheetGridDrawer
@onready var editor_container: VBoxContainer = %EditorContainer

@onready var selected_line_count_label: Label = %SelectedLineCountLabel
@onready var selected_column_count_label: Label = %SelectedColumnCountLabel


var data: Data = Data.new()
var plugin_version: String


func _ready():
	# menu
	import_button.pressed.connect(self.on_import_button_pressed)
	import_button.icon = get_theme_icon("New", "EditorIcons")
	export_button.pressed.connect(self.on_export_button_pressed)
	export_button.icon = get_theme_icon("Save", "EditorIcons")
	export_button.disabled = true
	
	# project
	project_container.visible = false
	version_label.text = "Version: " + plugin_version
	
	# sheets
	search_sheet_edit.text_changed.connect(self.on_search_sheet_text_changed)
	search_sheet_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	create_sheet_button.pressed.connect(self.on_create_sheet_button_pressed)
	create_sheet_button.icon = get_theme_icon("Add", "EditorIcons")
	create_sheet_button.tooltip_text = "Create new sheet"
	remove_sheet_button.pressed.connect(self.on_remove_sheet_button_pressed)
	remove_sheet_button.icon = get_theme_icon("Eraser", "EditorIcons")
	remove_sheet_button.tooltip_text = "Remove selected sheets"
	update_sheet_button.pressed.connect(self.on_update_sheet_button_pressed)
	update_sheet_button.icon = get_theme_icon("Edit", "EditorIcons")
	update_sheet_button.tooltip_text = "Update selected sheet"
	
	# columns
	search_column_edit.text_changed.connect(self.on_search_column_text_changed)
	search_column_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	create_column_button.pressed.connect(self.on_create_column_button_pressed)
	create_column_button.icon = get_theme_icon("Add", "EditorIcons")
	create_column_button.tooltip_text = "Create new column"
	remove_column_button.pressed.connect(self.on_remove_column_button_pressed)
	remove_column_button.icon = get_theme_icon("Eraser", "EditorIcons")
	remove_column_button.tooltip_text = "Remove selected columns"
	update_column_button.pressed.connect(self.on_update_column_button_pressed)
	update_column_button.icon = get_theme_icon("Edit", "EditorIcons")
	update_column_button.tooltip_text = "Update selected column"
	
	# lines
	search_line_edit.text_changed.connect(self.on_search_line_text_changed)
	search_line_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	create_line_button.pressed.connect(self.on_create_line_button_pressed)
	create_line_button.icon = get_theme_icon("Add", "EditorIcons")
	create_line_button.tooltip_text = "Create new line"
	remove_line_button.pressed.connect(self.on_remove_line_button_pressed)
	remove_line_button.icon = get_theme_icon("Eraser", "EditorIcons")
	remove_line_button.tooltip_text = "Remove selected lines"
	update_line_button.pressed.connect(self.on_update_line_button_pressed)
	update_line_button.icon = get_theme_icon("Edit", "EditorIcons")
	update_line_button.tooltip_text = "Update selected line"
	
	# tags
	search_tag_edit.text_changed.connect(self.on_search_tag_text_changed)
	search_tag_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	create_tag_button.pressed.connect(self.on_create_tag_button_pressed)
	create_tag_button.icon = get_theme_icon("Add", "EditorIcons")
	create_tag_button.tooltip_text = "Create new tag"
	remove_tag_button.pressed.connect(self.on_remove_tag_button_pressed)
	remove_tag_button.icon = get_theme_icon("Eraser", "EditorIcons")
	remove_tag_button.tooltip_text = "Remove selected tags"
	update_tag_button.pressed.connect(self.on_update_tag_button_pressed)
	update_tag_button.icon = get_theme_icon("Edit", "EditorIcons")
	update_tag_button.tooltip_text = "Update selected tag"
	
	# trees
	sheet_tree.select_mode = Tree.SELECT_MULTI
	sheet_tree.cell_moved.connect(self.on_sheet_moved)
	sheet_tree.cell_double_clicked.connect(self.on_item_sheet_double_clicked)
	sheet_tree.cell_selected.connect(self.on_sheet_selected)
	sheet_tree.hide_root = true
	sheet_tree.create_item()
	
	column_tree.select_mode = Tree.SELECT_MULTI
	column_tree.cell_moved.connect(self.on_column_moved)
	column_tree.cell_double_clicked.connect(self.on_item_column_double_clicked)
	column_tree.hide_root = true
	column_tree.columns = 3
	column_tree.set_column_expand(0, true)
	column_tree.set_column_expand(1, false)
	column_tree.set_column_expand(2, false)
	column_tree.create_item()
	
	line_tree.select_mode = Tree.SELECT_MULTI
	line_tree.cell_moved.connect(self.on_line_moved)
	line_tree.cell_double_clicked.connect(self.on_item_line_double_clicked)
	line_tree.hide_root = true
	line_tree.create_item()
	
	tag_tree.select_mode = Tree.SELECT_MULTI
	tag_tree.cell_moved.connect(self.on_tag_moved)
	tag_tree.cell_double_clicked.connect(self.on_item_tag_double_clicked)
	tag_tree.button_clicked.connect(self.on_tag_button_clicked)
	tag_tree.hide_root = true
	tag_tree.create_item()
	
	# grid
	filter_expression_button.pressed.connect(self.on_filter_expression_button_pressed)
	filter_expression_button.icon = get_theme_icon("Search", "EditorIcons")
	filter_expression_button.tooltip_text = "Search lines"
	
	sheet_grid_drawer.data = data
	sheet_grid_drawer.data_selection_changed.connect(self.on_cell_selection_changed)
	
	data.any_changed.connect(self.on_any_changed)


func _input(event):
	if not project_container.visible: return
	if export_button.disabled: return
	
	if event is InputEventKey:
		if event.pressed:
			match event.as_text():
				"Command+S": on_export_button_pressed()
				"Ctrl+S": on_export_button_pressed()


func on_any_changed():
	export_button.disabled = false
	
	if autosave_button.button_pressed:
		on_export_button_pressed()


func on_file_moved(old_file: String, new_file: String):
	data.on_file_moved(old_file, new_file)
	sheet_grid_drawer.clear_selection()


func on_file_removed(file: String):
	data.on_file_removed(file)
	sheet_grid_drawer.clear_selection()


func on_cell_selection_changed(sheet: Sheet, columns: Array, lines: Array):
	selected_line_count_label.text = "Lines: " + str(lines.size())
	selected_column_count_label.text = "Columns: " + str(columns.size())
	
	editor_container.on_selection_changed(data, sheet, columns, lines)


func on_import_button_pressed():
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.filters = PackedStringArray(["*.json"])
	dialog.file_selected.connect(self.on_file_selected)
	add_child(dialog)
	
	dialog.popup_centered_ratio(0.4)


func on_file_selected(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	
	var validated = false
	if content.length() == 0:
		validated = data.init_project(path)
	else:
		var json = JSON.parse_string(content)
		if json != null:
			validated = data.load_project(json, path)
	
	if validated:
		project_container.visible = true
		project_path_label.text = path
		init_sheet_tree()
	else:
		project_path_label.text = "Error while loading file: " + path


func on_export_button_pressed():
	data.save_project()
	export_button.disabled = true


func on_filter_expression_button_pressed():
	if filter_expression_edit.text.is_empty(): return
	sheet_grid_drawer.select_filter_items(filter_expression_edit.text.strip_escapes())


func init_sheet_tree():
	clear_all()
	
	var sheet_tree_root = sheet_tree.get_root()
	
	var sheets = data.get_sheets_ordered()
	for sheet in sheets:
		var item = sheet_tree.create_item(sheet_tree_root)
		item.set_metadata(0, sheet)
		item.set_text(0, sheet.key)
	
	if sheet_tree_root.get_child_count() > 0:
		sheet_tree_root.get_child(0).select(0)
		on_sheet_selected()
	
	export_button.disabled = true


func on_sheet_selected():
	clear()
	
	var selected_sheet_item = get_selected_sheet_item()
	if selected_sheet_item == null:  return
	
	var sheet = selected_sheet_item.get_metadata(0)
	var columns = data.get_columns_ordered(sheet)
	var lines = data.get_lines_ordered(sheet)
	var tags = data.get_tags_ordered(sheet)
	
	var column_root = column_tree.get_root()
	for column in columns:
		var item = column_tree.create_item(column_root)
		item.set_metadata(0, column)
		item.set_text(0, column.key)
		item.set_selectable(1, false)
		item.set_selectable(2, false)
		item.set_icon(2, Properties.get_icon(self, column))
		if not column.editable:
			item.set_icon(1, get_theme_icon("Lock", "EditorIcons"))
		else:
			item.set_icon(1, null)
	
	var line_root = line_tree.get_root()
	for line in lines:
		var item = line_tree.create_item(line_root)
		item.set_metadata(0, line)
		item.set_text(0, line.key)
	
	var tag_root = tag_tree.get_root()
	for tag in tags:
		var item = tag_tree.create_item(tag_root)
		item.set_metadata(0, tag)
		item.set_text(0, tag.key)
		item.add_button(0, get_theme_icon("GuiVisibilityVisible", "EditorIcons"))
	
	update_grid()


# CREATE SHEET
func on_create_sheet_button_pressed():
	var dialog = load("res://addons/gd_data/scenes/update_sheet_dialog.tscn").instantiate()
	dialog.button_create_pressed.connect(self.on_create_sheet_confirmed)
	dialog.data = data
	dialog.sheet = null
	add_child(dialog)
	
	dialog.popup_centered()


func on_create_sheet_confirmed(key: String):
	var result: UpdateResult = data.create_sheet(key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	var sheet = data.sheets[key]
	
	deselect_sheet_items()
	
	var root = sheet_tree.get_root()
	var item = sheet_tree.create_item(root)
	item.set_metadata(0, sheet)
	item.set_text(0, sheet.key)
	item.select(0)
	
	on_sheet_selected()


# UPDATE SHEET
func on_item_sheet_double_clicked(item: TreeItem, mouse_position: Vector2):
	on_update_sheet_button_pressed()


func on_update_sheet_button_pressed():
	var sheet_item = get_selected_sheet_item()
	if sheet_item == null: return

	var sheet = sheet_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_sheet_dialog.tscn").instantiate()
	dialog.button_update_pressed.connect(self.on_update_sheet_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	add_child(dialog)
	
	dialog.popup_centered()


func on_update_sheet_confirmed(new_key: String):
	var sheet_item = get_selected_sheet_item()
	var sheet = sheet_item.get_metadata(0)
	
	var result: UpdateResult = data.update_sheet(sheet, new_key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	sheet_item.set_text(0, new_key)


# REMOVE SHEET
func on_remove_sheet_button_pressed():
	var sheet_items = get_selected_sheet_items()
	if sheet_items.is_empty(): return
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Remove sheet"
	dialog.get_label().text = "Do you want to remove " + str(sheet_items.size()) + " sheet(s)"
	dialog.get_ok_button().text = "Remove"
	dialog.get_ok_button().pressed.connect(self.on_remove_sheet_confirmed)
	add_child(dialog)
	
	dialog.popup_centered()


func on_remove_sheet_confirmed():
	var sheet_items = get_selected_sheet_items()
	var sheets = sheet_items.map(func(x): return x.get_metadata(0))
	
	var result: UpdateResult = data.remove_sheets(sheets)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	for item in sheet_items:
		sheet_tree.get_root().remove_child(item)
	on_sheet_selected()


# MOVE SHEET
func on_sheet_moved(items_from: Array, item_to: TreeItem, shift: int):
	var sheets_from = items_from.map(func(x): return x.get_metadata(0))
	var sheet_to = item_to.get_metadata(0)
	
	var result: UpdateResult = data.move_sheets(sheets_from, sheet_to, shift)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	if item_to in items_from: return
	if shift == 1: items_from.reverse()
	for item_from in items_from:
		if shift == 1:
			item_from.move_after(item_to)
		elif shift == -1:
			item_from.move_before(item_to)


# SEARCH SHEET
func on_search_sheet_text_changed(text: String):
	for item in sheet_tree.get_root().get_children():
		var sheet: Sheet = item.get_metadata(0)
		if not text.is_empty() and text not in sheet.key:
			item.visible = false
		else:
			item.visible = true


# CREATE COLUMN
func on_create_column_button_pressed():
	var sheet_item = get_selected_sheet_item()
	if sheet_item == null: return

	var sheet = sheet_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_column_dialog.tscn").instantiate()
	dialog.button_create_pressed.connect(self.on_create_column_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.column = null
	add_child(dialog)
	
	dialog.popup_centered()


func on_create_column_confirmed(key: String, type: String, editable: bool, expression: String, settings: Dictionary):
	var sheet_item = get_selected_sheet_item()	
	var sheet = sheet_item.get_metadata(0)
	
	var result: UpdateResult = data.create_column(sheet, key, type, editable, expression, settings)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	var column: Column = sheet.columns[key]
	
	deselect_column_items()
	
	var root = column_tree.get_root()
	var item = column_tree.create_item(root)
	item.set_metadata(0, column)
	item.set_text(0, column.key)
	item.set_selectable(1, false)
	item.set_selectable(2, false)
	item.set_icon(2, Properties.get_icon(self, column))
	if not column.editable:
		item.set_icon(1, get_theme_icon("Lock", "EditorIcons"))
	else:
		item.set_icon(1, null)
	item.select(0)
	
	update_grid()


# UPDATE COLUMN
func on_item_column_double_clicked(item: TreeItem, mouse_position: Vector2):
	on_update_column_button_pressed()


func on_update_column_button_pressed():
	var sheet_item = get_selected_sheet_item()
	var column_item = get_selected_column_item()
	if column_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var column = column_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_column_dialog.tscn").instantiate()
	dialog.button_update_pressed.connect(self.on_update_column_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.column = column
	add_child(dialog)
	
	dialog.popup_centered()


func on_update_column_confirmed(key: String, type: String, editable: bool, expression: String, settings: Dictionary):
	var sheet_item = get_selected_sheet_item()
	var column_item = get_selected_column_item()
	
	var sheet = sheet_item.get_metadata(0)
	var column = column_item.get_metadata(0)
	
	var result: UpdateResult = data.update_column(sheet, column, key, type, editable, expression, settings)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	column_item.set_text(0, column.key)
	column_item.set_icon(2, Properties.get_icon(self, column))
	if not column.editable:
		column_item.set_icon(1, get_theme_icon("Lock", "EditorIcons"))
	else:
		column_item.set_icon(1, null)
	
	update_grid()


# REMOVE COLUMN
func on_remove_column_button_pressed():
	var column_items = get_selected_column_items()
	if column_items.is_empty(): return
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Remove column"
	dialog.get_label().text = "Do you want to remove " + str(column_items.size()) + " column(s)"
	dialog.get_ok_button().text = "Remove"
	dialog.get_ok_button().pressed.connect(self.on_remove_column_confirmed)
	add_child(dialog)
	
	dialog.popup_centered()


func on_remove_column_confirmed():
	var sheet_item = get_selected_sheet_item()
	var column_items = get_selected_column_items()
	
	var sheet = sheet_item.get_metadata(0)
	var columns = column_items.map(func(x): return x.get_metadata(0))
	
	var result: UpdateResult = data.remove_columns(sheet, columns)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	for item in column_items:
		column_tree.get_root().remove_child(item)

	update_grid()


# MOVE COLUMN
func on_column_moved(items_from: Array, item_to: TreeItem, shift: int):
	var sheet_item = get_selected_sheet_item()
	var sheet = sheet_item.get_metadata(0)
	
	var columns_from = items_from.map(func(x): return x.get_metadata(0))
	var column_to = item_to.get_metadata(0)
	
	var result: UpdateResult = data.move_columns(sheet, columns_from, column_to, shift)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	if item_to in items_from: return
	if shift == 1: items_from.reverse()
	for item_from in items_from:
		if shift == 1:
			item_from.move_after(item_to)
		elif shift == -1:
			item_from.move_before(item_to)
	
	update_grid()


# SEARCH COLUMN
func on_search_column_text_changed(text: String):
	for item in column_tree.get_root().get_children():
		var column = item.get_metadata(0)
		if not text.is_empty() and text not in column.key:
			item.visible = false
		else:
			item.visible = true


# CREATE LINE
func on_create_line_button_pressed():
	var sheet_item = get_selected_sheet_item()
	if sheet_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_line_dialog.tscn").instantiate()
	dialog.button_create_pressed.connect(self.on_create_line_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.line = null
	add_child(dialog)
	
	dialog.popup_centered()


func on_create_line_confirmed(key: String, count: int):
	var sheet_item = get_selected_sheet_item()
	var sheet = sheet_item.get_metadata(0)
	
	var result: UpdateResult = data.create_lines(sheet, key, count)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	deselect_line_items()
	
	for i in range(count):
		var line_key = key + ("" if count == 1 else str(i))
		var line = sheet.lines[line_key]
		
		var root = line_tree.get_root()
		var item = line_tree.create_item(root)
		item.set_metadata(0, line)
		item.set_text(0, line.key)
		item.select(0)
	
	update_grid()


# UPDATE LINE
func on_item_line_double_clicked(item: TreeItem, mouse_position: Vector2):
	on_update_line_button_pressed()


func on_update_line_button_pressed():
	var sheet_item = get_selected_sheet_item()
	var line_item = get_selected_line_item()
	if line_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var line = line_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_line_dialog.tscn").instantiate()
	dialog.button_update_pressed.connect(self.on_update_line_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.line = line
	add_child(dialog)
	
	dialog.popup_centered()


func on_update_line_confirmed(key: String, count: int):
	var sheet_item = get_selected_sheet_item()
	var line_item = get_selected_line_item()
	
	var sheet = sheet_item.get_metadata(0)
	var line = line_item.get_metadata(0)
	
	var result: UpdateResult = data.update_line(sheet, line, key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	line_item.set_text(0, key)
	
	update_grid()


# REMOVE LINE
func on_remove_line_button_pressed():
	var line_items = get_selected_line_items()
	if line_items.is_empty(): return
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Remove line"
	dialog.get_label().text = "Do you want to remove " + str(line_items.size()) + " line(s)"
	dialog.get_ok_button().text = "Remove"
	dialog.get_ok_button().pressed.connect(self.on_remove_line_confirmed)
	add_child(dialog)
	
	dialog.popup_centered()


func on_remove_line_confirmed():
	var sheet_item = get_selected_sheet_item()
	var line_items = get_selected_line_items()
	
	var sheet = sheet_item.get_metadata(0)
	var lines = line_items.map(func(x): return x.get_metadata(0))
	
	var result: UpdateResult = data.remove_lines(sheet, lines)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	for item in line_items:
		line_tree.get_root().remove_child(item)
	
	update_grid()


# MOVE LINE
func on_line_moved(items_from: Array, item_to: TreeItem, shift: int):
	var sheet_item = get_selected_sheet_item()
	var sheet = sheet_item.get_metadata(0)
	
	var lines_from = items_from.map(func(x): return x.get_metadata(0))
	var line_to = item_to.get_metadata(0)
	
	var result: UpdateResult = data.move_lines(sheet, lines_from, line_to, shift)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	if item_to in items_from: return
	if shift == 1: items_from.reverse()
	for item_from in items_from:
		if shift == 1:
			item_from.move_after(item_to)
		elif shift == -1:
			item_from.move_before(item_to)
	
	update_grid()


# SEARCH LINE
func on_search_line_text_changed(text: String):
	for item in line_tree.get_root().get_children():
		var line = item.get_metadata(0)
		if not text.is_empty() and text not in line.key:
			item.visible = false
		else:
			item.visible = true


# CREATE TAG
func on_create_tag_button_pressed():
	var sheet_item = get_selected_sheet_item()
	if sheet_item == null: return

	var sheet = sheet_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_tag_dialog.tscn").instantiate()
	dialog.button_create_pressed.connect(self.on_create_tag_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.tag = null
	add_child(dialog)
	
	dialog.popup_centered()


func on_create_tag_confirmed(key: String, filter_expression: String):
	var sheet_item = get_selected_sheet_item()
	var sheet = sheet_item.get_metadata(0)
	
	var result: UpdateResult = data.create_tag(sheet, key, filter_expression)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	var tag: Tag = sheet.tags[key]
	
	deselect_tag_items()
	
	var root = tag_tree.get_root()
	var item = tag_tree.create_item(root)
	item.set_metadata(0, tag)
	item.set_text(0, tag.key)
	item.add_button(0, get_theme_icon("GuiVisibilityVisible", "EditorIcons"))
	item.select(0)


# UPDATE TAG
func on_item_tag_double_clicked(item: TreeItem, mouse_position: Vector2):
	on_update_tag_button_pressed()


func on_update_tag_button_pressed():
	var sheet_item = get_selected_sheet_item()
	var tag_item = get_selected_tag_item()
	if tag_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var tag = tag_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/update_tag_dialog.tscn").instantiate()
	dialog.button_update_pressed.connect(self.on_update_tag_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.tag = tag
	add_child(dialog)
	
	dialog.popup_centered()


func on_update_tag_confirmed(key: String, filter_expression: String):
	var sheet_item = get_selected_sheet_item()
	var tag_item = get_selected_tag_item()
	
	var sheet = sheet_item.get_metadata(0)
	var tag = tag_item.get_metadata(0)
	
	var result: UpdateResult = data.update_tag(sheet, tag, key, filter_expression)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	tag_item.set_text(0, key)


# REMOVE TAG
func on_remove_tag_button_pressed():
	var tag_items = get_selected_tag_items()
	if tag_items.is_empty(): return
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Remove tag"
	dialog.get_label().text = "Do you want to remove " + str(tag_items.size()) + " tag(s)"
	dialog.get_ok_button().text = "Remove"
	dialog.get_ok_button().pressed.connect(self.on_remove_tag_confirmed)
	add_child(dialog)
	
	dialog.popup_centered()


func on_remove_tag_confirmed():
	var sheet_item = get_selected_sheet_item()
	var tag_items = get_selected_tag_items()
	
	var sheet = sheet_item.get_metadata(0)
	var tags = tag_items.map(func(x): return x.get_metadata(0))
	
	var result: UpdateResult = data.remove_tags(sheet, tags)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	for item in tag_items:
		tag_tree.get_root().remove_child(item)


# MOVE TAG
func on_tag_moved(items_from: Array, item_to: TreeItem, shift: int):
	var sheet_item = get_selected_sheet_item()
	var sheet = sheet_item.get_metadata(0)
	
	var tags_from = items_from.map(func(x): return x.get_metadata(0))
	var tag_to = item_to.get_metadata(0)
	
	var result: UpdateResult = data.move_tags(sheet, tags_from, tag_to, shift)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	if item_to in items_from: return
	if shift == 1: items_from.reverse()
	for item_from in items_from:
		if shift == 1:
			item_from.move_after(item_to)
		elif shift == -1:
			item_from.move_before(item_to)


# SEARCH TAG
func on_search_tag_text_changed(text: String):
	for item in tag_tree.get_root().get_children():
		var tag = item.get_metadata(0)
		if not text.is_empty() and text not in tag.key:
			item.visible = false
		else:
			item.visible = true


# OBSERVE TAG
func on_tag_button_clicked(item: TreeItem, col: int, id: int, mouse_button_index: int):
	var tag: Tag = item.get_metadata(0)
	sheet_grid_drawer.select_tag_items(tag)


# HELPER
func clear_all():
	sheet_tree.clear()
	sheet_tree.create_item()
	
	clear()


func clear():
	column_tree.clear()
	column_tree.create_item()
	
	line_tree.clear()
	line_tree.create_item()
	
	tag_tree.clear()
	tag_tree.create_item()
	
	sheet_grid_drawer.sheet = null
	sheet_grid_drawer.update_grid()
	
	editor_container.clear()
	filter_expression_edit.clear()


func update_grid():
	var selected_sheet_item = get_selected_sheet_item()
	sheet_grid_drawer.sheet = selected_sheet_item.get_metadata(0)
	sheet_grid_drawer.update_grid()
	editor_container.clear()


# GETTER
func get_selected_sheet_item():
	if sheet_tree.get_root().get_child_count() == 0: return null
	var selected_sheet_items = get_selected_sheet_items()
	if selected_sheet_items.is_empty(): return null
	var selected = selected_sheet_items[0]
	if selected.get_parent() == null: return null
	return selected


func get_selected_sheet_items():
	if sheet_tree.get_root().get_child_count() == 0: 
		return []
	return sheet_tree.get_selected_items()


func deselect_sheet_items():
	for sheet_item in get_selected_sheet_items():
		sheet_item.deselect(0)


func get_selected_column_item():
	if column_tree.get_root().get_child_count() == 0: return null
	var selected_column_items = get_selected_column_items()
	if selected_column_items.is_empty(): return null
	var selected = selected_column_items[0]
	if selected.get_parent() == null: return null
	return selected


func get_selected_column_items():
	if get_selected_sheet_item() == null: return []
	if column_tree.get_root().get_child_count() == 0: 
		return []
	return column_tree.get_selected_items()


func deselect_column_items():
	for column_item in get_selected_column_items():
		column_item.deselect(0)


func get_selected_line_item():
	if line_tree.get_root().get_child_count() == 0: return null
	var selected_line_items = get_selected_line_items()
	if selected_line_items.is_empty(): return null
	var selected = selected_line_items[0]
	if selected.get_parent() == null: return null
	return selected


func get_selected_line_items():
	if get_selected_sheet_item() == null: return []
	if line_tree.get_root().get_child_count() == 0: 
		return []
	return line_tree.get_selected_items()


func deselect_line_items():
	for line_item in get_selected_line_items():
		line_item.deselect(0)


func get_selected_tag_item():
	if tag_tree.get_root().get_child_count() == 0: return null
	var selected_tag_items = get_selected_tag_items()
	if selected_tag_items.is_empty(): return null
	var selected = selected_tag_items[0]
	if selected.get_parent() == null: return null
	return selected


func get_selected_tag_items():
	if get_selected_sheet_item() == null: return []
	if tag_tree.get_root().get_child_count() == 0: 
		return []
	return tag_tree.get_selected_items()


func deselect_tag_items():
	for tag_item in get_selected_tag_items():
		tag_item.deselect(0)
