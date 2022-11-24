@tool
extends Tree
class_name GridTree


const ITEM_MIN_WIDTH = 150
const ITEM_MIN_HEIGHT = 54

var plugin_theme: Theme

var nb_grid_line = 1
var nb_grid_column = 1

var selected_cells: Array = []
var pressed_cell = null


func _ready():
	theme_type_variation = "GridTree"
	column_titles_visible = true
	plugin_theme = _get_plugin_theme(self)


func _draw():
	if plugin_theme == null: return
	
	var rect = get_rect()
	var scroll = get_scroll()
	var color = plugin_theme.get_color("grid_line", "GridTree")
	
	for i in range(nb_grid_column):
		var x = (i + 1) * ITEM_MIN_WIDTH - scroll.x
		var from = Vector2(x, ITEM_MIN_HEIGHT)
		var to = Vector2(x, rect.size.y)
		draw_line(from, to, color)
	
	for i in range(nb_grid_line):
		var y = (i + 2) * ITEM_MIN_HEIGHT - scroll.y
		if y > ITEM_MIN_HEIGHT:
			var from = Vector2(0, y)
			var to = Vector2(nb_grid_column * ITEM_MIN_WIDTH, y)
			draw_line(from, to, color)


func build_grid():
	clear_grid()
	
	var root = create_item()
	
	for grid_column_index in range(nb_grid_column):
		set_column_title(grid_column_index, get_item_title(grid_column_index))
		set_column_custom_minimum_width(grid_column_index, ITEM_MIN_WIDTH)
		set_column_expand(grid_column_index, false)
	
	for grid_line_index in range(nb_grid_line):
		var item = create_item(root)
		item.custom_minimum_height = ITEM_MIN_HEIGHT
		
		for grid_column_index in range(nb_grid_column):
			item.set_selectable(grid_column_index, false)
			build_item(item, grid_line_index, grid_column_index)


func clear_grid():
	clear()
	_deselect_all()
	pressed_cell = null


func build_item(item: TreeItem, grid_line_index: int, grid_column_index: int):
	pass


func get_item_title(grid_column_index: int):
	pass


func selection_changed(selection: GridTreeSelection):
	pass


func build_item_string(item: TreeItem, grid_column_index: int, value: String):
	item.set_suffix(grid_column_index, value.replacen("\n", "\\n"))


func build_item_number(item: TreeItem, grid_column_index: int, value: float):
	item.set_suffix(grid_column_index, str(value))


func build_item_bool(item: TreeItem, grid_column_index: int, value: bool):
	item.set_cell_mode(grid_column_index, TreeItem.CELL_MODE_CHECK)
	item.set_checked(grid_column_index, value)


func build_item_color(item: TreeItem, grid_column_index: int, color: Color):
	item.set_icon(grid_column_index, preload("res://addons/gd_data/assets/color.svg"))
	item.set_icon_modulate(grid_column_index, color)


func build_item_file(item: TreeItem, grid_column_index: int, path: String, is_image: bool):
	if is_image and not path.is_empty():
		var texture = load(path)
		
		var width = texture.get_width()
		var height = texture.get_height()
		
		var icon_max_width = width \
			if height <= item.custom_minimum_height \
			else float(width) * (float(item.custom_minimum_height) / float(height))
		
		item.set_icon(grid_column_index, texture)
		item.set_icon_max_width(grid_column_index, icon_max_width)
		
	else:
		var formatted_path = path.split("/")[-1]
		item.set_suffix(grid_column_index, formatted_path)


func build_item_reference(item: TreeItem, grid_column_index: int, value: String):
	item.set_suffix(grid_column_index, value)


func build_item_object(item: TreeItem, grid_column_index: int, object):
	item.set_suffix(grid_column_index, JSON.stringify(object, "", false))


func build_item_region(item: TreeItem, grid_column_index: int, region: Dictionary):
	if not region.texture.is_empty():
		var texture = load(region.texture)
		
		var width = texture.get_width()
		var height = texture.get_height()
		var rect = Helper.get_region_rect(width, height, region.frame, region.hor, region.ver, region.sx, region.sy, region.ox, region.oy)
		
		var icon_max_width = rect.size.x \
			if height <= item.custom_minimum_height \
			else float(rect.size.x) * (float(item.custom_minimum_height) / float(rect.size.y))
		
		item.set_icon(grid_column_index, texture)
		item.set_icon_max_width(grid_column_index, icon_max_width)
		item.set_icon_region(grid_column_index, rect)


func set_normal_color(item: TreeItem, grid_column_index: int, grid_line_index: int):
	var color = plugin_theme.get_color("cell_normal", "GridTree")
	item.set_custom_bg_color(grid_column_index, color, false)


func set_selected_color(item: TreeItem, grid_column_index: int, grid_line_index: int):
	var color = plugin_theme.get_color("cell_selected", "GridTree")
	item.set_custom_bg_color(grid_column_index, color, false)


func set_disabled_color(item: TreeItem, grid_column_index: int, grid_line_index: int):
	var color = plugin_theme.get_color("cell_disabled", "GridTree")
	item.set_custom_bg_color(grid_column_index, color, false)


func set_linked_color(item: TreeItem, grid_column_index: int, grid_line_index: int):
	var color = plugin_theme.get_color("cell_linked", "GridTree")
	item.set_custom_bg_color(grid_column_index, color, false)


# override
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var item = get_item_at_position(event.position)
		if item == null: return
		
		var grid_column_index = get_column_at_position(event.position)
		var grid_line_index = item.get_index()
		
		var old_selected_cells = selected_cells.duplicate()
		if event.shift_pressed and pressed_cell != null:
			_on_shift_pressed(item, grid_line_index, grid_column_index)
			_on_selection_changed(old_selected_cells)
		elif not event.shift_pressed:
			_on_pressed(item, grid_line_index, grid_column_index)
			_on_selection_changed(old_selected_cells)


func _on_pressed(item: TreeItem, grid_line_index: int, grid_column_index: int):
	var cell = Vector2(grid_column_index, grid_line_index)
	
	pressed_cell = null
	
	var must_select_cell = cell not in selected_cells or selected_cells.size() > 1
	_deselect_all()
	if must_select_cell:
		_select_cell(cell)
		pressed_cell = cell


func _on_shift_pressed(item: TreeItem, grid_line_index: int, grid_column_index: int):
	var cell = Vector2(grid_column_index, grid_line_index)
	
	_deselect_all()
	_select_square(pressed_cell, cell)


func _on_selection_changed(old_selected_cells: Array):
	var not_selected_cells = old_selected_cells.filter(func(x): return selected_cells.find(x) == -1)
	
	var selection = GridTreeSelection.new()
	selection.selected_cells = selected_cells
	selection.not_selected_cells = not_selected_cells
	selection_changed(selection)


func _deselect_all():
	selected_cells.clear()


func _select_cell(cell: Vector2):
	if cell in selected_cells: return
	selected_cells.append(cell)


func _select_square(cell_from: Vector2, cell_to: Vector2):
	var x_min = min(cell_from.x, cell_to.x)
	var y_min = min(cell_from.y, cell_to.y)
	var x_max = max(cell_from.x, cell_to.x)
	var y_max = max(cell_from.y, cell_to.y)
	
	for i in range(x_min, x_max + 1):
		for j in range(y_min, y_max + 1):
			_select_cell(Vector2(i, j))


func _select_item(item: TreeItem):
	var cell_from = Vector2(0, item.get_index())
	var cell_to = Vector2(nb_grid_column - 1, item.get_index())
	_select_square(cell_from, cell_to)


func _get_plugin_theme(control):
	var theme = null
	while control != null && "theme" in control:
		theme = control.theme
		if theme != null: break
		control = control.get_parent()
	return theme
