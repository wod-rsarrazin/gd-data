extends Object
class_name UpdateResult


const OK = 0
const KO = 1
const NONE = 2

var state: int
var message: String


func is_ok():
	return state == OK


func is_ko():
	return state == KO


func is_none():
	return state == NONE


static func ok():
	var result = UpdateResult.new()
	result.state = OK
	return result


static func ko(message: String):
	var result = UpdateResult.new()
	result.state = KO
	result.message = message
	return result


static func none():
	var result = UpdateResult.new()
	result.state = NONE
	return result
