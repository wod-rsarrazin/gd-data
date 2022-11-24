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
	return "Data"


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
	
	var theme: Theme = Theme.new()
	
	# code edit
	var normal_code_edit_sb: StyleBoxFlat = StyleBoxFlat.new()
	normal_code_edit_sb.bg_color = dark_color
	normal_code_edit_sb.corner_radius_top_left = 8
	normal_code_edit_sb.corner_radius_top_right = 8
	normal_code_edit_sb.corner_radius_bottom_left = 8
	normal_code_edit_sb.corner_radius_bottom_right = 8
	normal_code_edit_sb.content_margin_left = 12
	normal_code_edit_sb.content_margin_right = 12
	normal_code_edit_sb.content_margin_top = 12
	normal_code_edit_sb.content_margin_bottom = 8
	theme.set_stylebox("normal", "ExpressionEdit", normal_code_edit_sb)
	
	# grid tree
	var focus_grid_tree_sb: StyleBoxEmpty = StyleBoxEmpty.new()
	theme.set_stylebox("focus", "GridTree", focus_grid_tree_sb)
	
	theme.set_stylebox("panel", "GridTree", StyleBoxEmpty.new())
	
	var title_grid_tree_sb: StyleBoxFlat = StyleBoxFlat.new()
	title_grid_tree_sb.bg_color = dark_color
	title_grid_tree_sb.border_color = color
	title_grid_tree_sb.content_margin_top = 14
	title_grid_tree_sb.content_margin_bottom = 13
	title_grid_tree_sb.border_width_top = 1
	title_grid_tree_sb.border_width_bottom = 1
	title_grid_tree_sb.border_width_right = 1
	theme.set_stylebox("title_button_hover", "GridTree", title_grid_tree_sb)
	theme.set_stylebox("title_button_normal", "GridTree", title_grid_tree_sb)
	theme.set_stylebox("title_button_pressed", "GridTree", title_grid_tree_sb)
	
	theme.set_constant("h_separation", "GridTree", 0)
	theme.set_constant("v_separation", "GridTree", 0)
	theme.set_color("grid_line", "GridTree", light_color)
	theme.set_color("cell_normal", "GridTree", color)
	theme.set_color("cell_selected", "GridTree", accent_color)
	theme.set_color("cell_disabled", "GridTree", dark_color)
	theme.set_color("cell_linked", "GridTree", accent_color.darkened(0.8))
	
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
	
	main_container.theme = theme
