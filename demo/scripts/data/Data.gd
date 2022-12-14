# Auto generated by plugin GDData
extends Node


var _data: Dictionary


func _ready():
	_data = GDDataLoader.new().load_data("res://demo/demo.json", {
		"heroes": Hero,
		"races": Race,
		"weapons": Weapon,
		"elements": Element,
		"gd_data_types": GDDataType,
		"gd_data_regions": GDDataRegion,
		"gd_data_cycles": GDDataCycle,
	})


func heroes_get_value(key: String) -> Hero: return _data.heroes.values.get(key)
func heroes_get_values() -> Array: return _data.heroes.values.values()
func heroes_get_keys() -> Array: return _data.heroes.values.keys()
func heroes_get_group(key: String) -> Array: return _data.heroes.groups.get(key)

func races_get_value(key: String) -> Race: return _data.races.values.get(key)
func races_get_values() -> Array: return _data.races.values.values()
func races_get_keys() -> Array: return _data.races.values.keys()
func races_get_group(key: String) -> Array: return _data.races.groups.get(key)

func weapons_get_value(key: String) -> Weapon: return _data.weapons.values.get(key)
func weapons_get_values() -> Array: return _data.weapons.values.values()
func weapons_get_keys() -> Array: return _data.weapons.values.keys()
func weapons_get_group(key: String) -> Array: return _data.weapons.groups.get(key)

func elements_get_value(key: String) -> Element: return _data.elements.values.get(key)
func elements_get_values() -> Array: return _data.elements.values.values()
func elements_get_keys() -> Array: return _data.elements.values.keys()
func elements_get_group(key: String) -> Array: return _data.elements.groups.get(key)

func gd_data_types_get_value(key: String) -> GDDataType: return _data.gd_data_types.values.get(key)
func gd_data_types_get_values() -> Array: return _data.gd_data_types.values.values()
func gd_data_types_get_keys() -> Array: return _data.gd_data_types.values.keys()
func gd_data_types_get_group(key: String) -> Array: return _data.gd_data_types.groups.get(key)

func gd_data_regions_get_value(key: String) -> GDDataRegion: return _data.gd_data_regions.values.get(key)
func gd_data_regions_get_values() -> Array: return _data.gd_data_regions.values.values()
func gd_data_regions_get_keys() -> Array: return _data.gd_data_regions.values.keys()
func gd_data_regions_get_group(key: String) -> Array: return _data.gd_data_regions.groups.get(key)

func gd_data_cycles_get_value(key: String) -> GDDataCycle: return _data.gd_data_cycles.values.get(key)
func gd_data_cycles_get_values() -> Array: return _data.gd_data_cycles.values.values()
func gd_data_cycles_get_keys() -> Array: return _data.gd_data_cycles.values.keys()
func gd_data_cycles_get_group(key: String) -> Array: return _data.gd_data_cycles.groups.get(key)
