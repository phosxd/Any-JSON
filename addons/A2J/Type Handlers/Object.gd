## Handles serialization for the Object type.
class_name A2JObjectTypeHandler extends A2JTypeHandler

## Named references that have been produced from conversion to Any-JSON.
## Cleared every time [code]to_json[/code] is called.
var produced_references:Array[String] = []


func _init() -> void:
	error_strings = [
		'Object "~~" is not defined in registry.',
		'"property_exclusions" in ruleset should be structured as follows: Dictionary[String,Array[String]].',
		'"convert_properties_to_references" in ruleset should be structured as follows: Dictionary[String,Dictionary[String,String]].',
	]


func to_json(object:Object, ruleset:Dictionary) -> Dictionary[String,Variant]:
	produced_references.clear() # Reset previously produced references.
	var object_class: String
	var script = object.get_script()
	if script is Script:
		object_class = script.get_global_name()
		if object_class == '':
			object_class = object.get_class()
	else:
		object_class = object.get_class()

	# Get & check registered object equivalent.
	var registered_object = A2J.object_registry.get(object_class, null)
	if registered_object == null:
		report_error(0, object_class)
		return {}
	registered_object = registered_object as Object
	# Get default object to compare properties with.
	var default_object:Object = _get_default_object(registered_object, object_class, ruleset)

	# Set up result.
	var result:Dictionary[String,Variant] = {
		'.type': 'Object:%s' % object_class, 
	}

	# Get exceptions from ruleset.
	var properties_to_exclude:Array[String] = _get_properties_to_exclude(object, ruleset)
	var properties_to_reference:Dictionary[String,String] = _get_properties_to_reference(object, ruleset)
	# Convert all properties.
	for property in object.get_property_list():
		if property.name in properties_to_exclude: continue # Exclude.
		if property.name.begins_with('_') && ruleset.get('exclude_private_properties'): continue
		# Reference is on properties to reference list.
		if property.name in properties_to_reference:
			var reference_name = properties_to_reference[property.name]
			result.set(property.name, _make_reference(reference_name))
			continue
		# Exclude null values.
		var property_value = object.get(property.name)
		if property_value == null: continue
		# Exclude values that are the same as default values.
		if ruleset.get('exclude_properties_set_to_default'):
			if property_value == default_object.get(property.name): continue
		# Convert value if not a primitive type.
		var new_value
		if typeof(property_value) not in A2J.primitive_types:
			new_value = A2J.to_json(property_value, ruleset)
		else:
			new_value = property_value
		# Set new value.
		result.set(property.name, new_value)
	
	return result


func from_json(json:Dictionary, ruleset:Dictionary) -> Object:
	var object_class:String = json.get('.type', '')
	assert(object_class.begins_with('Object:'), 'JSON ".type" must be "Object:<class_name>".')
	object_class = object_class.replace('Object:','')
	
	# Get & check registered object equivalent.
	var registered_object = A2J.object_registry.get(object_class, null)
	if registered_object == null:
		report_error(0)
	registered_object = registered_object as Object

	var result:Object = _get_default_object(registered_object, object_class, ruleset)
	var properties_to_exclude:Array[String] = _get_properties_to_exclude(result, ruleset)
	for key in json:
		if key.begins_with('.'): continue
		if key in properties_to_exclude: continue
		if key.begins_with('_') && ruleset.get('exclude_private_properties'): continue
		var value = json[key]
		var new_value
		if typeof(value) not in A2J.primitive_types:
			new_value = A2J.from_json(value, ruleset)
		else:
			new_value = value
		# Set value as metadata.
		if key.begins_with('metadata/'):
			result.set_meta(key.replace('metadata/',''), new_value)
		# Set value
		else:
			result.set(key, new_value)

	return result



## Assemble list of properties to exclude.
## [param object] is the object to use [code]is_class[/code] on.
func _get_properties_to_exclude(object:Object, ruleset:Dictionary) -> Array[String]:
	var property_exclusions_in_ruleset:Dictionary = ruleset.get('property_exclusions',{})
	# Throw error if property exclusions is not the expected type.
	if property_exclusions_in_ruleset is not Dictionary:
		report_error(1)
		return []

	# Iterate on every list of exclusions.
	var excluded_properties:Array[String] = []
	for key in property_exclusions_in_ruleset:
		if not object.is_class(key): continue
		var list = property_exclusions_in_ruleset[key]
		# Throw error if value is not the expected type.
		if list is not Array:
			report_error(1)
			return []
		# Add to excluded properties.
		excluded_properties.append_array(list)

	return excluded_properties


## Assemble list of properties to be converted to named references.
## [param object] is the object to use [code]is_class[/code] on.
func _get_properties_to_reference(object:Object, ruleset:Dictionary) -> Dictionary[String,String]:
	var properties_to_reference_in_ruleset = ruleset.get('property_references',{})
	if properties_to_reference_in_ruleset is not Dictionary:
		report_error(3)
		return {}

	# Iterate on every list.
	var properties_to_reference:Dictionary[String,String] = {}
	for key in properties_to_reference_in_ruleset:
		if not object.is_class(key): continue
		var list = properties_to_reference_in_ruleset[key]
		# Throw error if value is not the expected type.
		if list is not Dictionary:
			report_error(3)
			return {}
		# Add to properties to reference.
		for key_ in list:
			var value = list[key_]
			if value is not String:
				report_error(3)
				return {}
			properties_to_reference.set(key_, value)

	return properties_to_reference


func _make_reference(name:String) -> Dictionary[String,String]:
	var result:Dictionary[String,String] = {
		'.type': 'A2JReference',
		'value': name,
	}
	produced_references.append(name)
	return result


## Get the default object to compare properties to.
static func _get_default_object(registered_object:Object, object_class:String, ruleset:Dictionary) -> Object:
	var instantiator = ruleset.get('instantiator')
	if instantiator is Callable:
		return instantiator.call(registered_object, object_class)
	else:
		return registered_object.new()
