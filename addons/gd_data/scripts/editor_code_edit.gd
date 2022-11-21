@tool
extends CodeEdit


@onready var clear_button: Button = %ClearButton

var last_caret_column = 0


func _ready():
	theme_type_variation = "ExpressionEdit"
	
	caret_changed.connect(self.on_caret_changed)
	text_changed.connect(self.on_text_changed)
	
	clear_button.icon = get_theme_icon("Close", "EditorIcons")
	clear_button.pressed.connect(self.on_clear_button_pressed)
	clear_button.visible = not text.is_empty()


func on_caret_changed():
	if not "\n" in text:
		last_caret_column = get_caret_column()


func on_text_changed():
	if "\n" in text:
		text = text.replace("\n", "")
		set_caret_column(last_caret_column)
	clear_button.visible = not text.is_empty()


func on_clear_button_pressed():
	text = ""
	clear_button.visible = false


func _can_drop_data(position, data):
	if data.type != "files": return false
	if data.files.size() != 1: return false
	var value = data.files[0]
	return not value.is_empty()


func _drop_data(position, data):
	var value = data.files[0]
	insert_text_at_caret("\"" + value + "\"")
