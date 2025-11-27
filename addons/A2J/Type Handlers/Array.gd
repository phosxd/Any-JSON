## Handles serialization for the Array type.
class_name A2JArrayTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'Cannot call "from_json" with invalid an Any-JSON object. Expects Array or Dictionary.',
	]


func to_json(array:Array, ruleset:Dictionary) -> Variant:
	var result:Array = []
	# Convert all items.
	for value in array:
		# Convert value if not a primitive type.
		var new_value
		if typeof(value) not in A2J.primitive_types:
			new_value = A2J._to_json(value, ruleset)
		else:
			new_value = value
		# Append new value.
		result.append(new_value)
	
	return result


func from_json(json, ruleset:Dictionary) -> Array:
	var list: Array
	if json is Dictionary:
		list = json.get('value', [])
	if json is Array:
		list = json
	else:
		report_error(0)
		return []

	var result:Array = []
	var index:int = -1
	for item in list:
		index += 1
		var new_value
		if typeof(item) not in A2J.primitive_types:
			new_value = A2J._from_json(item, ruleset)
			# Pass unresolved reference off to be resolved ater all objects are serialized & present in the object stack.
			if new_value is String && new_value == '_A2J_unresolved_reference':
				A2J._process_next_pass_functions.append(_resolve_reference.bind(result, index, item))
				continue
		else:
			new_value = item
		# Append value
		result.append(new_value)

	return result


func _resolve_reference(value, result, ruleset:Dictionary, array:Array, index:int, reference_to_resolve) -> Variant:
	var resolved_reference = A2J._from_json(reference_to_resolve, ruleset)
	if resolved_reference is String && resolved_reference == '_A2J_unresolved_reference': resolved_reference = null
	
	# Set value.
	if index == array.size():
		array.append(resolved_reference)
	else:
		array.insert(index, resolved_reference)

	return result
