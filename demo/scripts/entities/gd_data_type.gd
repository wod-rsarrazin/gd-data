extends Resource
class_name GDDataType


@export var key: String
@export var index: int
@export var text: String
@export var number: int
@export var color: Color
@export var file: String
@export var reference: GDDataType
@export var region: AtlasTexture
@export var image: Texture2D
@export var audio: AudioStream
@export var scene: PackedScene
@export var resource: Resource
@export var boolean: bool
@export var model: ArrayMesh
@export var myscript: GDScript
@export var dictionary: Dictionary
@export var array: Array


func set_key(_value: String): key = _value
func set_index(_value: int): index = _value
func set_text(_value: String): text = _value
func set_number(_value: int): number = _value
func set_color(_value: String): color = Color(_value)
func set_file(_value: String): file = _value
func set_reference(_value: GDDataType): reference = _value
func set_region(_value: Dictionary): region = Helper.get_atlas_from_region(_value)
func set_image(_value: String): image = load(_value) if not _value.is_empty() else null
func set_audio(_value: String): audio = load(_value) if not _value.is_empty() else null
func set_scene(_value: String): scene = load(_value) if not _value.is_empty() else null
func set_resource(_value: String): resource = load(_value) if not _value.is_empty() else null
func set_boolean(_value: bool): boolean = _value
func set_model(_value: String): model = load(_value) if not _value.is_empty() else null
func set_myscript(_value: String): myscript = load(_value) if not _value.is_empty() else null
func set_dictionary(_value: Dictionary): dictionary = _value
func set_array(_value: Array): array = _value
