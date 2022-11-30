@tool
extends GridDrawer
class_name SheetGridDrawer


const CELL_SIZE: Vector2 = Vector2(160, 64)


var data: Data
var sheet: Sheet
var columns_ordered: Array[Column]
var lines_ordered: Array[Line]

var evaluator: Evaluator = Evaluator.new()


signal data_selection_changed(sheet: Sheet, selected_columns: Array, selected_lines: Array)


func update_grid():
	if not data.data_value_changed.is_connected(self.on_data_value_changed):
		data.data_value_changed.connect(self.on_data_value_changed)
	
	clear()
	
	if sheet == null:
		columns_ordered = []
		lines_ordered = []
	else:
		columns_ordered = data.get_columns_ordered(sheet)
		lines_ordered = data.get_lines_ordered(sheet)
		cell_count = Vector2(columns_ordered.size() + 2, lines_ordered.size() + 1)
		cell_title_count = Vector2(2, 1)
		cell_size = CELL_SIZE
		
		build()


func on_data_value_changed(sheet: Sheet, column: Column, line: Line):
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
		draw_text(cell_rect, "key")
	elif cell.x == 1:
		draw_text(cell_rect, "index")
	else:
		var column = get_column(cell)
		draw_text(cell_rect, column.key)


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
		Properties.build_grid_cell(self, cell_rect, column, value)


# override
func selection_changed(selection: GridDrawerSelection):
	var selected_lines = []
	var selected_columns = []
	
	for cell in selection.selected_cells:
		var line: Line = get_line(cell)
		var column: Column = get_column(cell)
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


func select_tag_items(tag: Tag):
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


func get_line(cell: Vector2) -> Line:
	return lines_ordered[cell.y - cell_title_count.y]


func get_column(cell: Vector2) -> Column:
	if cell.x < cell_title_count.x: return null
	return columns_ordered[cell.x - cell_title_count.x]


func get_grid_line_index(line: Line) -> int:
	return line.index + cell_title_count.y


func get_grid_column_index(column: Column) -> int:
	return column.index + cell_title_count.x
