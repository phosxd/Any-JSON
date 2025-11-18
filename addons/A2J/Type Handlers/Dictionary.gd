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
			key = A2J.to_json(key, ruleset)
			key = '@:'+JSON.stringify(key,"",true,false)
		# Convert value if not a primitive type.
		var new_value
		if typeof(value) not in A2J.primitive_types:
			new_value = A2J.to_json(value, ruleset)
		else:
			new_value = value
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
			key = A2J.from_json(key_json, ruleset)
		# Convert value.
		var new_value
		if typeof(value) not in A2J.primitive_types:
			new_value = A2J.from_json(value, ruleset)
		else:
			new_value = value
		# Append value
		result.set(key, new_value)

	return result
