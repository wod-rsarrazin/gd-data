@tool
extends PanelContainer
class_name EditorContainer


var data: Data
var sheet: Sheet
var column: Column
var lines: Array[Line]

var init_value


signal value_changed(value)


func _ready():
	if data == null: return
	
	init_control()


func init_control():
	pass


func update_value_no_signal():
	pass
