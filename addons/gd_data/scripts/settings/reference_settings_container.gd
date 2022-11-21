@tool
extends SettingsContainer


@onready var sheet_key_button: OptionButton = %SheetKeyButton

var sheet_keys: Array


func init_control():
	sheet_keys = data.get_sheets_ordered().map(func(x): return x.key)
	sheet_key_button.item_selected.connect(self.on_sheet_key_selected)
	
	var current_sheet_key = settings.sheet_key
	if current_sheet_key.is_empty():
		current_sheet_key = sheet_keys[0]
	
	sheet_key_button.clear()
	for sheet_key in sheet_keys:
		sheet_key_button.add_item(sheet_key)
	sheet_key_button.selected = sheet_keys.find(current_sheet_key)
	
	settings.sheet_key = current_sheet_key


func on_sheet_key_selected(_sheet_key_index: int):
	settings.sheet_key = sheet_keys[_sheet_key_index]
	
	settings_updated.emit(settings)
