@tool
extends PanelContainer
class_name EditorContainer


var data: GDData
var sheet: GDSheet
var column: GDColumn
var lines: Array[GDLine]

var init_value


signal value_changed(value)


func _ready():
	theme_type_variation = "EmptyPanelContainer"
	
	if data == null: return
	
	init_control()


func init_control():
	pass


func update_value_no_signal():
	pass
