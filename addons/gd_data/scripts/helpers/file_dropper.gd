@tool
extends PanelContainer
class_name FileDropper


var can_drop_file: Callable
var disabled: bool = false


signal file_dropped(file: String)


func _draw():
	var font = get_theme_font("font")
	var font_size = 30
	var color = Color(Color.LIGHT_GRAY, 0.1)
	var dash = 10
	var gap = 8
	
	var top_left = Vector2(gap, gap)
	var bottom_right = get_rect().size - Vector2(gap, gap)
	var top_right = Vector2(bottom_right.x, top_left.y)
	var bottom_left = Vector2(top_left.x, bottom_right.y)
	
	draw_dashed_line(top_left, top_right, color, 1, dash)
	draw_dashed_line(top_right, bottom_right, color, 1, dash)
	draw_dashed_line(bottom_right, bottom_left, color, 1, dash)
	draw_dashed_line(bottom_left, top_left, color, 1, dash)
	draw_dashed_line(top_left, bottom_right, color, 1, dash)
	draw_dashed_line(top_right, bottom_left, color, 1, dash)
	
	var text_bottom_right = Vector2(bottom_right)
	text_bottom_right.x -= font.get_string_size("Drag and Drop", 0, -1, font_size).x
	draw_string(font, text_bottom_right, "Drag and Drop", 0, -1, font_size, color)


func _can_drop_data(_position, _data):
	if disabled: return false
	if _data.type != "files": return false
	if _data.files.size() != 1: return false
	return can_drop_file.call(_data.files[0])


func _drop_data(_position, _data):
	file_dropped.emit(_data.files[0])
