@tool
extends VBoxContainer


@onready var import_button: Button = %ImportButton
@onready var export_button: Button = %ExportButton
@onready var project_path_label: Label = %ProjectPathLabel
@onready var autosave_button: CheckButton = %AutosaveButton
@onready var version_label: Label = %VersionLabel

@onready var project_container: HSplitContainer = %ProjectContainer

@onready var search_sheet_edit: LineEdit = %SearchSheetEdit
@onready var option_sheet_button: MenuButton = %OptionSheetButton
@onready var create_sheet_button: Button = %CreateSheetButton

@onready var search_column_edit: LineEdit = %SearchColumnEdit
@onready var option_column_button: MenuButton = %OptionColumnButton
@onready var create_column_button: Button = %CreateColumnButton

@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var option_line_button: MenuButton = %OptionLineButton
@onready var create_line_button: Button = %CreateLineButton

@onready var search_tag_edit: LineEdit = %SearchTagEdit
@onready var option_tag_button: MenuButton = %OptionTagButton
@onready var create_tag_button: Button = %CreateTagButton

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


var data: GDData = GDData.new()
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
	
	option_sheet_button.icon = get_theme_icon("GuiTabMenuHl", "EditorIcons")
	option_sheet_button.get_popup().clear()
	option_sheet_button.get_popup().add_icon_item(get_theme_icon("Add", "EditorIcons"), "Create")
	option_sheet_button.get_popup().add_icon_item(get_theme_icon("Duplicate", "EditorIcons"), "Duplicate")
	option_sheet_button.get_popup().add_icon_item(get_theme_icon("Edit", "EditorIcons"), "Update")
	option_sheet_button.get_popup().add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Remove")
	option_sheet_button.get_popup().index_pressed.connect(self.on_option_sheet_button_pressed)
	
	create_sheet_button.pressed.connect(self.on_create_sheet_button_pressed)
	create_sheet_button.icon = get_theme_icon("Add", "EditorIcons")
	create_sheet_button.tooltip_text = "Create new sheet"
	
	# columns
	search_column_edit.text_changed.connect(self.on_search_column_text_changed)
	search_column_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	
	option_column_button.icon = get_theme_icon("GuiTabMenuHl", "EditorIcons")
	option_column_button.get_popup().clear()
	option_column_button.get_popup().add_icon_item(get_theme_icon("Add", "EditorIcons"), "Create")
	option_column_button.get_popup().add_icon_item(get_theme_icon("Duplicate", "EditorIcons"), "Duplicate")
	option_column_button.get_popup().add_icon_item(get_theme_icon("Edit", "EditorIcons"), "Update")
	option_column_button.get_popup().add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Remove")
	option_column_button.get_popup().index_pressed.connect(self.on_option_column_button_pressed)
	
	create_column_button.pressed.connect(self.on_create_column_button_pressed)
	create_column_button.icon = get_theme_icon("Add", "EditorIcons")
	create_column_button.tooltip_text = "Create new column"
	
	# lines
	search_line_edit.text_changed.connect(self.on_search_line_text_changed)
	search_line_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	
	option_line_button.icon = get_theme_icon("GuiTabMenuHl", "EditorIcons")
	option_line_button.get_popup().clear()
	option_line_button.get_popup().add_icon_item(get_theme_icon("Add", "EditorIcons"), "Create")
	option_line_button.get_popup().add_icon_item(get_theme_icon("Duplicate", "EditorIcons"), "Duplicate")
	option_line_button.get_popup().add_icon_item(get_theme_icon("Edit", "EditorIcons"), "Update")
	option_line_button.get_popup().add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Remove")
	option_line_button.get_popup().index_pressed.connect(self.on_option_line_button_pressed)
	
	create_line_button.pressed.connect(self.on_create_line_button_pressed)
	create_line_button.icon = get_theme_icon("Add", "EditorIcons")
	create_line_button.tooltip_text = "Create new line"
	
	# tags
	search_tag_edit.text_changed.connect(self.on_search_tag_text_changed)
	search_tag_edit.right_icon = get_theme_icon("Search", "EditorIcons")
	
	option_tag_button.icon = get_theme_icon("GuiTabMenuHl", "EditorIcons")
	option_tag_button.get_popup().clear()
	option_tag_button.get_popup().add_icon_item(get_theme_icon("Add", "EditorIcons"), "Create")
	option_tag_button.get_popup().add_icon_item(get_theme_icon("Duplicate", "EditorIcons"), "Duplicate")
	option_tag_button.get_popup().add_icon_item(get_theme_icon("Edit", "EditorIcons"), "Update")
	option_tag_button.get_popup().add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Remove")
	option_tag_button.get_popup().index_pressed.connect(self.on_option_tag_button_pressed)
	
	create_tag_button.pressed.connect(self.on_create_tag_button_pressed)
	create_tag_button.icon = get_theme_icon("Add", "EditorIcons")
	create_tag_button.tooltip_text = "Create new tag"
	
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


func on_cell_selection_changed(sheet: GDSheet, columns: Array, lines: Array):
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
		create_sheet_item(sheet)
	
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
	
	for column in columns:
		create_column_item(column)
	for line in lines:
		create_line_item(line)
	for tag in tags:
		create_tag_item(tag)
	
	update_grid()


# OPTION SHEET
func on_option_sheet_button_pressed(index: int):
	match index:
		0: on_create_sheet_button_pressed()
		1: on_duplicate_sheet_button_pressed()
		2: on_update_sheet_button_pressed()
		3: on_remove_sheet_button_pressed()


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
	
	var item = create_sheet_item(sheet)
	item.select(0)
	
	on_sheet_selected()


# DUPLICATE SHEET
func on_duplicate_sheet_button_pressed():
	var sheet_item = get_selected_sheet_item()
	if sheet_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/duplicate_dialog.tscn").instantiate()
	dialog.button_ok_pressed.connect(self.on_duplicate_sheet_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.entity = sheet
	add_child(dialog)
	
	dialog.popup_centered()


func on_duplicate_sheet_confirmed(key: String):
	var sheet_item = get_selected_sheet_item()
	var duplicated_sheet = sheet_item.get_metadata(0)
	
	var result: UpdateResult = data.duplicate_sheet(duplicated_sheet, key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	deselect_sheet_items()
	
	var sheet: GDSheet = data.sheets[key]
	var item = create_sheet_item(sheet)
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
	
	update_sheet_item(sheet_item, sheet)


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
		var sheet: GDSheet = item.get_metadata(0)
		if not text.is_empty() and text not in sheet.key:
			item.visible = false
		else:
			item.visible = true


# OPTION COLUMN
func on_option_column_button_pressed(index: int):
	match index:
		0: on_create_column_button_pressed()
		1: on_duplicate_column_button_pressed()
		2: on_update_column_button_pressed()
		3: on_remove_column_button_pressed()


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


func on_create_column_confirmed(key: String, type: String, editable: bool, expression: String):
	var sheet_item = get_selected_sheet_item()	
	var sheet = sheet_item.get_metadata(0)
	
	var result: UpdateResult = data.create_column(sheet, key, type, editable, expression)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	var column: GDColumn = sheet.columns[key]
	
	deselect_column_items()
	
	var item = create_column_item(column)
	item.select(0)
	
	update_grid()


# DUPLICATE COLUMN
func on_duplicate_column_button_pressed():
	var sheet_item = get_selected_sheet_item()
	var column_item = get_selected_column_item()
	if column_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var column = column_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/duplicate_dialog.tscn").instantiate()
	dialog.button_ok_pressed.connect(self.on_duplicate_column_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.entity = column
	add_child(dialog)
	
	dialog.popup_centered()


func on_duplicate_column_confirmed(key: String):
	var sheet_item = get_selected_sheet_item()
	var column_item = get_selected_column_item()
	if column_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var duplicated_column = column_item.get_metadata(0)
	
	var result: UpdateResult = data.duplicate_column(sheet, duplicated_column, key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	deselect_column_items()
	
	var column: GDColumn = sheet.columns[key]
	var item = create_column_item(column)
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


func on_update_column_confirmed(key: String, type: String, editable: bool, expression: String):
	var sheet_item = get_selected_sheet_item()
	var column_item = get_selected_column_item()
	
	var sheet = sheet_item.get_metadata(0)
	var column = column_item.get_metadata(0)
	
	var result: UpdateResult = data.update_column(sheet, column, key, type, editable, expression)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	update_column_item(column_item, column)
	
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


# OPTION LINE
func on_option_line_button_pressed(index: int):
	match index:
		0: on_create_line_button_pressed()
		1: on_duplicate_line_button_pressed()
		2: on_update_line_button_pressed()
		3: on_remove_line_button_pressed()


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
		
		var item = create_line_item(line)
		item.select(0)
	
	update_grid()


# DUPLICATE LINE
func on_duplicate_line_button_pressed():
	var sheet_item = get_selected_sheet_item()
	var line_item = get_selected_line_item()
	if line_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var line = line_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/duplicate_dialog.tscn").instantiate()
	dialog.button_ok_pressed.connect(self.on_duplicate_line_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.entity = line
	add_child(dialog)
	
	dialog.popup_centered()


func on_duplicate_line_confirmed(key: String):
	var sheet_item = get_selected_sheet_item()
	var line_item = get_selected_line_item()
	if line_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var duplicated_line = line_item.get_metadata(0)
	
	var result: UpdateResult = data.duplicate_line(sheet, duplicated_line, key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	deselect_line_items()
	
	var line: GDLine = sheet.lines[key]
	var item = create_line_item(line)
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
	
	update_line_item(line_item, line)
	
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


# OPTION TAG
func on_option_tag_button_pressed(index: int):
	match index:
		0: on_create_tag_button_pressed()
		1: on_duplicate_tag_button_pressed()
		2: on_update_tag_button_pressed()
		3: on_remove_tag_button_pressed()


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
	
	var tag: GDTag = sheet.tags[key]
	
	deselect_tag_items()
	
	var item = create_tag_item(tag)
	item.select(0)


# DUPLICATE TAG
func on_duplicate_tag_button_pressed():
	var sheet_item = get_selected_sheet_item()
	var tag_item = get_selected_tag_item()
	if tag_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var tag = tag_item.get_metadata(0)
	
	var dialog = load("res://addons/gd_data/scenes/duplicate_dialog.tscn").instantiate()
	dialog.button_ok_pressed.connect(self.on_duplicate_tag_confirmed)
	dialog.data = data
	dialog.sheet = sheet
	dialog.entity = tag
	add_child(dialog)
	
	dialog.popup_centered()


func on_duplicate_tag_confirmed(key: String):
	var sheet_item = get_selected_sheet_item()
	var tag_item = get_selected_tag_item()
	if tag_item == null: return
	
	var sheet = sheet_item.get_metadata(0)
	var duplicated_tag = tag_item.get_metadata(0)
	
	var result: UpdateResult = data.duplicate_tag(sheet, duplicated_tag, key)
	if result.is_ko():
		push_error(result.message)
		return
	elif result.is_none():
		return
	
	deselect_tag_items()
	
	var tag: GDTag = sheet.tags[key]
	var item = create_tag_item(tag)
	item.select(0)
	
	update_grid()


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
	
	update_tag_item(tag_item, tag)


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
	var tag: GDTag = item.get_metadata(0)
	sheet_grid_drawer.select_tag_items(tag)


# HELPER
func create_sheet_item(sheet: GDSheet):
	var root = sheet_tree.get_root()
	var item = sheet_tree.create_item(root)
	item.set_metadata(0, sheet)
	item.set_text(0, sheet.key)
	return item


func update_sheet_item(item: TreeItem, sheet: GDSheet):
	item.set_text(0, sheet.key)


func create_column_item(column: GDColumn):
	var root = column_tree.get_root()
	var item = column_tree.create_item(root)
	item.set_metadata(0, column)
	item.set_selectable(1, false)
	item.set_selectable(2, false)
	item.set_text(0, column.key)
	item.set_icon(2, Properties.get_icon(self, column.type))
	if not column.editable:
		item.set_icon(1, get_theme_icon("Lock", "EditorIcons"))
	else:
		item.set_icon(1, null)
	return item


func update_column_item(item: TreeItem, column: GDColumn):
	item.set_text(0, column.key)
	item.set_icon(2, Properties.get_icon(self, column.type))
	if not column.editable:
		item.set_icon(1, get_theme_icon("Lock", "EditorIcons"))
	else:
		item.set_icon(1, null)


func create_line_item(line: GDLine):
	var root = line_tree.get_root()
	var item = line_tree.create_item(root)
	item.set_metadata(0, line)
	item.set_text(0, line.key)
	return item


func update_line_item(item: TreeItem, line: GDLine):
	item.set_text(0, line.key)


func create_tag_item(tag: GDTag):
	var root = tag_tree.get_root()
	var item = tag_tree.create_item(root)
	item.set_metadata(0, tag)
	item.add_button(0, get_theme_icon("GuiVisibilityVisible", "EditorIcons"))
	item.set_text(0, tag.key)
	return item


func update_tag_item(item: TreeItem, tag: GDTag):
	item.set_text(0, tag.key)


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
