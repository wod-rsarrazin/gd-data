@tool
extends GridTree


var sheet_key: String

var data: Data
var sheet: Sheet
var columns_ordered: Array[Column]
var lines_ordered: Array[Line]

var evaluator: Evaluator = Evaluator.new()


signal data_selection_changed(sheet: Sheet, selected_columns: Array, selected_lines: Array)


func update_grid():
	if data.data_value_changed.is_connected(self.on_data_value_changed):
		data.data_value_changed.disconnect(self.on_data_value_changed)
	
	if sheet_key.is_empty():
		sheet = null
		columns_ordered = []
		lines_ordered = []
		
		clear_grid()
	else:
		sheet = data.sheets[sheet_key]
		columns_ordered = data.get_columns_ordered(sheet)
		lines_ordered = data.get_lines_ordered(sheet)
		
		data.data_value_changed.connect(self.on_data_value_changed)
		nb_grid_line = lines_ordered.size()
		nb_grid_column = columns_ordered.size() + 2
		columns = nb_grid_column
		build_grid()


func on_data_value_changed(sheet: Sheet, column: Column, line: Line):
	var grid_line_index = get_grid_line_index(line)
	var grid_column_index = get_grid_column_index(column)
	var item = get_root().get_child(grid_line_index)
	build_item(item, grid_line_index, grid_column_index)


func get_item_title(grid_column_index: int):
	if grid_column_index == 0:
		return "key"
	elif grid_column_index == 1:
		return "index"
	else:
		var column = get_column(grid_column_index)
		return column.key


func build_item(item: TreeItem, grid_line_index: int, grid_column_index: int):
	var line = get_line(grid_line_index)
	var cell = Vector2(grid_column_index, grid_line_index)
	
	if grid_column_index == 0:
		build_item_string(item, grid_column_index, line.key)
		update_item_color(item, cell.x, cell.y, cell in selected_cells, true)
	elif grid_column_index == 1:
		build_item_string(item, grid_column_index, str(line.index))
		update_item_color(item, cell.x, cell.y, cell in selected_cells, true)
	else:
		var column = get_column(grid_column_index)
		var type = column.type
		var value = sheet.values[line.key][column.key]
		Properties.build_grid_cell(self, item, grid_column_index, column, value)
		update_item_color(item, cell.x, cell.y, cell in selected_cells, not column.editable)


func selection_changed(selection: GridTreeSelection):
	var selected_lines = []
	var selected_columns = []
	
	for cell in selection.selected_cells:
		var line: Line = get_line(cell.y)
		var column: Column = get_column(cell.x)
		if line != null and line not in selected_lines: 
			selected_lines.append(line)
		if column != null and column not in selected_columns: 
			selected_columns.append(column)
		
		var item = get_root().get_child(cell.y)
		update_item_color(item, cell.x, cell.y, true, column == null or not column.editable)
	
	for cell in selection.not_selected_cells:
		var column: Column = get_column(cell.x)
		
		var item = get_root().get_child(cell.y)
		update_item_color(item, cell.x, cell.y, false, column == null or not column.editable)
	
	data_selection_changed.emit(sheet, selected_columns, selected_lines)


func select_filter_items(expression_filter: String):
	if sheet.lines.is_empty(): return
	
	var old_selected_cells = selected_cells.duplicate()
	_deselect_all()
	
	for line in sheet.lines.values():
		var grid_line_index = get_grid_line_index(line)
		var item = get_root().get_child(grid_line_index)
		
		var values = EvaluatorHelper.get_values_from_line(sheet, line)
		var value = evaluator.evaluate(expression_filter, values)
		if value == null: 
			push_error("Error while evaluating expression: " + expression_filter)
			break
		if not (value is bool):
			push_error("Filter expression must return a boolean value")
			break
		if value == true:
			_select_item(item)
	
	_on_selection_changed(old_selected_cells)


func select_tag_items(tag: Tag):
	var old_selected_cells = selected_cells.duplicate()
	_deselect_all()
	
	for line_key in sheet.groups[tag.key]:
		var line = sheet.lines[line_key]
		var grid_line_index = get_grid_line_index(line)
		var item = get_root().get_child(grid_line_index)
		_select_item(item)
	
	_on_selection_changed(old_selected_cells)


func clear_selection():
	var old_selected_cells = selected_cells.duplicate()
	_deselect_all()
	_on_selection_changed(old_selected_cells)


func get_line(grid_line_index: int) -> Line:
	return lines_ordered[grid_line_index]


func get_column(grid_column_index: int) -> Column:
	if grid_column_index < 2: return null
	return columns_ordered[grid_column_index - 2]


func get_grid_line_index(line: Line) -> int:
	return line.index


func get_grid_column_index(column: Column) -> int:
	return column.index + 2
