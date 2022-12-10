extends Resource
class_name Element


@export var key: String
@export var index: int
@export var name: String
@export var color: Color


func set_key(_value: String): key = _value
func set_index(_value: int): index = _value
func set_name(_value: String): name = _value
func set_color(_value: String): color = Color(_value)
