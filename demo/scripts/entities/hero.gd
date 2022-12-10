extends Resource
class_name Hero


@export var key: String
@export var index: int
@export var name: String
@export var race: Race
@export var is_human: bool
@export var level: int
@export var strength: int
@export var texture: Texture2D
@export var color: Color
@export var obj: Dictionary


func set_key(_value: String): key = _value
func set_index(_value: int): index = _value
func set_name(_value: String): name = _value
func set_race(_value: Race): race = _value
func set_is_human(_value: bool): is_human = _value
func set_level(_value: int): level = _value
func set_strength(_value: int): strength = _value
func set_texture(_value: String): 
	if _value.is_empty(): return
	texture = load(_value)
func set_color(_value: String): color = Color(_value)
func set_obj(_value: Dictionary): obj = _value
