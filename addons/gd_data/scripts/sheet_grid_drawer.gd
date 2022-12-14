@tool
extends GridDrawer
class_name SheetGridDrawer


const CELL_SIZE: Vector2 = Vector2(200, 64)


var data: GDData
var sheet: GDSheet
var columns_ordered: Array[GDColumn]
var lines_ordered: Array[GDLine]

var evaluator: Evaluator = Evaluator.new()


signal data_selection_changed(sheet: GDSheet, selected_columns: Array, selected_lines: Array)


func update_grid():
	if not data.values_changed.is_connected(self.on_values_changed):
		data.values_changed.connect(self.on_values_changed)
	
	clear()
	
	if sheet == null:
		columns_ordered = []
		lines_ordered = []
	else:
		columns_ordered = data.get_columns_ordered(sheet)
		lines_ordered = data.get_lines_ordered(sheet)
		cell_count = Vector2(columns_ordered.size() + 2, lines_ordered.size() + 1)
		cell_title_count = Vector2(2, 1)
		if cell_size == Vector2.ZERO:
			cell_size = CELL_SIZE
		
		build()


func on_values_changed():
	queue_redraw()


# override
func draw_cell(cell: Vector2, cell_rect: Rect2):
	if cell.y == 0:
		draw_cell_title(cell, cell_rect)
	else:
		draw_cell_value(cell, cell_rect)


func draw_cell_title(cell: Vector2, cell_rect: Rect2):
	draw_rect(cell_rect, color_disabled)
	if cell.x == 0:
		var icon = get_theme_icon("Key", "EditorIcons")
		draw_icon_text(cell_rect, icon, "key")
	elif cell.x == 1:
		var icon = get_theme_icon("ArrowDown", "EditorIcons")
		draw_icon_text(cell_rect, icon, "index")
	else:
		var column = get_column(cell)
		var icon = Properties.get_icon(self, column.type)
		draw_icon_text(cell_rect, icon, column.key)


func draw_cell_value(cell: Vector2, cell_rect: Rect2):
	var line = get_line(cell)
	
	if cell.x == 0:
		draw_rect(cell_rect, color_disabled)
		draw_text(cell_rect, line.key)
	elif cell.x == 1:
		draw_rect(cell_rect, color_disabled)
		draw_text(cell_rect, str(line.index))
	else:
		var column = get_column(cell)
		var value = sheet.values[line.key][column.key]
		
		if not column.editable:
			draw_texture_rect(
				get_theme_icon("Close", "EditorIcons"),
				cell_rect, true, Color(1, 1, 1, 0.02)
			)
		
		Properties.build_grid_cell(self, cell_rect, column, value)


# override
func selection_changed(selection: GridDrawerSelection):
	var selected_lines = []
	var selected_columns = []
	
	for cell in selection.selected_cells:
		var line: GDLine = get_line(cell)
		var column: GDColumn = get_column(cell)
		if line != null and line not in selected_lines: 
			selected_lines.append(line)
		if column != null and column not in selected_columns: 
			selected_columns.append(column)
	
	data_selection_changed.emit(sheet, selected_columns, selected_lines)


func select_filter_items(expression_filter: String):
	if sheet.lines.is_empty(): return
	
	var old_selected_cells = selected_cells.duplicate()
	_deselect_all()
	
	for line in sheet.lines.values():
		var grid_line_index = get_grid_line_index(line)
		
		var values = Helper.get_values_from_line(sheet, line)
		var value = evaluator.evaluate(expression_filter, values)
		if value == null: 
			push_error("Error while evaluating expression: " + expression_filter)
			break
		if not (value is bool):
			push_error("Filter expression must return a boolean value")
			break
		if value == true:
			_select_line(grid_line_index)
	
	_on_selection_changed(old_selected_cells)


func select_tag_items(tag: GDTag):
	var old_selected_cells = selected_cells.duplicate()
	_deselect_all()
	
	for line_key in sheet.groups[tag.key]:
		var line = sheet.lines[line_key]
		var grid_line_index = get_grid_line_index(line)
		_select_line(grid_line_index)
	
	_on_selection_changed(old_selected_cells)


func clear_selection():
	var old_selected_cells = selected_cells.duplicate()
	_deselect_all()
	_on_selection_changed(old_selected_cells)


func decrease_size_column():
	cell_size.x = clamp(cell_size.x - 25, 150, 400)
	custom_minimum_size = Vector2(cell_size.x * cell_count.x, cell_size.y * cell_count.y)
	
	queue_redraw()


func increase_size_column():
	cell_size.x = clamp(cell_size.x + 25, 150, 400)
	custom_minimum_size = Vector2(cell_size.x * cell_count.x, cell_size.y * cell_count.y)
	
	queue_redraw()


func get_line(cell: Vector2) -> GDLine:
	return lines_ordered[cell.y - cell_title_count.y]


func get_column(cell: Vector2) -> GDColumn:
	if cell.x < cell_title_count.x: return null
	return columns_ordered[cell.x - cell_title_count.x]


func get_grid_line_index(line: GDLine) -> int:
	return line.index + cell_title_count.y


func get_grid_column_index(column: GDColumn) -> int:
	return column.index + cell_title_count.x
