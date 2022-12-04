@tool
extends FileEditorContainer


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	
	if value.split(".")[-1] in Properties.FILE_TYPES["Image"]:
		texture_rect.texture = load(value)
	else:
		texture_rect.texture = null
