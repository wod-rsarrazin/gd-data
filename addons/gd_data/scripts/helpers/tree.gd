@tool
extends Tree


signal cell_double_clicked(item: TreeItem, mouse_position: Vector2)
signal cell_moved(items_from: Array, item_to: TreeItem, shift: int)


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.double_click:
			var item = get_item_at_position(event.position)
			if item != null:
				cell_double_clicked.emit(item, event.global_position)


func _get_drag_data(position: Vector2):
	set_drop_mode_flags(DROP_MODE_INBETWEEN)
	
	var drag_items = get_selected_items()
	var item = get_item_at_position(position)
	if not item in drag_items:
		drag_items = [item]
	
	var text = ""
	for i in range(drag_items.size()):
		if i > 0: text += ", " + drag_items[i].get_text(0)
		else: text += drag_items[i].get_text(0)
	
	var preview = Label.new()
	preview.text = text
	set_drag_preview(preview)
	
	return drag_items


func _can_drop_data(position: Vector2, data):
	var is_array = data is Array
	if not is_array or data.is_empty(): return false
	for item in data:
		if not item in get_root().get_children():
			return false
	return true


func _drop_data(position: Vector2, items):
	var item_to = get_item_at_position(position)
	if item_to == null: return
	var shift = get_drop_section_at_position(position)
	cell_moved.emit(items, item_to, shift)


func get_selected_items(deselected_item: TreeItem = null):
	var selected_items = []
	var selected_item = get_next_selected(null)
	while selected_item:
		if selected_item != deselected_item:
			selected_items.append(selected_item)
		selected_item = get_next_selected(selected_item)
	return selected_items
