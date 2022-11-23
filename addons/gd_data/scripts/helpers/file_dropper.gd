@tool
extends PanelContainer
class_name FileDropper


var image_rect: TextureRect
var path_label: Label

var path: String
var can_drop_file: Callable
var disabled: bool = false


signal file_dropped(file: String)


func _ready():
	image_rect = TextureRect.new()
	image_rect.ignore_texture_size = true
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_rect.size_flags_vertical = SIZE_EXPAND_FILL
	image_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(image_rect)
	
	path_label = Label.new()
	path_label.size_flags_vertical = SIZE_SHRINK_END
	add_child(path_label)
	
	update_path(path)


func _draw():
	var color = Color(Color.LIGHT_GRAY, 0.2)
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


func _can_drop_data(_position, _data):
	if disabled: return false
	if _data.type != "files": return false
	if _data.files.size() != 1: return false
	return can_drop_file.call(_data.files[0])


func _drop_data(_position, _data):
	update_path(_data.files[0])
	file_dropped.emit(_data.files[0])


func update_path(_path: String):
	path = _path
	
	if path.split(".")[-1] in Properties.FILE_TYPES["Image"]:
		image_rect.texture = load(path)
	else:
		image_rect.texture = null
	path_label.text = path
