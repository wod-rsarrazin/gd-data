@tool
extends GridDrawer
class_name SheetGridDrawer


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
		cell_count = Vector2.ZERO
		cell_size = Vector2(160, 54)
		
		clear()
	else:
		sheet = data.sheets[sheet_key]
		columns_ordered = data.get_columns_ordered(sheet)
		lines_ordered = data.get_lines_ordered(sheet)
		
		data.data_value_changed.connect(self.on_data_value_changed)
		cell_count = Vector2(columns_ordered.size() + 2, lines_ordered.size() + 1)
		cell_size = Vector2(160, 54)
		
		build()


func on_data_value_changed(sheet: Sheet, column: Column, line: Line):
	build()


# override
func draw_cell(cell: Vector2, cell_rect: Rect2):
	if cell.y == 0:
		draw_cell_title(cell, cell_rect)
	else:
		draw_cell_value(cell, cell_rect)


func draw_cell_title(cell: Vector2, cell_rect: Rect2):
	var column = get_column(cell)
	
	draw_rect(cell_rect, color_disabled)
	if cell.x == 0:
		draw_text(cell_rect, "key")
	elif cell.x == 1:
		draw_text(cell_rect, "index")
	else:
		draw_text(cell_rect, column.key)


func draw_cell_value(cell: Vector2, cell_rect: Rect2):
	var line = get_line(cell)
	var column = get_column(cell)
	
	if cell.x == 0:
		draw_rect(cell_rect, color_disabled)
		draw_text(cell_rect, line.key)
	elif cell.x == 1:
		draw_rect(cell_rect, color_disabled)
		draw_text(cell_rect, str(line.index))
	else:
		var value = sheet.values[line.key][column.key]
		
		match column.type:
			"Text":
				draw_text(cell_rect, value.replacen("\n", "\\n"))
			"Number":
				draw_text(cell_rect, str(value))
			"Bool":
				draw_check(cell_rect, value)
			"Color":
				draw_rect_color(cell_rect, value, 12)
			"File":
				if not value.is_empty() and column.settings.file_type == "Image":
					draw_icon(cell_rect, load(value))
				else:
					draw_text(cell_rect, value.split("/")[-1])
			"Reference":
				draw_text(cell_rect, value)
			"Object":
				draw_text(cell_rect, JSON.stringify(value, "", false))
			"Region":
				pass
			_: push_error("Type '" + column.type + "' must be handled")


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
	pass


func select_tag_items(tag: Tag):
	pass


func clear_selection():
	pass


func get_line(cell: Vector2) -> Line:
	return lines_ordered[cell.y - 1]


func get_column(cell: Vector2) -> Column:
	if cell.x < 2: return null
	return columns_ordered[cell.x - 2]
