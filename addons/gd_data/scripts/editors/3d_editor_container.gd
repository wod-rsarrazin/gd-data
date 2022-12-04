@tool
extends FileEditorContainer


@onready var mesh_instance: MeshInstance3D = %MeshInstance3D
@onready var camera: Camera3D = %Camera3D
@onready var clear_button: Button = %ClearButton

var invert_y = false
var invert_x = false
var mouse_sensitivity = 0.005


func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var rect = get_rect()
		rect.position = get_screen_position()
		
		if rect.has_point(event.position):
			if event.relative.x != 0:
				var dir = 1 if invert_x else -1
				mesh_instance.rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)
			if event.relative.y != 0:
				var dir = 1 if invert_y else -1
				mesh_instance.rotate_object_local(Vector3.RIGHT, dir * event.relative.y * mouse_sensitivity)
	if event is InputEventPanGesture:
		camera.transform.origin.z += event.delta.y


func init_control():
	texture_rect.visible = false
	
	clear_button.icon = get_theme_icon("Clear", "EditorIcons")
	clear_button.pressed.connect(self.on_clear_button_pressed)
	
	super.init_control()


func on_clear_button_pressed():
	camera.transform.origin = Vector3(0, 0, 5)
	mesh_instance.rotation = Vector3.ZERO


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	
	if value.split(".")[-1] in Properties.FILE_TYPES["3D"]:
		mesh_instance.mesh = load(value)
	else:
		mesh_instance.mesh = null
