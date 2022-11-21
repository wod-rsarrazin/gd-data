@tool
extends Object
class_name Evaluator


func evaluate(command: String, values: Dictionary) -> Variant:
	var expression = Expression.new()
	var error = expression.parse(command, ["values"])
	if error != OK:
		return null

	var result = expression.execute([values], self)

	if expression.has_execute_failed():
		return null
	
	return result


func easing(t: float, transition: int = 0, ease: int = 0):
	t = clamp(t, 0, 1)
	return Tween.interpolate_value(0.0, 1.0, t, 1.0, transition, ease)


func test(condition: bool, if_value, else_value):
	return if_value if condition else else_value
