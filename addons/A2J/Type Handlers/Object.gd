## Handles serialization for the Object type.
class_name A2JObjectTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'Object "~~" is not defined in registry.',
		'"property_exclusions" in ruleset should be structured as follows: Dictionary[String,Array[String]].',
		'"convert_properties_to_references" in ruleset should be structured as follows: Dictionary[String,Dictionary[String,String]].',
		'"instantiator_function" in ruleset should be structured as follows: Callable(registered_object:Object, object_class:String, args:Array=[]) -> Object.',
		'"instantiator_arguments" in rulset should be structured as follows: Dictionary[String,Array].',
		'"property_inclusions" in ruleset should be structured as follows: Dictionary[String,Array[String]].',
		'Cannot convert from an invalid JSON representation.',
	]
	init_data = {
		'ids_to_objects': {},
	}


func to_json(object:Object, ruleset:Dictionary) -> Dictionary[String,Variant]:
	var object_class := A2JUtil.get_class_name(object)

	# Get & check registered object equivalent.
	var registered_object = A2J.object_registry.get(object_class, null)
	if registered_object == null:
		report_error(0, object_class)
		return {}
	registered_object = registered_object as Object
	# Get default object to compare properties with.
	var default_object:Object = _get_default_object(registered_object, object_class, ruleset)

	# If object has been serialized before, return a reference to it.
	var ids_to_objects:Dictionary = A2J._process_data.ids_to_objects
	var id = ids_to_objects.find_key(object)
	if id != null:
		return _make_reference('.i'+str(id))
	# If not, add to object stack & update index.
	else:
		id = ids_to_objects.keys().size()
		A2J._process_data.ids_to_objects.set(id, object)

	# Set up result.
	var result:Dictionary[String,Variant] = {
		'.type': 'Object:%s:%s' % [id, object_class],  # Pack class name & ID into type.
	}

	# Get exceptions from ruleset.
	var properties_to_exclude := _get_properties_to_exclude(object, ruleset)
	var properties_to_include := _get_properties_to_include(object, ruleset)
	var props_to_include_temp = ruleset.get('properties_inclusions', {})
	var do_properties_to_include = (props_to_include_temp is Dictionary && not props_to_include_temp.is_empty())
	var properties_to_reference:Dictionary[String,String] = _get_properties_to_reference(object, ruleset)
	# Convert all properties.
	for property in object.get_property_list():
		if property.name in properties_to_exclude: continue # Exclude.
		if property.name.begins_with('_') && ruleset.get('exclude_private_properties'): continue
		if do_properties_to_include && property.name not in properties_to_include: continue
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
		# Convert value.
		var new_value = A2J._to_json(property_value, ruleset)
		# Don't store null values.
		if new_value == null: continue
		# Set new value.
		result.set(property.name, new_value)
	
	return result


func from_json(json:Dictionary, ruleset:Dictionary) -> Object:
	var object_class:String = json.get('.type', '')
	var split_object_class = object_class.split(':')
	# Throw error if invalid number of splits.
	if split_object_class.size() != 3:
		report_error(6)
		return Object.new()
	# Set object class & id.
	object_class = split_object_class[2]
	var id = split_object_class[1]
	
	# Get & check registered object equivalent.
	var registered_object = A2J.object_registry.get(object_class, null)
	if registered_object == null:
		report_error(0)
	registered_object = registered_object as Object

	# Convert all values in the dictionary.
	var result := _get_default_object(registered_object, object_class, ruleset)
	var object_property_details := _get_object_property_details(result)
	var properties_to_exclude := _get_properties_to_exclude(result, ruleset)
	var properties_to_include = _get_properties_to_include(result, ruleset)
	var props_to_include_temp = ruleset.get('properties_inclusions', {})
	var do_properties_to_include:bool = (props_to_include_temp is Dictionary && not props_to_include_temp.is_empty())
	# Sort keys to prioritize script property.
	var keys = json.keys()
	keys.sort_custom(func(a,b) -> bool:
		return a == 'script'
	)
	for key in keys:
		if key.begins_with('.'): continue
		if key in properties_to_exclude: continue
		if key.begins_with('_') && ruleset.get('exclude_private_properties'): continue
		if do_properties_to_include && key not in properties_to_include: continue
		var value = json[key]
		var property_details:Dictionary = object_property_details.get(key, {})
		var new_value = A2J._from_json(value, ruleset, property_details)
		# Pass unresolved reference off to be resolved ater all objects are serialized & present in the object stack.
		if new_value is String && new_value == '_A2J_unresolved_reference':
			A2J._process_next_pass_functions.append(_resolve_reference.bind(result, key, value))
			continue
		# Set value as metadata.
		if key.begins_with('metadata/'):
			result.set_meta(key.replace('metadata/',''), new_value)
		# Set value
		else: result.set(key, new_value)

	# Add result object to "ids_to_objects" for use in references.
	A2J._process_data.ids_to_objects.set(str(id), result)

	return result


func _resolve_reference(value, result, ruleset:Dictionary, object:Object, property:String, reference_to_resolve) -> Variant:
	var resolved_reference = A2J._from_json(reference_to_resolve, ruleset)
	if resolved_reference is String && resolved_reference == '_A2J_unresolved_reference': resolved_reference = null
	
	# Set value as metadata.
	if property.begins_with('metadata/'):
		object.set_meta(property.replace('metadata/',''), resolved_reference)
	# Set value
	else: object.set(property, resolved_reference)

	return result


## Assemble list of properties to exclude.
## [param object] is the object to use [code]is_class[/code] on.
func _get_properties_to_exclude(object:Object, ruleset:Dictionary) -> PackedStringArray:
	var property_exclusions_in_ruleset:Dictionary = ruleset.get('property_exclusions',{})
	# Throw error if property exclusions is not the expected type.
	if property_exclusions_in_ruleset is not Dictionary:
		report_error(1)
		return []

	# Iterate on every list of exclusions.
	var excluded_properties := PackedStringArray()
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


## Assemble list of properties to include.
## [param object] is the object to use [code]is_class[/code] on.
func _get_properties_to_include(object:Object, ruleset:Dictionary) -> PackedStringArray:
	var property_inclusions_in_ruleset:Dictionary = ruleset.get('property_inclusions',{})
	# Throw error if property inclusions is not the expected type.
	if property_inclusions_in_ruleset is not Dictionary:
		report_error(5)
		return []

	# Iterate on every list of inclusions.
	var included_properties := PackedStringArray()
	for key in property_inclusions_in_ruleset:
		if not object.is_class(key): continue
		var list = property_inclusions_in_ruleset[key]
		# Throw error if value is not the expected type.
		if list is not Array:
			report_error(5)
			return []
		# Add to included properties.
		included_properties.append_array(list)

	return included_properties


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


func _make_reference(name:String) -> Dictionary[String,Variant]:
	var result:Dictionary[String,Variant] = {
		'.type': 'A2JRef',
		'name': name,
	}
	return result


## Get the default object to compare properties to.
func _get_default_object(registered_object:Object, object_class:String, ruleset:Dictionary) -> Object:
	var instantiator_function = ruleset.get('instantiator_function', A2J._default_instantiator_function)
	var instantiator_arguments = ruleset.get('instantiator_arguments', {})
	if instantiator_function is not Callable:
		instantiator_function = A2J._default_instantiator_function
		report_error(3)
	# Correct instantiator arguments to be dictionary if it isn't.
	if instantiator_arguments is not Dictionary:
		instantiator_arguments = {}
		report_error(4)
	# Get arguments.
	var args = instantiator_arguments.get(object_class)
	# If no instantiation arguments provided, call with no arguments.
	if args is not Array or args.size() == 0:
		return instantiator_function.call(registered_object, object_class)
	# Otherwise, call with arguments.
	else:
		return instantiator_function.call(registered_object, object_class, args)


func _get_object_property_details(object:Object) -> Dictionary[String,Dictionary]:
	var properties:Dictionary[String,Dictionary] = {}
	var property_list := object.get_property_list()
	for item in property_list:
		properties.set(item.name, {
			'class_name': item.class_name,
			'type': item.type,
			'hint_string': item.hint_string,
		})
	return properties
