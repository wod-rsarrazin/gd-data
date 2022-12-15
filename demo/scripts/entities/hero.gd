extends Resource
class_name Hero


@export var key: String
@export var index: int
@export var name: String
@export var race: Race
@export var level: int
@export var strength: int
@export var texture: Texture2D
@export var color: Color
@export var is_human: bool
@export var events: Array
@export var dictionary: Dictionary


func set_key(_value: String): key = _value
func set_index(_value: int): index = _value
func set_name(_value: String): name = _value
func set_race(_value: Race): race = _value
func set_level(_value: int): level = _value
func set_strength(_value: int): strength = _value
func set_texture(_value: String): texture = load(_value) if not _value.is_empty() else null
func set_color(_value: String): color = Color(_value)
func set_is_human(_value: bool): is_human = _value
func set_events(_value: Array): events = _value
func set_dictionary(_value: Dictionary): dictionary = _value
