@tool
extends CodeEdit
class_name ExpressionEdit


var clear_button: Button

var last_caret_column = 0


func _ready():
	theme_type_variation = "ExpressionEdit"
	auto_brace_completion_enabled = true
	context_menu_enabled = false
	drag_and_drop_selection_enabled = false
	highlight_all_occurrences = true
	syntax_highlighter = load("res://addons/gd_data/themes/code_highlighter.tres")
	scroll_fit_content_height = true
	caret_blink = true
	caret_changed.connect(self.on_caret_changed)
	text_changed.connect(self.on_text_changed)
	
	clear_button = Button.new()
	clear_button.flat = true
	clear_button.icon = get_theme_icon("Close", "EditorIcons")
	clear_button.pressed.connect(self.on_clear_button_pressed)
	clear_button.visible = not text.is_empty()
	clear_button.layout_direction = Control.LAYOUT_DIRECTION_RTL
	add_child(clear_button)


func set_text(text: String):
	clear_button.visible = not text.is_empty()
	super.set_text(text)


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
