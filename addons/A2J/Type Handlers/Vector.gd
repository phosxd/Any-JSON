## Handles serialization for Vector2(i), Vector3(i), & Vector4(i) types.
class_name A2JVectorTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'Cannot convert non-vector value to JSON.',
		'Cannot construct vector from invalid JSON representation.',
	]


func to_json(vector, ruleset:Dictionary) -> Dictionary[String,Variant]:
	var result:Dictionary[String,Variant] = {
		'.type': 'Vector',
		'float': true,
		'values': [],
	}
	# Vector2.
	if vector is Vector2:
		result.values = [vector.x, vector.y]
		result.float = true
	elif vector is Vector2i:
		result.values = [vector.x, vector.y]
		result.float = false
	# Vector3.
	elif vector is Vector3:
		result.values = [vector.x, vector.y, vector.z]
		result.float = true
	elif vector is Vector3i:
		result.values = [vector.x, vector.y, vector.z]
		result.float = false
	# Vector4.
	elif vector is Vector4:
		result.values = [vector.x, vector.y, vector.z, vector.w]
		result.float = true
	elif vector is Vector4i:
		result.values = [vector.x, vector.y, vector.z, vector.w]
		result.float = false

	# Throw error if not a vector.
	else:
		report_error(0)
		return {}

	return result


func from_json(json:Dictionary, ruleset:Dictionary) -> Variant:
	var values = json.get('values')
	var is_float = json.get('float')
	# Throw error if values is not an Array.
	if values is not Array:
		report_error(1)
		return null
	# Throw error if is_float is not a boolean.
	if is_float is not bool:
		report_error(1)
		return null
	# Re-type variables.
	values = values as Array
	is_float = is_float as bool
	
	# Check & throw error if values contains anything not a number.
	if not A2JUtil.is_number_array(values):
		report_error(1)
		return null

	# Vector2.
	if values.size() == 2 && not is_float:
		return Vector2i(values[0], values[1])
	elif values.size() == 2 && is_float:
		return Vector2(values[0], values[1])
	# Vector3.
	elif values.size() == 3 && not is_float:
		return Vector3i(values[0], values[1], values[2])
	elif values.size() == 3 && is_float:
		return Vector3(values[0], values[1], values[2])
	# Vector4.
	elif values.size() == 4 && not is_float:
		return Vector4i(values[0], values[1], values[2], values[3])
	elif values.size() == 4 && is_float:
		return Vector4(values[0], values[1], values[2], values[3])
	# Throw error if no conditions match.
	else:
		report_error(1)
		return null
