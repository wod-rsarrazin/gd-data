@tool
extends VBoxContainer
class_name SettingsContainer


var data: Data
var settings: Dictionary


signal settings_updated(settings: Dictionary)


func _ready():
	if data == null: return
	
	init_control()


func init_control():
	pass
