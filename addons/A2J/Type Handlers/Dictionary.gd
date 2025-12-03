## Handles serialization for the Dictionary type.
class_name A2JDictionaryTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'Cannot convert from an invalid JSON representation.',
	]


func to_json(dict:Dictionary, ruleset:Dictionary) -> Dictionary[String,Variant]:
	var result:Dictionary[String,Variant] = {}
	# Convert all items.
	for key in dict:
		var value = dict[key]
		# Convert key if is not string.
		if key is not String:
			key = A2J._to_json(key, ruleset)
			key = '@:'+JSON.stringify(key,"",true,false)
		# Convert value.
		var new_value = A2J._to_json(value, ruleset)
		# Set new value.
		result.set(key, new_value)
	
	return result


func from_json(json:Dictionary, ruleset:Dictionary) -> Dictionary[Variant,Variant]:
	var result := {}
	for key in json:
		if key is not String:
			report_error(0)
			return {}
		var value = json[key]
		# Convert string key to variant key.
		if key.begins_with('@:'):
			var key_json = JSON.parse_string(key.replace('@:',''))
			if key_json == null:
				report_error(0)
				return {}
			key = A2J._from_json(key_json, ruleset)
		# Convert value.
		var new_value = A2J._from_json(value, ruleset)
		# Pass unresolved reference off to be resolved ater all objects are serialized & present in the object stack.
		if new_value is String && new_value == '_A2J_unresolved_reference':
			A2J._process_next_pass_functions.append(_resolve_reference.bind(result, key, value))
			continue
		# Append value
		result.set(key, new_value)

	return result


func _resolve_reference(value, result, ruleset:Dictionary, dict:Dictionary, key:String, reference_to_resolve) -> Variant:
	var resolved_reference = A2J._from_json(reference_to_resolve, ruleset)
	if resolved_reference is String && resolved_reference == '_A2J_unresolved_reference': resolved_reference = null
	
	# Set value.
	dict.set(key, resolved_reference)

	return result
