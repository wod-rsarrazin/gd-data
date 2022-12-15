extends Resource
class_name Weapon


@export var key: String
@export var index: int
@export var name: String
@export var texture_frame: int
@export var rank: int
@export var level: int
@export var strength: int
@export var element: Race
@export var texture_region: AtlasTexture


func set_key(_value: String): key = _value
func set_index(_value: int): index = _value
func set_name(_value: String): name = _value
func set_texture_frame(_value: int): texture_frame = _value
func set_rank(_value: int): rank = _value
func set_level(_value: int): level = _value
func set_strength(_value: int): strength = _value
func set_element(_value: Race): element = _value
func set_texture_region(_value: Dictionary): texture_region = Helper.get_atlas_from_region(_value)
