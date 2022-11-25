@tool
extends Control


var nb_lines = 500
var nb_columns = 15
var cell_size = Vector2(160, 54)

var font: Font
var font_size: int
var icon_checked: Texture2D
var icon_unchecked: Texture2D
var color_grid: Color = Color.BLACK
var color_background: Color = Color.BLACK.lightened(0.15)

func _ready():
	font = get_theme_font("font")
	font_size = get_theme_font_size("font")
	icon_checked = get_theme_icon("GuiChecked", "EditorIcons")
	icon_unchecked = get_theme_icon("GuiUnchecked", "EditorIcons")
	
	custom_minimum_size = Vector2(
		cell_size.x * nb_columns,
		cell_size.y * nb_lines,
	)


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		queue_redraw()


func _draw():
	var start: float = Time.get_unix_time_from_system()
	
	var rect = Rect2(Vector2.ZERO, custom_minimum_size)
	
	# background
	draw_rect(rect, color_background)
	
	# cell
	for i in range(nb_lines):
		for j in range(nb_columns):
			var cell_pos = Vector2(j * cell_size.x, i * cell_size.y)
			var cell_rect = Rect2(cell_pos, cell_size)
			_draw_cell(cell_rect, i, j)
	
	# grid lines
	for i in range(nb_lines):
		var y = i * cell_size.y
		var from = Vector2(0, y)
		var to = Vector2(rect.size.x, y)
		draw_line(from, to, color_grid)
	
	# grid columns
	for i in range(nb_columns):
		var x = i * cell_size.x
		var from = Vector2(x, 0)
		var to = Vector2(x, rect.size.y)
		draw_line(from, to, color_grid)
	
	print(Time.get_unix_time_from_system() - start)


func _draw_cell(cell_rect: Rect2, grid_line_index: int, grid_column_index: int):
	if grid_column_index % 4 == 0:
		draw_text(cell_rect, "test")
	elif grid_column_index % 3 == 0:
		draw_curve(cell_rect)
	elif grid_column_index % 2 == 0:
		draw_icon(cell_rect, icon_checked)
	else:
		draw_rect_color(cell_rect, Color.WHEAT)


func draw_curve(cell_rect: Rect2):
	draw_line(cell_rect.position, cell_rect.position + cell_size, Color.BLACK)


func draw_rect_color(cell_rect: Rect2, color: Color, margin: int = 8):
	var rect_pos = cell_rect.position + Vector2(margin, margin)
	var rect_size = cell_size - Vector2(margin * 2, margin * 2)
	var rect = Rect2(rect_pos, rect_size)
	draw_rect(rect, color)


func draw_text(cell_rect: Rect2, text: String, space_left: int = 8):
	var font_height = font.get_height(font_size)
	var text_pos = Vector2(cell_rect.position.x + space_left, cell_rect.position.y + cell_size.y / 2 + font_size / 3)
	draw_string(font, text_pos, text, 0, -1, font_size)


func draw_icon(cell_rect: Rect2, icon: Texture2D, space_left: int = 8):
	var img_height = icon.get_height()
	var img_pos = Vector2(cell_rect.position.x + space_left, cell_rect.position.y + cell_size.y / 2 - img_height / 2)
	draw_texture(icon, img_pos)
