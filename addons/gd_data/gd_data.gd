@tool
extends EditorPlugin


var main_container: VBoxContainer


func _ready():
	main_container = load("res://addons/gd_data/scenes/main_container.tscn").instantiate()
	main_container.plugin_version = get_plugin_version()
	update_theme()
	get_editor_interface().get_editor_main_screen().add_child(main_container)
	main_container.hide()
	
	var file_system_dock = get_editor_interface().get_file_system_dock()
	file_system_dock.files_moved.connect(self.on_files_moved)
	file_system_dock.file_removed.connect(self.on_file_removed)


func _exit_tree():
	if main_container != null:
		main_container.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_container != null:
		main_container.visible = visible


func _get_plugin_name():
	return "GDData"


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")


# CUSTOM
func on_files_moved(old_file: String, new_file: String):
	main_container.on_file_moved(old_file, new_file)


func on_file_removed(file: String):
	main_container.on_file_removed(file)


func get_plugin_version():
	var config_file = ConfigFile.new()
	var err = config_file.load("res://addons/gd_data/plugin.cfg")
	if err != OK: return ""
	return config_file.get_value("plugin", "version", "")


func update_theme():
	var editor_theme = get_editor_interface().get_base_control().theme
	var color: Color = editor_theme.get_stylebox("tab_unselected", "TabContainer").bg_color
	var light_color: Color = editor_theme.get_stylebox("tab_selected", "TabContainer").bg_color
	var dark_color: Color = editor_theme.get_stylebox("panel", "Tree").bg_color
	var accent_color: Color = editor_theme.get_stylebox("selected", "Tree").bg_color
	var focus_color: Color = editor_theme.get_stylebox("focus", "Button").border_color
	
	var theme: Theme = Theme.new()
	
	update_theme_commons(theme, color, light_color, dark_color, accent_color, focus_color)
	update_theme_grid(theme, color, light_color, dark_color, accent_color, focus_color)
	update_theme_editor(theme, color, light_color, dark_color, accent_color, focus_color)
	
	main_container.theme = theme


func update_theme_commons(theme: Theme, color: Color, light_color: Color, dark_color: Color, accent_color: Color, focus_color: Color):
	# dark panel container
	var dark_panel_container_sb: StyleBoxFlat = StyleBoxFlat.new()
	dark_panel_container_sb.bg_color = dark_color
	dark_panel_container_sb.corner_radius_bottom_left = 8
	dark_panel_container_sb.corner_radius_top_left = 8
	dark_panel_container_sb.corner_radius_top_right = 8
	dark_panel_container_sb.corner_radius_bottom_right = 8
	theme.set_stylebox("panel", "DarkPanelContainer", dark_panel_container_sb)
	
	# empty panel container
	var empty_panel_container_sb: StyleBoxEmpty = StyleBoxEmpty.new()
	theme.set_stylebox("panel", "EmptyPanelContainer", empty_panel_container_sb)
	
	# expression edit
	var expression_edit_normal_sb: StyleBoxFlat = StyleBoxFlat.new()
	expression_edit_normal_sb.bg_color = dark_color
	expression_edit_normal_sb.corner_radius_top_left = 8
	expression_edit_normal_sb.corner_radius_top_right = 8
	expression_edit_normal_sb.corner_radius_bottom_left = 8
	expression_edit_normal_sb.corner_radius_bottom_right = 8
	expression_edit_normal_sb.content_margin_left = 12
	expression_edit_normal_sb.content_margin_right = 12
	expression_edit_normal_sb.content_margin_top = 12
	expression_edit_normal_sb.content_margin_bottom = 12
	
	var expression_edit_focus_sb: StyleBoxFlat = StyleBoxFlat.new()
	expression_edit_focus_sb.bg_color = dark_color
	expression_edit_focus_sb.border_color = focus_color
	expression_edit_focus_sb.corner_radius_top_left = 8
	expression_edit_focus_sb.corner_radius_top_right = 8
	expression_edit_focus_sb.corner_radius_bottom_left = 8
	expression_edit_focus_sb.corner_radius_bottom_right = 8
	expression_edit_focus_sb.content_margin_left = 12
	expression_edit_focus_sb.content_margin_right = 12
	expression_edit_focus_sb.content_margin_top = 12
	expression_edit_focus_sb.content_margin_bottom = 12
	expression_edit_focus_sb.border_width_left = 4
	expression_edit_focus_sb.border_width_right = 4
	expression_edit_focus_sb.border_width_top = 4
	expression_edit_focus_sb.border_width_bottom = 4
	
	theme.set_stylebox("focus", "ExpressionEdit", expression_edit_focus_sb)
	theme.set_stylebox("normal", "ExpressionEdit", expression_edit_normal_sb)
	theme.set_stylebox("read_only", "ExpressionEdit", expression_edit_normal_sb)


func update_theme_grid(theme: Theme, color: Color, light_color: Color, dark_color: Color, accent_color: Color, focus_color: Color):
	# grid drawer
	theme.set_color("background", "GridDrawer", color)
	theme.set_color("grid", "GridDrawer", light_color)
	theme.set_color("disabled", "GridDrawer", dark_color)
	theme.set_color("selected", "GridDrawer", accent_color)


func update_theme_editor(theme: Theme, color: Color, light_color: Color, dark_color: Color, accent_color: Color, focus_color: Color):
	var editor_normal_sb: StyleBoxFlat = StyleBoxFlat.new()
	editor_normal_sb.bg_color = dark_color
	editor_normal_sb.corner_radius_top_left = 8
	editor_normal_sb.corner_radius_top_right = 8
	editor_normal_sb.corner_radius_bottom_left = 8
	editor_normal_sb.corner_radius_bottom_right = 8
	editor_normal_sb.content_margin_left = 8
	editor_normal_sb.content_margin_right = 8
	editor_normal_sb.content_margin_top = 8
	editor_normal_sb.content_margin_bottom = 8
	
	var editor_focus_sb: StyleBoxFlat = StyleBoxFlat.new()
	editor_focus_sb.bg_color = dark_color
	editor_focus_sb.border_color = focus_color
	editor_focus_sb.corner_radius_top_left = 8
	editor_focus_sb.corner_radius_top_right = 8
	editor_focus_sb.corner_radius_bottom_left = 8
	editor_focus_sb.corner_radius_bottom_right = 8
	editor_focus_sb.content_margin_left = 8
	editor_focus_sb.content_margin_right = 8
	editor_focus_sb.content_margin_top = 8
	editor_focus_sb.content_margin_bottom = 8
	editor_focus_sb.border_width_left = 4
	editor_focus_sb.border_width_right = 4
	editor_focus_sb.border_width_top = 4
	editor_focus_sb.border_width_bottom = 4
	
	# checkbox
	theme.set_stylebox("disabled", "EditorCheckBox", editor_normal_sb)
	theme.set_stylebox("focus", "EditorCheckBox", editor_focus_sb)
	theme.set_stylebox("hover", "EditorCheckBox", editor_normal_sb)
	theme.set_stylebox("hover_pressed", "EditorCheckBox", editor_normal_sb)
	theme.set_stylebox("normal", "EditorCheckBox", editor_normal_sb)
	theme.set_stylebox("pressed", "EditorCheckBox", editor_normal_sb)
	
	# color button
	theme.set_stylebox("disabled", "EditorColorButton", editor_normal_sb)
	theme.set_stylebox("focus", "EditorColorButton", editor_focus_sb)
	theme.set_stylebox("hover", "EditorColorButton", editor_normal_sb)
	theme.set_stylebox("normal", "EditorColorButton", editor_normal_sb)
	theme.set_stylebox("pressed", "EditorColorButton", editor_normal_sb)
	
	# file dropper
	theme.set_stylebox("panel", "EditorFileDropper", editor_normal_sb)
	
	# line edit
	theme.set_stylebox("focus", "EditorLineEdit", editor_focus_sb)
	theme.set_stylebox("normal", "EditorLineEdit", editor_normal_sb)
	theme.set_stylebox("read_only", "EditorLineEdit", editor_normal_sb)
	
	# code edit
	theme.set_stylebox("focus", "EditorCodeEdit", editor_focus_sb)
	theme.set_stylebox("normal", "EditorCodeEdit", editor_normal_sb)
	theme.set_stylebox("read_only", "EditorCodeEdit", editor_normal_sb)
	
	# text edit
	theme.set_stylebox("focus", "EditorTextEdit", editor_focus_sb)
	theme.set_stylebox("normal", "EditorTextEdit", editor_normal_sb)
	theme.set_stylebox("read_only", "EditorTextEdit", editor_normal_sb)
	
	# option button
	theme.set_stylebox("disabled", "EditorOptionButton", editor_normal_sb)
	theme.set_stylebox("focus", "EditorOptionButton", editor_focus_sb)
	theme.set_stylebox("hover", "EditorOptionButton", editor_normal_sb)
	theme.set_stylebox("normal", "EditorOptionButton", editor_normal_sb)
	theme.set_stylebox("pressed", "EditorOptionButton", editor_normal_sb)
