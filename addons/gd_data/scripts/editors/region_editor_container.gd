@tool
extends EditorContainer


@onready var frame_spinbox: SpinBox = %FrameSpinBox
@onready var horizontal_spinbox: SpinBox = %HorizontalSpinBox
@onready var vertical_spinbox: SpinBox = %VerticalSpinBox
@onready var offset_x_spinbox: SpinBox = %OffsetXSpinBox
@onready var offset_y_spinbox: SpinBox = %OffsetYSpinBox
@onready var separation_x_spinbox: SpinBox = %SeparationXSpinBox
@onready var separation_y_spinbox: SpinBox = %SeparationYSpinBox
@onready var file_dropper: FileDropper = %FileDropper
@onready var preview_rect: TextureRect = %PreviewRect

var region: Dictionary


func init_control():
	theme_type_variation = "DarkPanelContainer"
	
	region = init_value.duplicate(true)
	
	frame_spinbox.value = region.frame
	frame_spinbox.editable = column.editable
	
	horizontal_spinbox.value = region.hor
	horizontal_spinbox.editable = column.editable
	
	vertical_spinbox.value = region.ver
	vertical_spinbox.editable = column.editable
	
	offset_x_spinbox.value = region.ox
	offset_x_spinbox.editable = column.editable
	
	offset_y_spinbox.value = region.oy
	offset_y_spinbox.editable = column.editable
	
	separation_x_spinbox.value = region.sx
	separation_x_spinbox.editable = column.editable
	
	separation_y_spinbox.value = region.sy
	separation_y_spinbox.editable = column.editable
	
	file_dropper.disabled = not column.editable
	file_dropper.can_drop_file = self.can_drop_file
	file_dropper.file_dropped.connect(self.on_file_dropped)
	
	init_signals()
	update_preview()
	file_dropper.update_path(region.texture)


func can_drop_file(file: String):
	return FileAccess.file_exists(file) and file.split(".")[-1] in Properties.FILE_TYPES["Image"]


func on_frame_changed(_frame: int):
	region.frame = _frame
	
	update_preview()
	
	value_changed.emit(region)


func on_horizontal_changed(_horizontal: int):
	region.hor = _horizontal
	
	update_preview()
	
	value_changed.emit(region)


func on_vertical_changed(_vertical: int):
	region.ver = _vertical
	
	update_preview()
	
	value_changed.emit(region)


func on_offset_x_changed(_offset_x: int):
	region.ox = _offset_x
	
	update_preview()
	
	value_changed.emit(region)


func on_offset_y_changed(_offset_y: int):
	region.oy = _offset_y
	
	update_preview()
	
	value_changed.emit(region)


func on_separation_x_changed(_separation_x: int):
	region.sx = _separation_x
	
	update_preview()
	
	value_changed.emit(region)


func on_separation_y_changed(_separation_y: int):
	region.sy = _separation_y
	
	update_preview()
	
	value_changed.emit(region)


func on_file_dropped(_file: String):
	region.texture = _file
	
	update_preview()
	
	value_changed.emit(region)


func update_preview():
	if not region.texture.is_empty():
		var image = load(region.texture)
		var rect = Helper.get_region_rect(image, region.frame, region.hor, region.ver, region.sx, region.sy, region.ox, region.oy)
		
		var atlas = AtlasTexture.new()
		atlas.atlas = image
		atlas.region = rect
		preview_rect.texture = atlas
	else:
		preview_rect.texture = null


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	region = value.duplicate(true)
	
	reset_signals() # used to set spinbox values without sending signals
	frame_spinbox.value = region.frame
	horizontal_spinbox.value = region.hor
	vertical_spinbox.value = region.ver
	offset_x_spinbox.value = region.ox
	offset_y_spinbox.value = region.oy
	separation_x_spinbox.value = region.sx
	separation_y_spinbox.value = region.sy
	file_dropper.update_path(region.texture)
	init_signals()
	
	update_preview()


func init_signals():
	frame_spinbox.value_changed.connect(self.on_frame_changed)
	horizontal_spinbox.value_changed.connect(self.on_horizontal_changed)
	vertical_spinbox.value_changed.connect(self.on_vertical_changed)
	offset_x_spinbox.value_changed.connect(self.on_offset_x_changed)
	offset_y_spinbox.value_changed.connect(self.on_offset_y_changed)
	separation_x_spinbox.value_changed.connect(self.on_separation_x_changed)
	separation_y_spinbox.value_changed.connect(self.on_separation_y_changed)


func reset_signals():
	if frame_spinbox.value_changed.is_connected(self.on_frame_changed):
		frame_spinbox.value_changed.disconnect(self.on_frame_changed)
	if horizontal_spinbox.value_changed.is_connected(self.on_horizontal_changed):
		horizontal_spinbox.value_changed.disconnect(self.on_horizontal_changed)
	if vertical_spinbox.value_changed.is_connected(self.on_vertical_changed):
		vertical_spinbox.value_changed.disconnect(self.on_vertical_changed)
	if offset_x_spinbox.value_changed.is_connected(self.on_offset_x_changed):
		offset_x_spinbox.value_changed.disconnect(self.on_offset_x_changed)
	if offset_y_spinbox.value_changed.is_connected(self.on_offset_y_changed):
		offset_y_spinbox.value_changed.disconnect(self.on_offset_y_changed)
	if separation_x_spinbox.value_changed.is_connected(self.on_separation_x_changed):
		separation_x_spinbox.value_changed.disconnect(self.on_separation_x_changed)
	if separation_y_spinbox.value_changed.is_connected(self.on_separation_y_changed):
		separation_y_spinbox.value_changed.disconnect(self.on_separation_y_changed)
