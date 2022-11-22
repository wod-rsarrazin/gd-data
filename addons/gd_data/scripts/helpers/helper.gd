extends Object
class_name Helper


static func get_region_rect(img_width: int, img_height: int, frame: int, hor: int, ver: int, sx: int, sy: int, ox: int, oy: int) -> Rect2:
	frame = clamp(frame, 0, hor * ver)
	
	var width = (img_width - ox - sx * (hor - 1)) / hor
	var height = (img_height - oy - sy * (ver - 1)) / ver
	var x = ox + (frame % hor * (width + sx))
	var y = oy + (frame / hor * (height + sy))
	
	return Rect2(x, y, width, height)
