extends Resource
class_name GDDataRegion


@export var key: String
@export var index: int
@export var icon_frame: int
@export var icon: AtlasTexture
@export var icon_off: AtlasTexture
@export var icon_sep: AtlasTexture
@export var icon_off_sep: AtlasTexture


func set_key(_value: String): key = _value
func set_index(_value: int): index = _value
func set_icon_frame(_value: int): icon_frame = _value
func set_icon(_value: Dictionary): icon = Helper.get_atlas_from_region(_value)
func set_icon_off(_value: Dictionary): icon_off = Helper.get_atlas_from_region(_value)
func set_icon_sep(_value: Dictionary): icon_sep = Helper.get_atlas_from_region(_value)
func set_icon_off_sep(_value: Dictionary): icon_off_sep = Helper.get_atlas_from_region(_value)
