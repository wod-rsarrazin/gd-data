@tool
extends Control
class_name GridDrawer


# params
@export var cell_size = Vector2.ZERO
@export var cell_count = Vector2.ZERO

# internal
var selected_cells = {}
var pressed_cell = null
var texture_cache = {}

# theme
var font: Font
var font_size: int
var icon_checked: Texture2D
var icon_unchecked: Texture2D
var color_grid: Color
var color_background: Color
var color_selected: Color
var color_disabled: Color


func _ready():
	font = get_theme_font("font")
	font_size = get_theme_font_size("font")
	icon_checked = get_theme_icon("GuiChecked", "EditorIcons")
	icon_unchecked = get_theme_icon("GuiUnchecked", "EditorIcons")
	color_grid = get_theme_color("grid", "GridDrawer")
	color_background = get_theme_color("background", "GridDrawer")
	color_selected = get_theme_color("selected", "GridDrawer")
	color_disabled = get_theme_color("disabled", "GridDrawer")


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell = _get_cell(event.position)
		
		var old_selected_cells = selected_cells.duplicate()
		if event.shift_pressed and pressed_cell != null:
			_on_shift_pressed(cell)
			_on_selection_changed(old_selected_cells)
		elif not event.shift_pressed:
			_on_pressed(cell)
			_on_selection_changed(old_selected_cells)


func _on_pressed(cell: Vector2):
	pressed_cell = null
	
	var must_select_cell = cell not in selected_cells or selected_cells.size() > 1
	_deselect_all()
	if must_select_cell:
		_select_cell(cell)
		pressed_cell = cell


func _on_shift_pressed(cell: Vector2):
	_deselect_all()
	_select_square(pressed_cell, cell)


func _deselect_all():
	selected_cells.clear()


func _select_cell(cell: Vector2):
	selected_cells[cell] = ""


func _select_square(cell_from: Vector2, cell_to: Vector2):
	var x_min = min(cell_from.x, cell_to.x)
	var y_min = min(cell_from.y, cell_to.y)
	var x_max = max(cell_from.x, cell_to.x)
	var y_max = max(cell_from.y, cell_to.y)
	
	for i in range(x_min, x_max + 1):
		for j in range(y_min, y_max + 1):
			_select_cell(Vector2(i, j))


func _on_selection_changed(old_selected_cells: Dictionary):
	var list_selected_cells = selected_cells.keys()
	var list_not_selected_cells = old_selected_cells.keys().filter(func(x): return not selected_cells.has(x))
	
	var selection = GridDrawerSelection.new()
	selection.selected_cells = list_selected_cells
	selection.not_selected_cells = list_not_selected_cells
	selection_changed(selection)
	
	queue_redraw()


func _draw():
	var start: float = Time.get_unix_time_from_system()
	
	var rect = Rect2(Vector2.ZERO, custom_minimum_size)
	
	# background
	draw_rect(rect, color_background)
	
	# selected cell
	for selected_cell in selected_cells:
		var rect_selected = _get_cell_rect(selected_cell)
		draw_rect(rect_selected, color_selected)
	
	# cell
	for y in range(cell_count.y):
		for x in range(cell_count.x):
			var cell = Vector2(x, y)
			var cell_pos = Vector2(x * cell_size.x, y * cell_size.y)
			var cell_rect = Rect2(cell_pos, cell_size)
			draw_cell(cell, cell_rect)
	
	# grid lines
	for y in range(cell_count.y):
		var cell_pos_y = y * cell_size.y
		var from = Vector2(0, cell_pos_y)
		var to = Vector2(rect.size.x, cell_pos_y)
		draw_line(from, to, color_grid)
	
	# grid columns
	for x in range(cell_count.x):
		var cell_pos_x = x * cell_size.x
		var from = Vector2(cell_pos_x, 0)
		var to = Vector2(cell_pos_x, rect.size.y)
		draw_line(from, to, color_grid)
	
	print(Time.get_unix_time_from_system() - start)


func _get_cell(mouse_position: Vector2):
	var cell_x = floor(mouse_position.x / cell_size.x)
	var cell_y = floor(mouse_position.y / cell_size.y)
	return Vector2(cell_x, cell_y)


func _get_cell_rect(cell: Vector2):
	var x = cell.x * cell_size.x
	var y = cell.y * cell_size.y
	return Rect2(Vector2(x, y), cell_size)


func build():
	custom_minimum_size = Vector2(cell_size.x * cell_count.x, cell_size.y * cell_count.y)
	queue_redraw()


func clear():
	custom_minimum_size = Vector2.ZERO
	selected_cells.clear()
	pressed_cell = null
	cell_count = Vector2.ZERO
	build()


func draw_cell(cell: Vector2, cell_rect: Rect2):
	pass


func selection_changed(selection: GridDrawerSelection):
	pass


func draw_rect_margin(cell_rect: Rect2, color: Color, margin: int = 8):
	var rect_pos = cell_rect.position + Vector2(margin, margin)
	var rect_size = cell_size - Vector2(margin * 2, margin * 2)
	var rect = Rect2(rect_pos, rect_size)
	draw_rect(rect, color)


func draw_text(cell_rect: Rect2, text: String, space_left: int = 8):
	var font_height = font.get_height(font_size)
	var text_pos = Vector2(cell_rect.position.x + space_left, cell_rect.position.y + cell_size.y / 2 - font_height / 2)
	
	var text_line = TextLine.new()
	text_line.width = cell_size.x - space_left
	text_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text_line.add_string(text, font, font_size)
	text_line.draw(get_canvas_item(), text_pos, Color.LIGHT_GRAY)


func draw_check(cell_rect: Rect2, checked: bool, space_left: int = 8):
	var icon = icon_checked if checked else icon_unchecked
	var img_height = icon.get_height()
	var img_pos = Vector2(cell_rect.position.x + space_left, cell_rect.position.y + cell_size.y / 2 - img_height / 2)
	draw_texture(icon, img_pos)


func draw_image(cell_rect: Rect2, image_path: String, space_left: int = 8):
	var image: Texture2D = _get_image(image_path)
	if image == null: return
	
	var image_size = Vector2(image.get_width(), image.get_height())
	var rect = _get_image_rect(cell_rect, image_size, space_left)
	
	draw_texture_rect(image, rect, false)


func draw_image_region(cell_rect: Rect2, image_path: String, horizontal: int, vertical: int, frame: int = 0, sx: int = 0, sy: int = 0, ox: int = 0, oy: int = 0, space_left: int = 8):
	var image: Texture2D = _get_image(image_path)
	if image == null: return
	
	var region_rect = Helper.get_region_rect(image, frame, horizontal, vertical, sx, sy, ox, oy)
	var rect = _get_image_rect(cell_rect, region_rect.size, space_left)
	
	draw_texture_rect_region(image, rect, region_rect)


func _get_image(image_path: String):
	if texture_cache.has(image_path):
		return texture_cache[image_path]
	else:
		var texture = load(image_path)
		if texture == null: return null
		texture_cache[image_path] = texture
		return texture


func _get_image_rect(cell_rect: Rect2, image_size: Vector2, space_left: int):
	var img_height = min(image_size.y, cell_rect.size.y)
	var img_width = img_height * image_size.x / image_size.y
	if img_width > cell_rect.size.x - space_left:
		space_left = 0
		img_width = cell_rect.size.x
		img_height = img_width * image_size.y / image_size.x
	
	var img_pos = Vector2(cell_rect.position.x + space_left, cell_rect.position.y + cell_rect.size.y / 2 - img_height / 2)
	var img_size = Vector2(img_width, img_height)
	return Rect2(img_pos, img_size)
