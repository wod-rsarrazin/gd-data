@tool
extends EditorContainer


@onready var value_texture_rect: TextureRect = %ValueTextureRect
@onready var value_label: Label = %ValueLabel


func init_control():
	update_control(init_value)


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
	if _data.type != "files": return false
	if _data.files.size() != 1: return false
	if not column.editable: return false
	var value = _data.files[0]
	var error_message = Properties.validate_value(_data.files[0], column.type, column.settings, data.sheets)
	return not value.is_empty() and error_message.is_empty()


func _drop_data(_position, _data):
	var value = _data.files[0]
	update_control(value)
	
	value_changed.emit(value)


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	update_control(value)


func update_control(path: String):
	if column.settings.file_type == "Image":
		var error_message = Properties.validate_value(path, column.type, column.settings, data.sheets)
		var texture_validated = not path.is_empty() and error_message.is_empty()
		value_texture_rect.texture = load(path) if texture_validated else null
	else:
		value_texture_rect.texture = null
	value_label.text = path
