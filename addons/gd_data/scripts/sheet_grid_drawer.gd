@tool
extends GridDrawer
class_name SheetGridDrawer


func _ready():
	cell_count = Vector2(15, 500)
	cell_size = Vector2(160, 54)
	super._ready()


# override
func draw_cell(cell: Vector2, cell_rect: Rect2):
	if int(cell.x) % 4 == 0:
		draw_text(cell_rect, "test")
	elif int(cell.x) % 3 == 0:
		draw_curve(cell_rect)
	elif int(cell.x) == 0:
		draw_icon(cell_rect, icon_checked)
	else:
		draw_rect_color(cell_rect, Color.WHITE, 12)


# override
func selection_changed(selection: GridDrawerSelection):
	pass
