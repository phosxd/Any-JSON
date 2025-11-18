## Handles serialization for various types.
## [br][br][b]Types:[/b]
## [br]- StringName
## [br]- NodePath
## [br]- Color
## [br]- Plane
## [br]- Quaternion
## [br]- Rect2
## [br]- Rect2i
## [br]- AABB
## [br]- Basis
## [br]- Transform2D
## [br]- Transform3D
## [br]- Projection
class_name A2JMiscTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'Cannot convert invalid value to JSON.',
		'Cannot construct value from invalid JSON representation.',
	]


func to_json(value, ruleset:Dictionary) -> Dictionary[String,Variant]:
	var result:Dictionary[String,Variant] = {
		'.type': type_string(typeof(value)),
		'value': null,
	}

	if value is StringName or value is NodePath:
		result.value = str(value)

	elif value is Color:
		result.value = [value.r, value.g, value.b, value.a]

	elif value is Plane:
		result.value = [value.x, value.y, value.z, value.d]

	elif value is Quaternion:
		result.value = [value.x, value.y, value.z, value.w]

	elif value is Rect2 or value is Rect2i:
		result.value = [value.position.x, value.position.y, value.size.x, value.size.y]

	elif value is AABB:
		result.value = [
			value.position.x, value.position.y, value.position.z,
			value.size.x, value.size.y, value.size.z,
		]

	elif value is Basis:
		result.value = [
			value.x.x, value.x.y, value.x.z,
			value.y.x, value.y.y, value.y.z,
			value.z.x, value.z.y, value.z.z,
		]

	elif value is Transform2D:
		result.value = [
			value.x.x, value.x.y,
			value.y.x, value.y.y,
			value.origin.x, value.origin.y,
		]

	elif value is Transform3D:
		result.value = [
			value.basis.x.x, value.basis.x.y, value.basis.x.z,
			value.basis.y.x, value.basis.y.y, value.basis.y.z,
			value.basis.z.x, value.basis.z.y, value.basis.z.z,
			value.origin.x, value.origin.y, value.origin.z,
		]

	elif value is Projection:
		result.value = [
			value.x.x, value.x.y, value.x.z, value.x.w,
			value.y.x, value.y.y, value.y.z, value.y.w,
			value.z.x, value.z.y, value.z.z, value.z.w,
			value.w.x, value.w.y, value.w.z, value.w.w,
		]

	# Throw error if not an expected type.
	else:
		report_error(0)
		return {}

	return result


func from_json(json:Dictionary, ruleset:Dictionary) -> Variant:
	var type = json.get('.type')
	if type is not String:
		report_error(1)
		return null
	var value = json.get('value')

	if type == 'StringName':
		if value is not String: report_error(1); return null
		return StringName(value)

	elif type == 'NodePath':
		if value is not String: report_error(1); return null
		return NodePath(value)

	elif type == 'Color':
		if value is not Array or value.size() != 4: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Color(value[0], value[1], value[2], value[3])

	elif type == 'Plane':
		if value is not Array or value.size() != 4: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Plane(Vector3(value[0], value[1], value[2]), value[3])

	elif type == 'Quaternion':
		if value is not Array or value.size() != 4: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Quaternion(value[0], value[1], value[2], value[3])

	elif type == 'Rect2':
		if value is not Array or value.size() != 4: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Rect2(value[0], value[1], value[2], value[3])

	elif type == 'Rect2i':
		if value is not Array or value.size() != 4: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Rect2i(int(value[0]), int(value[1]), int(value[2]), int(value[3]))

	elif type == 'AABB':
		if value is not Array or value.size() != 6: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return AABB(Vector3(value[0], value[1], value[2]), Vector3(value[3], value[4], value[5]))

	elif type == 'Basis':
		if value is not Array or value.size() != 9: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Basis(
			Vector3(value[0], value[1], value[2]),
			Vector3(value[3], value[4], value[5]),
			Vector3(value[6], value[7], value[8]),
		)

	elif type == 'Transform2D':
		if value is not Array or value.size() != 6: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Transform2D(
			Vector2(value[0], value[1]),
			Vector2(value[2], value[3]),
			Vector2(value[4], value[5]),
		)

	elif type == 'Transform3D':
		if value is not Array or value.size() != 12: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Transform3D(
			Vector3(value[0], value[1], value[2]),
			Vector3(value[3], value[4], value[5]),
			Vector3(value[6], value[7], value[8]),
			Vector3(value[9], value[10], value[11]),
		)

	elif type == 'Transform3D':
		if value is not Array or value.size() != 16: report_error(1); return null
		if not A2JUtil.is_number_array(value): report_error(1); return null
		return Projection(
			Vector4(value[0], value[1], value[2], value[3]),
			Vector4(value[4], value[5], value[6], value[7]),
			Vector4(value[8], value[9], value[10], value[11]),
			Vector4(value[12], value[13], value[14], value[15]),
		)

	# Throw error if no conditions match.
	else:
		report_error(1)
		return null
