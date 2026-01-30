## Handles serialization for the Array type.
class_name A2JArrayTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'Expected array or dictionary.',
	]


func to_json(array:Array, ruleset:Dictionary) -> Variant:
	var result:Array = []
	# Convert all items.
	var index := -1
	for value in array:
		index += 1
		A2J._tree_position.append('@index:%s' % index)
		# Convert value.
		var new_value = A2J._to_json(value, ruleset)
		# Don't add null values.
		if new_value == null:
			A2J._tree_position.pop_back()
			continue
		# Append new value.
		result.append(new_value)
		A2J._tree_position.pop_back()
	
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
	for value in list:
		index += 1
		A2J._tree_position.append('@index:%s' % index)
		# Convert value.
		var new_value = A2J._from_json(value, ruleset)
		# Pass unresolved reference off to be resolved ater all objects are serialized & present in the object stack.
		if new_value is String && new_value == '_A2J_unresolved_reference':
			A2J._process_next_pass_functions.append(_resolve_reference.bind(result, index, value))
			A2J._tree_position.pop_back()
			continue
		# Append value
		result.append(new_value)
		A2J._tree_position.pop_back()

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
